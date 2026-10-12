// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import ApplicationServices
import Combine

/// Hides the menu bar icons left of the collapser, shows them again on a click,
/// keeps the never-shown ones out of the bar altogether and reorders icons on
/// request. macOS 27 or later only.
///
/// The physical order of the bar is the only truth for hiding: whatever sits
/// left of the collapser when the bar collapses is hidden, so a native ⌘-drag
/// across the collapser changes membership and no separate list can drift
/// from the bar. Never-shown icons have no place in the bar to tell them by,
/// so they are the one list that is stored, and they stay out while the bar
/// is expanded too. Hiding works per app (the system allowlist takes bundle
/// ids), which is why Vorssaint's own icons, system items and helper
/// processes without a bundle id are never hidden.
///
/// Every doubt resolves towards a visible bar: an empty walk, a missing
/// collapser, a refused activation or a revoked permission drops the
/// restriction, never-shown icons included. Main thread only, like the other services; the Accessibility
/// walks and the drags run on background queues.
final class MenuBarOrganizerService: ObservableObject {
    static let shared = MenuBarOrganizerService()

    enum State: Equatable { case off, expanded, collapsed, applying }
    enum Problem: Equatable {
        case accessibilityMissing
        case collapserNotFound
        case activationFailed(String)
        case nothingToHide
    }

    @Published private(set) var state: State = .off
    @Published private(set) var problem: Problem?
    /// The last walk of an expanded bar, in visual order. Kept while
    /// collapsed, when the hidden items are gone from Accessibility.
    @Published private(set) var inventory: [MenuBarItemSnapshot] = []
    /// The last partition at the collapser; the hidden list survives a collapse.
    @Published private(set) var layout: MenuBarLayout?
    /// Localized names of other running menu bar managers.
    @Published private(set) var runningManagers: [String] = []
    @Published private(set) var lastApplyReport: (moved: Int, failed: Int)?
    /// What the last collapse hid, also across a relaunch.
    @Published private(set) var lastHidden: [MenuBarHiddenRecord]
    /// The icons kept out of the bar for good, in the order of the editor.
    @Published private(set) var neverShown: [MenuBarHiddenRecord]

    /// Why hiding cannot work on this Mac, nil when it can. The private API is
    /// only looked up on macOS 27 or later.
    static let unsupportedReason: MenuBarOrganizerAvailability.Unsupported? = {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return MenuBarOrganizerAvailability.unsupportedReason(
            majorVersion: version.majorVersion,
            versionString: "\(version.majorVersion).\(version.minorVersion)",
            bridgeAvailable: version.majorVersion >= 27 && MenuBarVisibilityAssertion.isAvailable)
    }()

    var unsupportedReason: MenuBarOrganizerAvailability.Unsupported? { Self.unsupportedReason }
    var isSupported: Bool { Self.unsupportedReason == nil }

    private static let quietWalkInterval: TimeInterval = 1
    private static let quietWaitLimit: TimeInterval = 60
    private static let launchPollInterval: TimeInterval = 0.2
    private static let launchRevealWindow: TimeInterval = 2.5
    /// Launches in a burst share one reveal, which may stretch this far.
    private static let launchRevealLimit: TimeInterval = 6
    private static let moverQueue = DispatchQueue(label: "com.vorssaint.menu-bar-organizer.mover",
                                                  qos: .userInitiated)

    private let assertion = MenuBarVisibilityAssertion()
    private let collapser = MenuBarOrganizerCollapser()
    private let ownBundleID = Bundle.main.bundleIdentifier ?? ""
    /// Advances whenever the user or the system changes course, so a walk or
    /// timer that answers late knows it has been overtaken.
    private var epoch = 0
    private var quietGate = MenuBarQuietGate()
    private var rehideTimer: Timer?
    private var hiddenBundles = Set<String>()
    /// Bundles launched while icons were hidden whose icons the open bar is
    /// waiting for.
    private var awaitedLaunches = Set<String>()
    private var launchRevealStarted: TimeInterval = 0
    private var launchRevealDeadline: TimeInterval = 0
    private var applyCancellation: Cancellation?
    private var workspaceTokens: [NSObjectProtocol] = []
    private var accessibilityObserver: AnyCancellable?

