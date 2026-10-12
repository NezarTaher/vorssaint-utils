// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import CoreGraphics
import Foundation

enum MenuBarOrganizerTests {
    private static let own = "com.vorssaint.app"
    private static let chevron = MenuBarItemIdentity(bundleID: own, title: "VorssaintMenuBarOrganizer")

    private static func identity(_ bundle: String, _ title: String = "Item-0") -> MenuBarItemIdentity {
        MenuBarItemIdentity(bundleID: bundle, title: title)
    }

    private static func item(_ bundle: String, _ title: String = "Item-0", x: CGFloat,
                             width: CGFloat = 30, bundleless: Bool = false) -> MenuBarItemSnapshot {
        MenuBarItemSnapshot(identity: identity(bundle, title),
                            frame: CGRect(x: x, y: 0, width: width, height: 33),
                            pid: 100, appName: bundle, hostIsBundleless: bundleless)
    }

    /// A bar with two hideable apps and a helper left of the chevron, one app,
    /// Vorssaint's main icon and the battery right of it.
    private static let bar: [MenuBarItemSnapshot] = [
        item("com.example.alpha", x: 1000),
        item("com.example.helper", x: 1030, bundleless: true),
        item("com.example.beta", x: 1060),
        item(own, "VorssaintMenuBarOrganizer", x: 1090),
        item("com.example.gamma", x: 1120),
        item(own, "Vorssaint", x: 1150),
        item(MenuBarOrganizerPolicy.agentBundleID, "com.apple.menuextra.battery", x: 1180)
    ]

    static func run(_ suite: TestSuite) {
        identities(suite)
        availability(suite)
        partition(suite)
        allowlist(suite)
        movePlanner(suite)
        dropPoints(suite)
        quietGate(suite)
        hiddenRecords(suite)
        managers(suite)
    }

    private static func identities(_ suite: TestSuite) {
        let first = MenuBarItemIdentity.make(bundleID: "a", candidates: [nil, "", "  ", "ident", "desc"], taken: [])
        suite.expect(first.title == "ident", "the first non-empty Accessibility string names the item")
        let unnamed = MenuBarItemIdentity.make(bundleID: "a", candidates: [nil, ""], taken: [])
        suite.expect(unnamed.title == "Item-0", "an item without any string is Item-0")
        let second = MenuBarItemIdentity.make(bundleID: "a", candidates: [], taken: [unnamed])
        suite.expect(second.title == "Item-1", "a second unnamed item of one app stays distinct")
        let repeated = MenuBarItemIdentity.make(bundleID: "a", candidates: ["ident"], taken: [first])
        suite.expect(repeated != first && repeated.title == "ident-1", "a repeated title stays distinct")
        let other = MenuBarItemIdentity.make(bundleID: "b", candidates: ["ident"], taken: [first])
        suite.expect(other.title == "ident", "titles only collide within one bundle")
    }

    private static func availability(_ suite: TestSuite) {
        typealias Gate = MenuBarOrganizerAvailability
        suite.expect(Gate.unsupportedReason(majorVersion: 26, versionString: "26.4", bridgeAvailable: true)
                         == .requiresMacOS27(current: "26.4"),
                     "macOS 26 is refused with its own version, even if the API were there")
        suite.expect(Gate.unsupportedReason(majorVersion: 27, versionString: "27.2", bridgeAvailable: false)
                         == .apiMissing,
                     "macOS 27 without the private API reports the missing API")
        suite.expect(Gate.unsupportedReason(majorVersion: 27, versionString: "27.2", bridgeAvailable: true) == nil,
                     "macOS 27 with the API is supported")
        suite.expect(Gate.unsupportedReason(majorVersion: 28, versionString: "28.0", bridgeAvailable: true) == nil,
                     "later versions stay supported")
    }

    private static func partition(_ suite: TestSuite) {
        let layout = MenuBarOrganizerLayout.partition(bar.reversed(), chevron: chevron)
        suite.expect(layout?.hidden == [identity("com.example.alpha"), identity("com.example.helper"),
                                        identity("com.example.beta")],
                     "items left of the chevron are hidden, in visual order whatever the input order")
        suite.expect(layout?.visible == [identity("com.example.gamma"), identity(own, "Vorssaint"),
                                         identity(MenuBarOrganizerPolicy.agentBundleID, "com.apple.menuextra.battery")],
                     "items right of the chevron are visible and the chevron is on neither side")
        suite.expect(MenuBarOrganizerLayout.partition(bar.filter { $0.identity != chevron }, chevron: chevron) == nil,
                     "a missing chevron yields no layout")
        suite.expect(MenuBarOrganizerLayout.partition([], chevron: chevron) == nil,
                     "an empty walk yields no layout")
    }

