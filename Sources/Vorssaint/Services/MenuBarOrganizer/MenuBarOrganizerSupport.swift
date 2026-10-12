// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import CoreGraphics
import Foundation

// The pure half of the Menu Bar Organizer: everything that can be decided from
// an inventory without touching Accessibility, AppKit or the private API.

/// Stable identity of one menu bar item: owning bundle + a title picked from
/// AX title / identifier / description, "Item-0" when all are empty.
struct MenuBarItemIdentity: Hashable, Codable {
    let bundleID: String
    let title: String

    /// Identity for an item whose Accessibility strings are `candidates`, in
    /// order of preference. Two items of one app that would share a title get
    /// a numeric suffix, so an identity always names exactly one item of a walk.
    static func make(bundleID: String, candidates: [String?],
                     taken: Set<MenuBarItemIdentity>) -> MenuBarItemIdentity {
        let named = candidates.lazy
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
        if let named {
            let plain = MenuBarItemIdentity(bundleID: bundleID, title: named)
            if !taken.contains(plain) { return plain }
        }
        // Unnamed items count from zero; a repeated name counts from one, the
        // unnumbered one being the first.
        var index = named == nil ? 0 : 1
        while true {
            let candidate = MenuBarItemIdentity(bundleID: bundleID, title: "\(named ?? "Item")-\(index)")
            if !taken.contains(candidate) { return candidate }
            index += 1
        }
    }
}

struct MenuBarItemSnapshot: Equatable {
    let identity: MenuBarItemIdentity
    /// CG global coordinates, top-left origin, main display.
    let frame: CGRect
    let pid: pid_t
    let appName: String?
    /// The host process has no LaunchServices bundle id of its own, so the
    /// allowlist cannot address it and the item cannot be hidden.
    let hostIsBundleless: Bool

    var isSystem: Bool { identity.bundleID == MenuBarOrganizerPolicy.agentBundleID }
}

enum MenuBarOrganizerAvailability {
    enum Unsupported: Equatable {
        case requiresMacOS27(current: String)
        case apiMissing
    }

    /// Why hiding cannot work on this Mac, or nil when it can. The version is
    /// judged first: below macOS 27 the private API is never even looked up.
    static func unsupportedReason(majorVersion: Int, versionString: String,
                                  bridgeAvailable: Bool) -> Unsupported? {
        guard majorVersion >= 27 else { return .requiresMacOS27(current: versionString) }
        return bridgeAvailable ? nil : .apiMissing
    }
}

enum MenuBarOrganizerPolicy {
    static let agentBundleID = "com.apple.MenuBarAgent"
    /// Battery, Bluetooth, clock, displays, input, sound, Wi-Fi, screen
    /// mirroring and Control Center. All of them stay allowed.
    static let allSystemItems: [Int] = Array(0...8)

    /// The allowlist works per bundle id, so an item can only be hidden when
    /// its host has one, and Vorssaint's own bundle must stay because the
    /// collapser lives in it.
    static func canHide(_ item: MenuBarItemSnapshot, ownBundleID: String) -> Bool {
        !item.isSystem && !item.hostIsBundleless
            && !item.identity.bundleID.isEmpty && item.identity.bundleID != ownBundleID
    }

    static func isMovable(_ item: MenuBarItemSnapshot) -> Bool { !item.isSystem }
}

/// The icon of the collapser, the organizer's own status item.
enum MenuBarOrganizerIcon: String, CaseIterable {
    case chevron, dots, lines, grid

    /// SF Symbol for the state. Only the chevron changes with the state: it
    /// points at the hidden icons while they are hidden.
    func symbol(collapsed: Bool) -> String {
        switch self {
        case .chevron: return collapsed ? "chevron.left" : "chevron.right"
        case .dots: return "ellipsis"
        case .lines: return "line.3.horizontal"
        case .grid: return "circle.grid.2x2"
        }
    }

