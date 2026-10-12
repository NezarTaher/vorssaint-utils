// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

/// The Menu Bar Organizer page: the switch, a drawing of the bar split at the
/// chevron and the auto re-hide delay. The drawing is a local copy; the bar
/// only changes when it is applied.
struct MenuBarOrganizerSettings: View {
    private static let autoRehideChoices = [5, 10, 30, 60]

    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var permissions = Permissions.shared
    @ObservedObject private var service = MenuBarOrganizerService.shared
    @AppStorage(DefaultsKey.menuBarOrganizerEnabled) private var enabled = false
    @AppStorage(DefaultsKey.menuBarOrganizerAutoRehideSeconds) private var autoRehideSeconds = 0
    @State private var draft = MenuBarLayout(hidden: [], visible: [])

    private let ownBundleID = Bundle.main.bundleIdentifier ?? ""

    private var strings: MenuBarOrganizerFeatureStrings { FeatureStrings.menuBarOrganizer(l10n.language) }

    var body: some View {
        Form {
            Section(strings.title) {
                // Installing the feature turns the switch on; where hiding
                // cannot work it must not read as on.
                Toggle(strings.enable, isOn: service.isSupported ? $enabled : .constant(false))
                    .disabled(!service.isSupported)
                    .onChange(of: enabled) { _, value in
                        service.syncWithPreferences()
                        guard value, service.isSupported, !permissions.accessibility else { return }
                        permissions.requestAccessibility()
                        permissions.openAccessibilitySettings()
                    }
                if let unsupported = service.unsupportedReason {
                    warning(unsupportedText(unsupported))
                } else {
                    caption(strings.enableCaption)
                }
                ForEach(service.runningManagers, id: \.self) { manager in
                    warning(String(format: strings.otherManagerFormat, manager))
                }
                if let status {
                    caption(status)
                }
                if let problem = service.problem {
                    warning(problemText(problem))
                }
            }

            if enabled, service.isSupported, !permissions.accessibility {
                Section(l10n.s.permissionRequired) {
                    PermissionRow(kind: .accessibility)
                }
            }

            if service.state != .off {
                Group {
                    itemSection(strings.hiddenSection, items: draft.hidden, empty: strings.hiddenEmpty,
                                action: strings.showItem) { draft.hidden.move(fromOffsets: $0, toOffset: $1) }
                    itemSection(strings.visibleSection, items: draft.visible, empty: strings.visibleEmpty,
                                action: strings.hideItem) { draft.visible.move(fromOffsets: $0, toOffset: $1) }
                    applySection
                }
                .disabled(service.state == .applying)
            }

            Section {
                Picker(strings.autoRehide, selection: $autoRehideSeconds) {
                    Text(strings.autoRehideNever).tag(0)
                    ForEach(Self.autoRehideChoices, id: \.self) { seconds in
                        Text(String(format: strings.autoRehideSecondsFormat, seconds)).tag(seconds)
                    }
                }
                .disabled(!service.isSupported)
            }
        }
        .formStyle(.grouped)
        .onAppear {
            draft = baseline
            service.refreshInventory()
        }
        // A bar that changed under the drawing makes the drawing stale.
        .onChange(of: baseline) { _, value in draft = value }
    }

    // MARK: - Layout

    private func itemSection(_ title: String, items: [MenuBarItemIdentity], empty: String, action: String,
                             move: @escaping (IndexSet, Int) -> Void) -> some View {
        Section(title) {
            if items.isEmpty {
                Text(empty)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            } else {
                ForEach(items, id: \.self) { identity in
                    row(identity, action: action)
                }
                .onMove(perform: move)
            }
        }
    }