    private static func allowlist(_ suite: TestSuite) {
        guard let layout = MenuBarOrganizerLayout.partition(bar, chevron: chevron) else {
            suite.expect(false, "the reference bar partitions")
            return
        }
        let hidden = MenuBarOrganizerLayout.hiddenBundles(in: layout, items: bar, ownBundleID: own)
        suite.expect(hidden == ["com.example.alpha", "com.example.beta"],
                     "only addressable hosts left of the chevron are hidden")

        let running: Set<String> = ["com.example.alpha", "com.example.gamma", "com.example.windowed"]
        let list = MenuBarOrganizerLayout.allowlist(hiddenBundles: hidden, observed: bar,
                                                    running: running, ownBundleID: own)
        suite.expect(list?.bundles == ["com.example.gamma", "com.example.helper", "com.example.windowed", own].sorted(),
                     "everything running or observed stays allowed except the hidden bundles")
        suite.expect(list?.systemItems == Array(0...8), "all nine system items stay allowed")

        // Vorssaint's own icon, a system item and a helper dragged left of the
        // chevron must not turn into hide requests.
        let unhideable = MenuBarLayout(hidden: [identity(own, "Vorssaint"), identity("com.example.helper"),
                                                identity(MenuBarOrganizerPolicy.agentBundleID, "com.apple.menuextra.battery")],
                                       visible: [])
        suite.expect(MenuBarOrganizerLayout.hiddenBundles(in: unhideable, items: bar, ownBundleID: own).isEmpty,
                     "own, system and bundleless items are never hidden")
        suite.expect(MenuBarOrganizerLayout.allowlist(hiddenBundles: [], observed: bar,
                                                      running: running, ownBundleID: own) == nil,
                     "nothing to hide means no assertion")
        suite.expect(MenuBarOrganizerLayout.allowlist(
                         hiddenBundles: [own, "com.example.helper", MenuBarOrganizerPolicy.agentBundleID],
                         observed: bar, running: running, ownBundleID: own) == nil,
                     "a request naming only protected bundles hides nothing")

        let everything = MenuBarOrganizerLayout.allowlist(hiddenBundles: ["com.example.alpha", own],
                                                          observed: [item("com.example.alpha", x: 0)],
                                                          running: [], ownBundleID: own)
        suite.expect(everything?.bundles == [own],
                     "the allowlist is never empty: the own bundle is always on it")
        suite.expect(MenuBarOrganizerLayout.allowlist(hiddenBundles: ["com.example.alpha"], observed: [],
                                                      running: [], ownBundleID: "") == nil,
                     "without an own bundle id there is nothing safe to allow")
    }

    private static func movePlanner(_ suite: TestSuite) {
        let a = identity("a"), b = identity("b"), c = identity("c"), d = identity("d"), e = identity("e")

        func check(_ current: [MenuBarItemIdentity], _ target: [MenuBarItemIdentity],
                   moves expected: Int, gives result: [MenuBarItemIdentity]? = nil, _ label: String) {
            let plan = MenuBarMovePlanner.plan(current: current, target: target)
            var order = current
            var landed = true
            for move in plan {
                order = MenuBarMovePlanner.applying(move, to: order)
                landed = landed && MenuBarMovePlanner.isSatisfied(move, in: order)
            }
            suite.expect(plan.count == expected, "\(label): \(plan.count) moves, expected \(expected)")
            suite.expect(order == (result ?? target), "\(label): the moves produce the target order")
            suite.expect(landed, "\(label): every move reads as landed right after it is applied")
        }

        check([a, b, c], [a, b, c], moves: 0, "unchanged order")
        check([a, b, c, d], [d, a, b, c], moves: 1, "one item to the left end")
        check([a, b, c, d], [b, c, d, a], moves: 1, "one item to the right end")
        check([a, b, c, d, e], [a, d, c, b, e], moves: 2, "swapping two items around a third")
        check([a, b, c, d], [d, c, b, a], moves: 3, "a full reversal keeps one item in place")
        check([a, b, c], [c, d, a, b], moves: 1, gives: [c, a, b], "a target item that is gone is skipped")
        check([e, a, b], [b, a], moves: 1, gives: [e, b, a], "an unmentioned item keeps the left end")

        suite.expect(MenuBarMovePlanner.plan(current: [a, b, c, d], target: [d, a, b, c])
                         == [MenuBarMove(item: d, after: nil)],
                     "a leftmost placement has no anchor")
        suite.expect(MenuBarMovePlanner.plan(current: [a, b, c, d], target: [a, c, d, b])
                         == [MenuBarMove(item: b, after: d)],
                     "the one displaced item moves, not the run it jumped")
        suite.expect(!MenuBarMovePlanner.isSatisfied(MenuBarMove(item: d, after: a), in: [a, b, d]),
                     "an item one slot off has not landed")
        suite.expect(!MenuBarMovePlanner.isSatisfied(MenuBarMove(item: e, after: nil), in: [a, b]),
                     "an item that vanished has not landed")
    }