    /// The icon a stored preference names, the chevron when it names none.
    static func stored(_ raw: String?) -> MenuBarOrganizerIcon {
        raw.flatMap(MenuBarOrganizerIcon.init(rawValue:)) ?? .chevron
    }
}

/// Items left of the collapser are hidden, right of it visible, in visual
/// order. Never-shown items have no place in the bar; theirs is the order of
/// the editor.
struct MenuBarLayout: Equatable {
    var hidden: [MenuBarItemIdentity]
    var visible: [MenuBarItemIdentity]
    var neverShown: [MenuBarItemIdentity] = []
}

enum MenuBarOrganizerLayout {
    /// Splits an inventory at the collapser. Purely positional: items that can
    /// never be hidden still land on the side they sit on. nil when the
    /// collapser is not in the inventory (fail open).
    static func partition(_ items: [MenuBarItemSnapshot], collapser: MenuBarItemIdentity) -> MenuBarLayout? {
        let ordered = items.sorted { $0.frame.minX < $1.frame.minX }.map(\.identity)
        guard let boundary = ordered.firstIndex(of: collapser) else { return nil }
        return MenuBarLayout(hidden: Array(ordered[..<boundary]),
                             visible: Array(ordered[(boundary + 1)...]))
    }

    /// Bundles the assertion should hide for a layout: the hosts of the hidden
    /// items that can be hidden at all.
    static func hiddenBundles(in layout: MenuBarLayout, items: [MenuBarItemSnapshot],
                              ownBundleID: String) -> Set<String> {
        let hidden = Set(layout.hidden)
        return Set(items.lazy
            .filter { hidden.contains($0.identity) && MenuBarOrganizerPolicy.canHide($0, ownBundleID: ownBundleID) }
            .map(\.identity.bundleID))
    }

    /// Bundles the assertion keeps out of the bar even while it is expanded.
    /// A never-shown item is gone from Accessibility, so one the inventory
    /// lacks counts when it is among the `known` records, which only ever
    /// hold items that can be hidden.
    static func neverShownBundles(in layout: MenuBarLayout, items: [MenuBarItemSnapshot],
                                  known: [MenuBarHiddenRecord], ownBundleID: String) -> Set<String> {
        Set(MenuBarHiddenRecord.records(for: layout.neverShown, items: items, known: known,
                                        ownBundleID: ownBundleID).map(\.identity.bundleID))
    }

    /// Allowlist for the assertion: everything but the hidden and the
    /// never-shown bundles. `nil` when neither names anything that can be
    /// hidden (drop the assertion instead). Every running app stays allowed,
    /// not only the ones seen in the bar: an extra allowed bundle costs
    /// nothing, and a missing one would swallow an icon nobody asked to hide.
    static func allowlist(hiddenBundles: Set<String>, neverShownBundles: Set<String>,
                          observed: [MenuBarItemSnapshot], running: Set<String>,
                          ownBundleID: String) -> (bundles: [String], systemItems: [Int])? {
        let protected = Set(observed.lazy.filter(\.hostIsBundleless).map(\.identity.bundleID))
            .union([ownBundleID, MenuBarOrganizerPolicy.agentBundleID, ""])
        let hidden = hiddenBundles.union(neverShownBundles).subtracting(protected)
        guard !hidden.isEmpty, !ownBundleID.isEmpty else { return nil }
        let allowed = running
            .union(observed.lazy.filter { !$0.isSystem }.map(\.identity.bundleID))
            .union([ownBundleID])
            .subtracting(hidden)
            .subtracting([""])
        return (allowed.sorted(), MenuBarOrganizerPolicy.allSystemItems)
    }
}

/// One ⌘-drag: put `item` immediately after `after` (nil = leftmost of the movable run).
struct MenuBarMove: Equatable {
    let item: MenuBarItemIdentity
    let after: MenuBarItemIdentity?
}