    private init() {
        lastHidden = MenuBarHiddenRecord.decode(UserDefaults.standard.data(forKey: DefaultsKey.menuBarOrganizerLastHidden))
        neverShown = MenuBarHiddenRecord.decode(UserDefaults.standard.data(forKey: DefaultsKey.menuBarOrganizerNeverShown))
        collapser.onToggle = { [weak self] in self?.toggle() }
        collapser.onOpenSettings = {
            SettingsRouter.shared.page = .menuBarOrganizer
            (NSApp.delegate as? AppDelegate)?.openSettingsWindow()
        }
    }

    // MARK: - Lifecycle

    func syncWithPreferences() {
        let enabled = isSupported
            && AppFeature.menuBarOrganizer.isAvailable
            && UserDefaults.standard.bool(forKey: DefaultsKey.menuBarOrganizerEnabled)
        if enabled {
            start()
        } else {
            stop()
        }
    }

    private func start() {
        guard state == .off else { return }
        state = .expanded
        problem = nil
        // In the bar before any assertion: an item registered while icons are
        // hidden parks off screen until they are shown again.
        collapser.install(collapsed: false)

        let center = NSWorkspace.shared.notificationCenter
        workspaceTokens = [
            center.addObserver(forName: NSWorkspace.didLaunchApplicationNotification,
                               object: nil, queue: .main) { [weak self] note in
                guard let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
                else { return }
                self?.applicationLaunched(app)
            },
            center.addObserver(forName: NSWorkspace.didTerminateApplicationNotification,
                               object: nil, queue: .main) { [weak self] _ in
                self?.refreshManagers()
            },
            center.addObserver(forName: NSWorkspace.didWakeNotification,
                               object: nil, queue: .main) { [weak self] _ in
                self?.reassertAfterWake()
            }
        ]
        accessibilityObserver = Permissions.shared.$accessibility
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] granted in self?.accessibilityChanged(granted) }
        refreshManagers()
        collapseWhenQuiet()
    }

    /// Shows every icon, the never-shown ones too, and removes the collapser.
    /// Safe to call at any time,
    /// including on quit and while a reorder pass is running.
    func stop() {
        advance()
        assertion.release()
        guard state != .off else { return }
        workspaceTokens.forEach(NSWorkspace.shared.notificationCenter.removeObserver)
        workspaceTokens = []
        accessibilityObserver = nil
        collapser.remove()
        state = .off
        problem = nil
    }

    // MARK: - Showing and hiding

    func toggle() {
        switch state {
        case .collapsed: expand()
        case .expanded: collapse()
        case .off, .applying: break
        }
    }

    /// Redraws the collapser after its icon was changed in Settings.
    func refreshIcon() {
        collapser.setCollapsed(state == .collapsed)
    }

    /// Hides the icons left of the collapser, reading the boundary afresh.
    func collapse() {
        guard state == .expanded else { return }
        walkAndCollapse(token: advance())
    }

    /// Shows the hidden icons where they were. Also calls off a collapse that
    /// is still waiting for the bar to settle.
    func expand() {
        guard state == .collapsed || state == .expanded else { return }
        let wasCollapsed = state == .collapsed
        advance()
        state = .expanded
        collapser.setCollapsed(false)
        // A collapse that was still waiting never restricted the bar, and a
        // bar that is still settling must stay unrestricted.
        guard wasCollapsed else {
            assertion.release()
            return
        }
        restrictExpanded()
        scheduleAutoRehide()
        // The icons return a moment after the restriction lifts.
        let token = epoch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self, self.epoch == token else { return }
            self.refreshInventory()
        }
    }

    /// An expanded bar still keeps the never-shown apps out; without any the
    /// restriction is dropped. A restriction already held stays until the new
    /// one is live, so never-shown icons do not flash when the bar expands.
    private func restrictExpanded() {
        guard let allowed = allowlist(hiding: []) else {
            assertion.release()
            return
        }
        let token = epoch
        assertion.activate(bundles: allowed.bundles, systemItems: allowed.systemItems) { [weak self] failure in
            guard let self, self.epoch == token, let failure else { return }
            self.failOpen(.activationFailed(failure))
        }
    }

    /// Allowlist that keeps out `hidden` and the never-shown apps, judged by
    /// the last inventory. nil when that hides nothing.
    private func allowlist(hiding hidden: Set<String>) -> (bundles: [String], systemItems: [Int])? {
        let never = MenuBarOrganizerLayout.neverShownBundles(
            in: MenuBarLayout(hidden: [], visible: [], neverShown: neverShown.map(\.identity)),
            items: inventory, known: neverShown, ownBundleID: ownBundleID)
        return MenuBarOrganizerLayout.allowlist(hiddenBundles: hidden, neverShownBundles: never,
                                                observed: inventory, running: runningBundles(),
                                                ownBundleID: ownBundleID)
    }

    /// Re-reads the bar for the editor. Only an expanded bar is read: while
    /// icons are hidden they are gone from Accessibility and the frames of
    /// the rest are stale. The never-shown ones are missing from an expanded
    /// bar as well, and no reader needs them.
    func refreshInventory() {
        refreshManagers()
        guard canReadLayout else { return }
        let token = epoch
        MenuBarAccessibilityInventory.walk { [weak self] items in
            guard let self, self.epoch == token, self.canReadLayout else { return }
            self.adopt(items)
        }
    }

    private var canReadLayout: Bool {
        state == .expanded || state == .off
    }

    /// Collapses once three walks a second apart agree, so icons of login
    /// items that are still starting are in place before the boundary is read.
    private func collapseWhenQuiet() {
        let token = advance()
        guard AXIsProcessTrusted() else {
            problem = .accessibilityMissing
            return
        }
        quietGate = MenuBarQuietGate()
        quietWalk(token: token, started: ProcessInfo.processInfo.systemUptime)
    }

    private func quietWalk(token: Int, started: TimeInterval) {
        MenuBarAccessibilityInventory.walk { [weak self] items in
            guard let self, self.epoch == token, self.state == .expanded else { return }
            let waited = ProcessInfo.processInfo.systemUptime - started
            if self.quietGate.observe(items.map(\.identity)) || waited >= Self.quietWaitLimit {
                self.collapse(with: items, token: token)
                return
            }
            self.adopt(items)
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.quietWalkInterval) { [weak self] in
                guard let self, self.epoch == token else { return }
                self.quietWalk(token: token, started: started)
            }
        }
    }

    /// Walks and collapses. The bar must be expanded when this is called.
    private func walkAndCollapse(token: Int) {
        guard AXIsProcessTrusted() else {
            failOpen(.accessibilityMissing)
            return
        }
        MenuBarAccessibilityInventory.walk { [weak self] items in
            guard let self, self.epoch == token else { return }
            self.collapse(with: items, token: token)
        }
    }

    private func collapse(with items: [MenuBarItemSnapshot], token: Int) {
        guard !items.isEmpty else {
            failOpen(AXIsProcessTrusted() ? .collapserNotFound : .accessibilityMissing)
            return
        }
        adopt(items)
        guard let layout else {
            failOpen(.collapserNotFound)
            return
        }
        let hidden = MenuBarOrganizerLayout.hiddenBundles(in: layout, items: items, ownBundleID: ownBundleID)
        guard let allowed = allowlist(hiding: hidden) else {
            failOpen(.nothingToHide)
            return
        }
        hiddenBundles = hidden
        remember(MenuBarHiddenRecord.records(for: layout, items: items, ownBundleID: ownBundleID))
        assertion.activate(bundles: allowed.bundles, systemItems: allowed.systemItems) { [weak self] failure in
            guard let self, self.epoch == token else { return }
            if let failure {
                self.failOpen(.activationFailed(failure))
                return
            }
            self.problem = nil
            self.state = .collapsed
            self.collapser.setCollapsed(true)
        }
    }

    /// Shows the whole bar, never-shown icons included, and says why hiding
    /// is paused.
    private func failOpen(_ reason: Problem) {
        assertion.release()
        problem = reason
        if state == .collapsed { state = .expanded }
        collapser.setCollapsed(false)
    }

    private func adopt(_ items: [MenuBarItemSnapshot]) {
        if inventory != items { inventory = items }
        let partition = MenuBarOrganizerCollapser.identity.flatMap {
            MenuBarOrganizerLayout.partition(items, collapser: $0)
        }
        if layout != partition { layout = partition }
    }

    private func remember(_ records: [MenuBarHiddenRecord]) {
        guard records != lastHidden else { return }
        lastHidden = records
        UserDefaults.standard.set(MenuBarHiddenRecord.encode(records), forKey: DefaultsKey.menuBarOrganizerLastHidden)
    }

    private func rememberNeverShown(_ records: [MenuBarHiddenRecord]) {
        guard records != neverShown else { return }
        neverShown = records
        UserDefaults.standard.set(MenuBarHiddenRecord.encode(records), forKey: DefaultsKey.menuBarOrganizerNeverShown)
    }

    private func scheduleAutoRehide() {
        let seconds = UserDefaults.standard.integer(forKey: DefaultsKey.menuBarOrganizerAutoRehideSeconds)
        guard seconds > 0 else { return }
        let timer = Timer(timeInterval: TimeInterval(seconds), repeats: false) { [weak self] _ in
            self?.collapse()
        }
        RunLoop.main.add(timer, forMode: .common)
        rehideTimer = timer
    }

    /// Invalidates everything still pending and returns the new epoch.
    @discardableResult
    private func advance() -> Int {
        epoch += 1
        rehideTimer?.invalidate()
        rehideTimer = nil
        awaitedLaunches.removeAll()
        applyCancellation?.cancel()
        applyCancellation = nil
        return epoch
    }

    // MARK: - System events

    /// An icon registered while others are hidden parks off screen and never
    /// reaches the bar. So a launch lifts the restriction briefly, waits for
    /// the new icon and restores what it lifted: a collapsed bar collapses
    /// again, which also puts the icon on its side of the collapser, and an
    /// expanded one takes the never-shown icons back out.
    private func applicationLaunched(_ app: NSRunningApplication) {
        refreshManagers()
        guard let bundleID = app.bundleIdentifier, bundleID != ownBundleID else { return }
        let now = ProcessInfo.processInfo.systemUptime
        if !awaitedLaunches.isEmpty {
            // Already open for an earlier launch of the same burst.
            awaitedLaunches.insert(bundleID)
            launchRevealDeadline = min(now + Self.launchRevealWindow,
                                       launchRevealStarted + Self.launchRevealLimit)
            return
        }
        guard state == .collapsed || (state == .expanded && assertion.isActive) else { return }
        // An expanded bar does not change course: its auto re-hide timer
        // keeps running, and whatever advances the epoch ends the wait.
        let token = state == .collapsed ? advance() : epoch
        awaitedLaunches = [bundleID]
        launchRevealStarted = now
        launchRevealDeadline = now + Self.launchRevealWindow
        assertion.release()
        pollForLaunchedItems(token: token)
    }

    private func pollForLaunchedItems(token: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.launchPollInterval) { [weak self] in
            guard let self, self.epoch == token else { return }
            MenuBarAccessibilityInventory.walk { [weak self] items in
                guard let self, self.epoch == token else { return }
                let present = Set(items.map(\.identity.bundleID))
                let expired = ProcessInfo.processInfo.systemUptime >= self.launchRevealDeadline
                guard expired || self.awaitedLaunches.isSubset(of: present) else {
                    self.pollForLaunchedItems(token: token)
                    return
                }
                self.awaitedLaunches.removeAll()
                if self.state == .collapsed {
                    self.collapse(with: items, token: token)
                } else {
                    self.adopt(items)
                    self.restrictExpanded()
                }
            }
        }
    }

    /// Sleep can drop the restriction. The bar may still be restricted, so the
    /// boundary cannot be read again: the remembered set is asserted anew, and
    /// the old restriction is only released once the new one is live. An
    /// expanded bar gets its never-shown restriction back the same way.
    private func reassertAfterWake() {
        guard state == .collapsed || (state == .expanded && assertion.isActive),
              awaitedLaunches.isEmpty else { return }
        guard let allowed = allowlist(hiding: state == .collapsed ? hiddenBundles : []) else {
            expand()
            return
        }
        let token = epoch
        assertion.activate(bundles: allowed.bundles, systemItems: allowed.systemItems) { [weak self] failure in
            guard let self, self.epoch == token, let failure else { return }
            self.failOpen(.activationFailed(failure))
        }
    }

    private func accessibilityChanged(_ granted: Bool) {
        guard state != .off else { return }
        if !granted {
            // Without it the bar can be neither read nor trusted.
            if state == .collapsed || assertion.isActive {
                advance()
                failOpen(.accessibilityMissing)
            }
        } else if state == .expanded, problem == .accessibilityMissing {
            problem = nil
            collapseWhenQuiet()
        }
    }

    private func refreshManagers() {
        var names: [String] = []
        for app in NSWorkspace.shared.runningApplications {
            guard let bundleID = app.bundleIdentifier,
                  MenuBarManagerDetection.isKnownManager(bundleIdentifier: bundleID),
                  let name = app.localizedName, !names.contains(name) else { continue }
            names.append(name)
        }
        if runningManagers != names { runningManagers = names }
    }

    private func runningBundles() -> Set<String> {
        Set(NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier))
    }

    // MARK: - Reordering

    /// Stores the drawn never-shown list, drags the icons into the drawn
    /// order, then reports how many moves landed. Every icon is shown for the
    /// pass, because only an icon that is in the bar can be dragged, and the
    /// bar is restricted again afterwards. Never-shown icons are not part of
    /// the order; the planner leaves them at the left end.
    func apply(_ target: MenuBarLayout) {
        guard state == .expanded || state == .collapsed,
              let collapserIdentity = MenuBarOrganizerCollapser.identity else { return }
        guard AXIsProcessTrusted() else {
            problem = .accessibilityMissing
            return
        }
        let wasCollapsed = state == .collapsed
        let wasRestricted = assertion.isActive
        let token = advance()
        // Names come from the inventory, then from what was remembered.
        rememberNeverShown(MenuBarHiddenRecord.records(for: target.neverShown, items: inventory,
                                                       known: neverShown + lastHidden, ownBundleID: ownBundleID))
        assertion.release()
        state = .applying
        collapser.setCollapsed(false)
        lastApplyReport = nil

        let order = target.hidden + [collapserIdentity] + target.visible
        let cancellation = Cancellation()
        applyCancellation = cancellation
        Self.moverQueue.async { [weak self] in
            let report = Self.reorder(to: order, afterReveal: wasRestricted, cancellation: cancellation)
            DispatchQueue.main.async {
                guard let self, self.epoch == token, self.state == .applying else { return }
                self.applyCancellation = nil
                self.lastApplyReport = report
                self.state = .expanded
                if wasCollapsed {
                    self.walkAndCollapse(token: token)
                } else {
                    self.restrictExpanded()
                    self.refreshInventory()
                }
            }
        }
    }

    /// Lets a pass that is being abandoned stop between two drags.
    private final class Cancellation {
        private let lock = NSLock()
        private var cancelled = false
        var isCancelled: Bool { lock.withLock { cancelled } }
        func cancel() { lock.withLock { cancelled = true } }
    }

    /// The reorder pass, off the main thread. Every move is verified by a
    /// fresh walk and retried once, re-aimed at the frames as they sit then.
    private static func reorder(to target: [MenuBarItemIdentity], afterReveal: Bool,
                                cancellation: Cancellation) -> (moved: Int, failed: Int) {
        func movableItems() -> [MenuBarItemSnapshot] {
            MenuBarAccessibilityInventory.walkNow().filter(MenuBarOrganizerPolicy.isMovable)
        }
        if afterReveal { waitForReturningItems() }
        var items = movableItems()
        let bar = CGDisplayBounds(CGMainDisplayID())
        var moved = 0
        var failed = 0
        for move in MenuBarMovePlanner.plan(current: items.map(\.identity), target: target) {
            for _ in 0..<2 {
                let order = items.map(\.identity)
                guard !cancellation.isCancelled, !MenuBarMovePlanner.isSatisfied(move, in: order) else { break }
                let frames = Dictionary(items.map { ($0.identity, $0.frame) }, uniquingKeysWith: { first, _ in first })
                guard let frame = frames[move.item],
                      let drop = MenuBarMovePlanner.dropPoint(for: move, frames: frames, order: order) else { break }
                let aim = CGPoint(x: min(max(drop.x, bar.minX + 1), bar.maxX - 1), y: drop.y)
                MenuBarItemMover.commandDrag(from: CGPoint(x: frame.midX, y: frame.midY), to: aim)
                // The agent animates the reflow before the tree settles.
                Thread.sleep(forTimeInterval: 0.35)
                items = movableItems()
            }
            if MenuBarMovePlanner.isSatisfied(move, in: items.map(\.identity)) {
                moved += 1
            } else {
                failed += 1
            }
            if cancellation.isCancelled { break }
        }
        return (moved, failed)
    }

    /// Icons return one by one after the restriction lifts; a plan made from
    /// half a bar would be wrong.
    private static func waitForReturningItems() {
        var gate = MenuBarQuietGate()
        let deadline = ProcessInfo.processInfo.systemUptime + 2.5
        Thread.sleep(forTimeInterval: 0.3)
        while ProcessInfo.processInfo.systemUptime < deadline {
            let items = MenuBarAccessibilityInventory.walkNow()
            if !items.isEmpty, gate.observe(items.map(\.identity)) { return }
            Thread.sleep(forTimeInterval: 0.2)
        }
    }
}