    private func row(_ identity: MenuBarItemIdentity, action: String) -> some View {
        let locked = lockReason(identity)
        return HStack(spacing: 8) {
            icon(identity)
                .frame(width: 18, height: 18)
            VStack(alignment: .leading, spacing: 1) {
                Text(name(identity))
                if let locked {
                    Text(locked)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if locked == nil {
                Button(action) {
                    draft = MenuBarOrganizerEditorSupport.movingAcross(identity, in: draft)
                }
                .buttonStyle(.borderless)
            }
        }
        .moveDisabled(locked != nil)
    }

    private var applySection: some View {
        Section {
            HStack(spacing: 8) {
                if service.state == .applying {
                    ProgressView()
                        .controlSize(.small)
                    Text(strings.applying)
                        .foregroundStyle(.secondary)
                } else {
                    Button(pendingMoves > 0
                           ? String(format: strings.applyPendingFormat, pendingMoves)
                           : strings.apply) {
                        service.apply(draft)
                    }
                    .disabled(pendingMoves == 0)
                    Button(strings.discard) { draft = baseline }
                        .disabled(draft == baseline)
                }
                Spacer()
                if let report = service.lastApplyReport {
                    Text(String(format: strings.applyReportFormat, report.moved, report.failed))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Button(strings.refresh) {
                    draft = baseline
                    service.refreshInventory()
                }
            }
            caption(strings.applyHint)
            caption(strings.dragHint)
            caption(strings.perAppNote)
            caption(strings.systemExtrasNote)
        }
    }

    /// The bar the drawing starts from and is compared with.
    private var baseline: MenuBarLayout {
        MenuBarOrganizerEditorSupport.baseline(layout: service.layout, lastHidden: service.lastHidden,
                                               collapsed: service.state == .collapsed)
    }

    private var pendingMoves: Int {
        guard let chevron = MenuBarOrganizerChevron.identity else { return 0 }
        return MenuBarOrganizerEditorSupport.pendingMoves(from: baseline, to: draft, chevron: chevron)
    }

    // MARK: - Rows

    private func snapshot(_ identity: MenuBarItemIdentity) -> MenuBarItemSnapshot? {
        service.inventory.first { $0.identity == identity }
    }

    /// Why a row cannot be hidden or moved here, nil when it can.
    private func lockReason(_ identity: MenuBarItemIdentity) -> String? {
        if identity.bundleID == MenuBarOrganizerPolicy.agentBundleID { return strings.lockedSystem }
        if identity.bundleID == ownBundleID { return strings.lockedOwn }
        // Only items that hide are remembered, so one without a snapshot does.
        guard let item = snapshot(identity),
              !MenuBarOrganizerPolicy.canHide(item, ownBundleID: ownBundleID) else { return nil }
        return strings.lockedHelper
    }

    private func name(_ identity: MenuBarItemIdentity) -> String {
        let appName = snapshot(identity)?.appName
            ?? service.lastHidden.first { $0.identity == identity }?.appName
            ?? identity.title
        // Several icons of one app are told apart by their own names.
        let siblings = (draft.hidden + draft.visible).filter { $0.bundleID == identity.bundleID }.count
        return siblings > 1 && appName != identity.title ? "\(appName) (\(identity.title))" : appName
    }

    @ViewBuilder
    private func icon(_ identity: MenuBarItemIdentity) -> some View {
        if identity.bundleID != MenuBarOrganizerPolicy.agentBundleID, let url = bundleURL(identity) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                .resizable()
        } else {
            Image(systemName: "menubar.rectangle")
                .foregroundStyle(.secondary)
        }
    }

    private func bundleURL(_ identity: MenuBarItemIdentity) -> URL? {
        snapshot(identity).flatMap { NSRunningApplication(processIdentifier: $0.pid)?.bundleURL }
            ?? NSWorkspace.shared.urlForApplication(withBundleIdentifier: identity.bundleID)
    }

    // MARK: - Texts

    private var status: String? {
        switch service.state {
        case .off: return nil
        case .expanded: return strings.statusExpanded
        case .collapsed: return strings.statusCollapsed
        case .applying: return strings.applying
        }
    }

    private func unsupportedText(_ reason: MenuBarOrganizerAvailability.Unsupported) -> String {
        switch reason {
        case .requiresMacOS27(let current): return String(format: strings.unsupportedOSFormat, current)
        case .apiMissing: return strings.unsupportedAPI
        }
    }

    private func problemText(_ problem: MenuBarOrganizerService.Problem) -> String {
        switch problem {
        case .accessibilityMissing: return strings.problemAccessibility
        case .chevronNotFound: return strings.problemChevronNotFound
        case .activationFailed(let reason): return String(format: strings.problemActivationFormat, reason)
        case .nothingToHide: return strings.problemNothingToHide
        }
    }

    private func warning(_ text: String) -> some View {
        Label(text, systemImage: "exclamationmark.triangle.fill")
            .font(.caption)
            .foregroundStyle(.orange)
    }

    private func caption(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}