enum MenuBarMovePlanner {
    /// Minimal drags turning `current` into `target` (both left→right, movable
    /// items only). Items of `target` that are gone are skipped, and items the
    /// target does not mention keep the left end, where macOS puts newcomers.
    /// The moves are meant to be performed in order.
    static func plan(current: [MenuBarItemIdentity], target: [MenuBarItemIdentity]) -> [MenuBarMove] {
        let goal = resolvedTarget(current: current, target: target)
        let rank = Dictionary(goal.enumerated().map { ($1, $0) }, uniquingKeysWith: { first, _ in first })
        // The longest run already in the right relative order stays put;
        // everything else needs exactly one drag.
        let settled = longestIncreasingRun(current.compactMap { rank[$0] })
        var moves: [MenuBarMove] = []
        for (index, item) in goal.enumerated() where !settled.contains(index) {
            moves.append(MenuBarMove(item: item, after: index == 0 ? nil : goal[index - 1]))
        }
        return moves
    }

    /// The order a move produces, used to tell whether a drag landed.
    static func applying(_ move: MenuBarMove, to order: [MenuBarItemIdentity]) -> [MenuBarItemIdentity] {
        var result = order.filter { $0 != move.item }
        guard result.count < order.count else { return order }
        guard let after = move.after else {
            result.insert(move.item, at: 0)
            return result
        }
        guard let anchor = result.firstIndex(of: after) else { return order }
        result.insert(move.item, at: anchor + 1)
        return result
    }

    static func isSatisfied(_ move: MenuBarMove, in order: [MenuBarItemIdentity]) -> Bool {
        guard let position = order.firstIndex(of: move.item) else { return false }
        guard let after = move.after else { return position == 0 }
        return position > 0 && order[position - 1] == after
    }

    /// Drop point for a move given fresh frames: halfway between the centers
    /// of `after` and its right neighbour, just right of `after` when it is the
    /// last one, or just left of the leftmost item. nil when a frame is missing.
    static func dropPoint(for move: MenuBarMove, frames: [MenuBarItemIdentity: CGRect],
                          order: [MenuBarItemIdentity]) -> CGPoint? {
        guard let own = frames[move.item] else { return nil }
        let others = order.filter { $0 != move.item }
        // The dragged item is held by its center, so half its width keeps it
        // clear of the neighbour it must not cross.
        let clearance = own.width / 2 + 2
        guard let after = move.after else {
            guard let first = others.first, let frame = frames[first] else { return nil }
            return CGPoint(x: frame.minX - clearance, y: own.midY)
        }
        guard let anchor = others.firstIndex(of: after), let left = frames[after] else { return nil }
        guard anchor + 1 < others.count else {
            return CGPoint(x: left.maxX + clearance, y: own.midY)
        }
        guard let right = frames[others[anchor + 1]] else { return nil }
        return CGPoint(x: (left.midX + right.midX) / 2, y: own.midY)
    }

    private static func resolvedTarget(current: [MenuBarItemIdentity],
                                       target: [MenuBarItemIdentity]) -> [MenuBarItemIdentity] {
        let present = Set(current)
        var seen = Set<MenuBarItemIdentity>()
        let wanted = target.filter { present.contains($0) && seen.insert($0).inserted }
        return current.filter { !seen.contains($0) } + wanted
    }

    /// Values of one longest strictly increasing subsequence.
    private static func longestIncreasingRun(_ values: [Int]) -> Set<Int> {
        guard !values.isEmpty else { return [] }
        var length = [Int](repeating: 1, count: values.count)
        var previous = [Int?](repeating: nil, count: values.count)
        for index in values.indices {
            for earlier in 0..<index where values[earlier] < values[index] && length[earlier] + 1 > length[index] {
                length[index] = length[earlier] + 1
                previous[index] = earlier
            }
        }
        var cursor = length.indices.max { length[$0] < length[$1] }
        var run = Set<Int>()
        while let index = cursor {
            run.insert(values[index])
            cursor = previous[index]
        }
        return run
    }
}

