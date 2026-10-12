// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import CoreGraphics
import Foundation

/// Moves a menu bar item the only way macOS 27 honours: the ⌘-drag a person
/// would make, posted at HID level. The agent animates the move and remembers
/// the position by itself.
///
/// Blocking, and never to be called on the main thread: when the dragged item
/// is Vorssaint's own, AppKit tracks the drag on the main run loop, and
/// posting from there would interleave with that tracking and lose the drop.
enum MenuBarItemMover {
    /// Marks the events posted here, so the shield lets them through and
    /// swallows only what the physical mouse produces. "VSMB".
    static let syntheticTag: Int64 = 0x5653_4D42

    private static let quietGap: TimeInterval = 0.25
    private static let quietWaitLimit: TimeInterval = 1.5
    private static let grabHold: TimeInterval = 0.18
    private static let stepInterval: TimeInterval = 0.03
    private static let maximumStep: CGFloat = 40
    private static let releaseHold: TimeInterval = 0.12

    /// ⌘-drags from one bar point to another (CG global coordinates, top-left
    /// origin, the space Accessibility frames use). The pointer is borrowed
    /// for well under a second and put back where it was.
    static func commandDrag(from start: CGPoint, to end: CGPoint) {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }
        source.userData = syntheticTag
        let home = CGEvent(source: nil)?.location

        // Do not pull the pointer out of a hand in motion. If it never rests,
        // the shield still keeps the drag on its path.
        waitForQuietPointer()

        let shield = DragShield()
        shield.activate()
        defer { shield.deactivate() }

        func post(_ type: CGEventType, at point: CGPoint) {
            guard let event = CGEvent(mouseEventSource: source, mouseType: type,
                                      mouseCursorPosition: point, mouseButton: .left) else { return }
            event.flags = .maskCommand
            event.post(tap: .cghidEventTap)
            // The ⌘-click hands the front to the item's owner, and macOS
            // resets the cursor state on that change.
            shield.reassert()
        }

        post(.leftMouseDown, at: start)
        // A drag that leaves at once is not taken as a deliberate grab.
        Thread.sleep(forTimeInterval: grabHold)
        // A single jump is ignored, and long jumps make the agent lose track
        // of the slots the item crosses.
        let distance = hypot(end.x - start.x, end.y - start.y)
        let steps = max(6, Int((distance / maximumStep).rounded(.up)))
        for step in 1...steps {
            let progress = CGFloat(step) / CGFloat(steps)
            post(.leftMouseDragged, at: CGPoint(x: start.x + (end.x - start.x) * progress,
                                                y: start.y + (end.y - start.y) * progress))
            Thread.sleep(forTimeInterval: stepInterval)
        }
        Thread.sleep(forTimeInterval: releaseHold)
        post(.leftMouseUp, at: end)

        // Back home while the shield still hides the cursor.
        if let home {
            Thread.sleep(forTimeInterval: 0.06)
            CGWarpMouseCursorPosition(home)
        }
    }

    private static func waitForQuietPointer() {
        let types: [CGEventType] = [.mouseMoved, .leftMouseDown, .leftMouseUp, .leftMouseDragged,
                                    .rightMouseDown, .rightMouseUp, .scrollWheel]
        let deadline = ProcessInfo.processInfo.systemUptime + quietWaitLimit
        while ProcessInfo.processInfo.systemUptime < deadline {
            let idle = types.map { CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: $0) }.min()
            if (idle ?? .infinity) >= quietGap { return }
            Thread.sleep(forTimeInterval: 0.05)
        }
    }
}

/// Keeps the physical mouse out of one synthetic drag. Physical input shares
/// the HID stream with the posted events: a nudge would pull the drag off its
/// path, a click would land in the menu bar, a button release would end the
/// drag early. Three layers, all undone by `deactivate`, and all connection
/// state that the window server resets if the process dies mid-drag:
///
/// 1. Mouse and cursor are dissociated, so moving the mouse moves nothing.
/// 2. An active event tap swallows physical mouse events. It runs on a thread
///    of its own because the main run loop is busy tracking the drag when the
///    item is Vorssaint's, and a starved tap is switched off by the system.
/// 3. The cursor is hidden so it does not visibly fly across the bar.
private final class DragShield {
    private var tap: CFMachPort?
    private var tapSource: CFRunLoopSource?
    private var tapRunLoop: CFRunLoop?
    private let armed = DispatchSemaphore(value: 0)
    private var active = false
    /// Hiding the cursor is counted; every hide is balanced on the way out.
    private var hides = 0

    func activate() {
        guard !active else { return }
        active = true
        reassert()
        startTap()
    }

    /// macOS restores association and cursor whenever the frontmost app
    /// changes, which the drag itself causes, so both are set again after
    /// every posted event.
    func reassert() {
        guard active else { return }
        CGAssociateMouseAndMouseCursorPosition(0)
        if CGDisplayHideCursor(CGMainDisplayID()) == .success { hides += 1 }
    }

    /// The only way out, also after a failed drag: a tap left alive or a
    /// mouse left dissociated would freeze the pointer for good.
    func deactivate() {
        guard active else { return }
        active = false
        if let tap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        if let tapRunLoop {
            if let tapSource { CFRunLoopRemoveSource(tapRunLoop, tapSource, .commonModes) }
            CFRunLoopStop(tapRunLoop)
        }
        tap = nil
        tapSource = nil
        tapRunLoop = nil
        while hides > 0 {
            CGDisplayShowCursor(CGMainDisplayID())
            hides -= 1
        }
        CGAssociateMouseAndMouseCursorPosition(1)
    }

    private func startTap() {
        let types: [CGEventType] = [.mouseMoved, .leftMouseDown, .leftMouseUp, .leftMouseDragged,
                                    .rightMouseDown, .rightMouseUp, .rightMouseDragged,
                                    .otherMouseDown, .otherMouseUp, .otherMouseDragged, .scrollWheel]
        let mask = types.reduce(CGEventMask(0)) { $0 | (CGEventMask(1) << $1.rawValue) }
        // Without the tap (Accessibility just revoked) the shield degrades to
        // the other two layers: the path stays put, stray clicks are not caught.
        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap, place: .headInsertEventTap, options: .defaultTap,
            eventsOfInterest: mask,
            callback: { _, type, event, _ in
                // The disable notices are not mouse events and must pass.
                if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                    return Unmanaged.passUnretained(event)
                }
                if event.getIntegerValueField(.eventSourceUserData) == MenuBarItemMover.syntheticTag {
                    return Unmanaged.passUnretained(event)
                }
                return nil
            },
            userInfo: nil)
        else { return }
        self.tap = tap
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        tapSource = source
        let thread = Thread { [self] in
            let runLoop = CFRunLoopGetCurrent()
            tapRunLoop = runLoop
            CFRunLoopAddSource(runLoop, source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            armed.signal()
            CFRunLoopRun()
        }
        thread.name = "com.vorssaint.menu-bar-organizer.shield"
        thread.qualityOfService = .userInteractive
        thread.start()
        // Nothing is posted before the tap is live, and `deactivate` must find
        // the run loop it has to stop. A thread always starts; the wait is brief.
        armed.wait()
    }
}