    private static func dropPoints(_ suite: TestSuite) {
        let a = identity("a"), b = identity("b"), c = identity("c")
        let frames: [MenuBarItemIdentity: CGRect] = [
            a: CGRect(x: 100, y: 0, width: 30, height: 33),
            b: CGRect(x: 130, y: 0, width: 40, height: 33),
            c: CGRect(x: 170, y: 0, width: 20, height: 33)
        ]
        let order = [a, b, c]

        let between = MenuBarMovePlanner.dropPoint(for: MenuBarMove(item: c, after: a), frames: frames, order: order)
        suite.expect(between == CGPoint(x: 132.5, y: 16.5),
                     "between two items the drop lands halfway between their centers")
        let leftmost = MenuBarMovePlanner.dropPoint(for: MenuBarMove(item: c, after: nil), frames: frames, order: order)
        suite.expect(leftmost == CGPoint(x: 88, y: 16.5),
                     "a leftmost placement drops clear of the first item's left edge")
        let rightmost = MenuBarMovePlanner.dropPoint(for: MenuBarMove(item: a, after: c), frames: frames, order: order)
        suite.expect(rightmost == CGPoint(x: 207, y: 16.5),
                     "after the last item the drop lands clear of its right edge")
        let skipsSelf = MenuBarMovePlanner.dropPoint(for: MenuBarMove(item: b, after: a), frames: frames, order: order)
        suite.expect(skipsSelf == CGPoint(x: 147.5, y: 16.5),
                     "the dragged item is not its own right neighbour")
        suite.expect(MenuBarMovePlanner.dropPoint(for: MenuBarMove(item: c, after: a),
                                                  frames: frames.filter { $0.key != a }, order: order) == nil,
                     "a missing anchor frame yields no drop point")
        suite.expect(MenuBarMovePlanner.dropPoint(for: MenuBarMove(item: a, after: nil),
                                                  frames: [a: CGRect(x: 100, y: 0, width: 30, height: 33)],
                                                  order: [a]) == nil,
                     "a lone item has nowhere to go")
    }

    private static func quietGate(_ suite: TestSuite) {
        let a = identity("a"), b = identity("b")
        var gate = MenuBarQuietGate()
        suite.expect(!gate.observe([a]) && !gate.observe([a]), "two matching walks are not quiet yet")
        suite.expect(gate.observe([a]), "the third matching walk is quiet")
        var restless = MenuBarQuietGate()
        _ = restless.observe([a])
        _ = restless.observe([a])
        suite.expect(!restless.observe([a, b]) && !restless.observe([a, b]),
                     "a late icon restarts the count")
        suite.expect(restless.observe([a, b]), "and the bar is quiet three walks later")
    }

    private static func hiddenRecords(_ suite: TestSuite) {
        guard let layout = MenuBarOrganizerLayout.partition(bar, chevron: chevron) else {
            suite.expect(false, "the reference bar partitions")
            return
        }
        let records = MenuBarHiddenRecord.records(for: layout, items: bar, ownBundleID: own)
        suite.expect(records.map(\.identity) == [identity("com.example.alpha"), identity("com.example.beta")],
                     "only items that really hide are remembered")
        suite.expect(MenuBarHiddenRecord.decode(MenuBarHiddenRecord.encode(records)) == records,
                     "hidden records survive their stored form")
        suite.expect(MenuBarHiddenRecord.decode(Data("not json".utf8)).isEmpty && MenuBarHiddenRecord.decode(nil).isEmpty,
                     "unreadable stored records read as none")
    }

    private static func managers(_ suite: TestSuite) {
        for bundle in ["com.surteesstudios.Bartender", "com.surteesstudios.Bartender-setapp",
                       "com.jordanbaird.Ice", "com.dragonapp.ice", "com.dragonapp.ice.MenuBarItemService",
                       "com.stonerl.Thaw", "app.fif7y.Pelmet", "app.fif7y.Pelmet.items.hidden",
                       "com.dwarvesv.minimalbar", "com.mortennn.Dozer", "br.tec.sparrow.menubarhide"] {
            suite.expect(MenuBarManagerDetection.isKnownManager(bundleIdentifier: bundle),
                         "\(bundle) is a known menu bar manager")
        }
        for bundle in ["com.jordanbaird.IceCream", "com.apple.MenuBarAgent", "com.vorssaint.app", ""] {
            suite.expect(!MenuBarManagerDetection.isKnownManager(bundleIdentifier: bundle),
                         "\(bundle) is not a menu bar manager")
        }
    }
}