/// Decides when the menu bar has stopped changing after launch: the same
/// inventory on enough consecutive walks. Login items keep adding icons for a
/// while, and collapsing early would freeze a boundary they have yet to cross.
struct MenuBarQuietGate {
    static let requiredMatches = 3
    private var last: [MenuBarItemIdentity]?
    private var matches = 0

    /// Feeds one walk; true once the bar counts as quiet.
    mutating func observe(_ inventory: [MenuBarItemIdentity]) -> Bool {
        matches = inventory == last ? matches + 1 : 1
        last = inventory
        return matches >= Self.requiredMatches
    }
}

/// A hidden or never-shown item as it is remembered across the time it is
/// gone from Accessibility, so the editor can still name it.
struct MenuBarHiddenRecord: Codable, Equatable {
    let identity: MenuBarItemIdentity
    let appName: String?

    static func records(for layout: MenuBarLayout, items: [MenuBarItemSnapshot],
                        ownBundleID: String) -> [MenuBarHiddenRecord] {
        let byIdentity = Dictionary(items.map { ($0.identity, $0) }, uniquingKeysWith: { first, _ in first })
        return layout.hidden.compactMap { identity in
            guard let item = byIdentity[identity],
                  MenuBarOrganizerPolicy.canHide(item, ownBundleID: ownBundleID) else { return nil }
            return MenuBarHiddenRecord(identity: identity, appName: item.appName)
        }
    }

    /// Records for the given identities, in their order. An item in the
    /// inventory must be hideable; one the inventory lacks is taken over from
    /// the `known` records, and dropped when there is none.
    static func records(for identities: [MenuBarItemIdentity], items: [MenuBarItemSnapshot],
                        known: [MenuBarHiddenRecord], ownBundleID: String) -> [MenuBarHiddenRecord] {
        let byIdentity = Dictionary(items.map { ($0.identity, $0) }, uniquingKeysWith: { first, _ in first })
        return identities.compactMap { identity in
            guard let item = byIdentity[identity] else { return known.first { $0.identity == identity } }
            guard MenuBarOrganizerPolicy.canHide(item, ownBundleID: ownBundleID) else { return nil }
            return MenuBarHiddenRecord(identity: identity, appName: item.appName)
        }
    }

    static func encode(_ records: [MenuBarHiddenRecord]) -> Data? {
        try? JSONEncoder().encode(records)
    }

    static func decode(_ data: Data?) -> [MenuBarHiddenRecord] {
        guard let data else { return [] }
        return (try? JSONDecoder().decode([MenuBarHiddenRecord].self, from: data)) ?? []
    }
}

/// The drawing behind the layout editor in Settings. Nothing moves in the bar
/// until the drawing is applied, so it is compared with the bar it started from.
enum MenuBarOrganizerEditorSupport {
    enum Tier: CaseIterable {
        /// Right of the collapser, always in the bar.
        case show
        /// Left of the collapser, in the bar only while it is expanded.
        case hide
        /// Not in the bar at all.
        case never
    }

    static func tier(of identity: MenuBarItemIdentity, in layout: MenuBarLayout) -> Tier? {
        if layout.visible.contains(identity) { return .show }
        if layout.hidden.contains(identity) { return .hide }
        return layout.neverShown.contains(identity) ? .never : nil
    }

    /// The layout the editor starts from. While icons are hidden the bar
    /// cannot be read, so remembered hidden items the last partition does not
    /// know (a relaunch) join the hidden side. Never-shown items are always
    /// drawn from memory. A walk of a bar that was open for a moment may have
    /// seen their apps on either side; they are hidden all the same, so every
    /// icon of such an app is drawn as never shown.
    static func baseline(layout: MenuBarLayout?, lastHidden: [MenuBarHiddenRecord],
                         neverShown: [MenuBarHiddenRecord], collapsed: Bool) -> MenuBarLayout {
        var baseline = layout ?? MenuBarLayout(hidden: [], visible: [])
        if collapsed {
            let known = Set(baseline.hidden + baseline.visible)
            baseline.hidden += lastHidden.map(\.identity).filter { !known.contains($0) }
        }
        let remembered = neverShown.map(\.identity)
        let bundles = Set(remembered.map(\.bundleID))
        let seen = (baseline.hidden + baseline.visible).filter { bundles.contains($0.bundleID) }
        baseline.hidden.removeAll { bundles.contains($0.bundleID) }
        baseline.visible.removeAll { bundles.contains($0.bundleID) }
        baseline.neverShown = remembered + seen.filter { !remembered.contains($0) }
        return baseline
    }

    /// Moves an item into `tier`, in front of `target` or to the end of the
    /// tier without one. The one function behind drag and drop and the row
    /// menu. Never show works per app, so a move into or out of it takes
    /// every icon of the app along, and an item that `isLocked` never goes
    /// there. Within one list an item dragged down lands behind the row it
    /// reached, as it does when rows part under a drag.
    static func moving(_ identity: MenuBarItemIdentity, to tier: Tier, before target: MenuBarItemIdentity?,
                       in layout: MenuBarLayout, isLocked: (MenuBarItemIdentity) -> Bool) -> MenuBarLayout {
        guard identity != target, let source = Self.tier(of: identity, in: layout),
              !(tier == .never && isLocked(identity)) else { return layout }
        var moved = [identity]
        if source != tier, source == .never || tier == .never {
            moved = (layout.hidden + layout.visible + layout.neverShown).filter {
                $0.bundleID == identity.bundleID && !(tier == .never && isLocked($0))
            }
        }
        let path: WritableKeyPath<MenuBarLayout, [MenuBarItemIdentity]>
        switch tier {
        case .show: path = \.visible
        case .hide: path = \.hidden
        case .never: path = \.neverShown
        }
        let list = layout[keyPath: path]
        let draggedDown = source == tier
            && (target.flatMap(list.firstIndex(of:)) ?? 0) > (list.firstIndex(of: identity) ?? 0)

        var result = layout
        result.hidden.removeAll(where: moved.contains)
        result.visible.removeAll(where: moved.contains)
        result.neverShown.removeAll(where: moved.contains)
        let anchor = target.flatMap(result[keyPath: path].firstIndex(of:))
        result[keyPath: path].insert(contentsOf: moved,
                                     at: anchor.map { draggedDown ? $0 + 1 : $0 } ?? result[keyPath: path].count)
        return result
    }

    /// How many steps applying `draft` to a bar laid out as `baseline` takes:
    /// one per drag, and one for a changed set of never-shown items, which
    /// needs an apply of its own. System items are left out, as they are when
    /// the drags are planned.
    static func pendingMoves(from baseline: MenuBarLayout, to draft: MenuBarLayout,
                             collapser: MenuBarItemIdentity) -> Int {
        let current = (baseline.hidden + [collapser] + baseline.visible)
            .filter { $0.bundleID != MenuBarOrganizerPolicy.agentBundleID }
        let drags = MenuBarMovePlanner.plan(current: current,
                                            target: draft.hidden + [collapser] + draft.visible).count
        return drags + (Set(baseline.neverShown) == Set(draft.neverShown) ? 0 : 1)
    }
}

enum MenuBarManagerDetection {
    /// Bartender (incl. Setapp), Ice, Ice 2, Thaw, Pelmet, Hidden Bar, Dozer
    /// and MenubarHide. Prefixes, so helper and variant bundles match too.
    private static let prefixes = [
        "com.surteesstudios.bartender",
        "com.jordanbaird.ice",
        "com.dragonapp.ice",
        "com.stonerl.thaw",
        "app.fif7y.pelmet",
        "com.dwarvesv.minimalbar",
        "com.mortennn.dozer",
        "br.tec.sparrow.menubarhide"
    ]

    static func isKnownManager(bundleIdentifier: String) -> Bool {
        let lowered = bundleIdentifier.lowercased()
        return prefixes.contains { lowered == $0 || lowered.hasPrefix($0 + ".") || lowered.hasPrefix($0 + "-") }
    }
}
