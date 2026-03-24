/*
 * Exhaustive-style coverage of the cmd-cmd state machine (mirrored from
 * `Recognizer.swift`). No `EventTap` required.
 */

import XCTest
import AppKit

final class RecognizerStateMachineTests: XCTestCase {

    private var xorBit: UInt { 0b100000000 }

    /// `r` such that `r ^ xorBit` equals `target`.
    private func flagsRaw(forScrubbed target: UInt) -> UInt {
        target ^ xorBit
    }

    func testScrubProducesEmptyMask() {
        let f = NSEvent.ModifierFlags(rawValue: flagsRaw(forScrubbed: 0))
        XCTAssertEqual(RecognizerStateMirrorTransitions.scrub(f), 0)
    }

    func testFlagsChangedCommandDownGoesPressedOnceFromPossible() {
        let raw = flagsRaw(forScrubbed: RecognizerStateMirrorTransitions.leftCommandKeyMask)
        let flags = NSEvent.ModifierFlags(rawValue: raw).union(.command)
        let next = RecognizerStateMirrorTransitions.afterFlagsChanged(
            state: .possible,
            modifierFlags: flags
        )
        XCTAssertEqual(next, .pressedCommandOnce)
    }

    func testFlagsChangedEmptyPreservesState() {
        let raw = flagsRaw(forScrubbed: 0)
        let flags = NSEvent.ModifierFlags(rawValue: raw)
        XCTAssertEqual(
            RecognizerStateMirrorTransitions.afterFlagsChanged(state: .rejected, modifierFlags: flags),
            .rejected
        )
    }

    func testFlagsChangedOtherResetsToPossible() {
        let raw = flagsRaw(forScrubbed: 0b111)
        let flags = NSEvent.ModifierFlags(rawValue: raw)
        XCTAssertEqual(
            RecognizerStateMirrorTransitions.afterFlagsChanged(state: .pressedCommandTwice, modifierFlags: flags),
            .possible
        )
    }

    func testKeysPressedHappyPathToRecognized() {
        let empty = NSEvent.ModifierFlags(rawValue: flagsRaw(forScrubbed: 0))
        let cmdRaw = flagsRaw(forScrubbed: RecognizerStateMirrorTransitions.rightCommandKeyMask)
        let cmdOn = NSEvent.ModifierFlags(rawValue: cmdRaw).union(.command)

        var s = RecognizerStateMirror.possible
        s = RecognizerStateMirrorTransitions.afterFlagsChanged(state: s, modifierFlags: cmdOn)
        XCTAssertEqual(s, .pressedCommandOnce)

        s = RecognizerStateMirrorTransitions.afterKeysPressed(
            state: s, eventType: .flagsChanged, modifierFlags: empty
        )
        XCTAssertEqual(s, .releasedCommandOnce)

        s = RecognizerStateMirrorTransitions.afterKeysPressed(
            state: s, eventType: .flagsChanged, modifierFlags: cmdOn
        )
        XCTAssertEqual(s, .pressedCommandTwice)

        s = RecognizerStateMirrorTransitions.afterKeysPressed(
            state: s, eventType: .flagsChanged, modifierFlags: empty
        )
        XCTAssertEqual(s, .recognized)
    }

    func testPressedCommandOnceNonFlagsChangeRejects() {
        let s = RecognizerStateMirror.pressedCommandOnce
        let empty = NSEvent.ModifierFlags(rawValue: flagsRaw(forScrubbed: 0))
        let next = RecognizerStateMirrorTransitions.afterKeysPressed(
            state: s, eventType: .keyDown, modifierFlags: empty
        )
        XCTAssertEqual(next, .rejected)
    }

    func testReleasedCommandOnceWrongFlagsRejects() {
        let s = RecognizerStateMirror.releasedCommandOnce
        let wrong = NSEvent.ModifierFlags(rawValue: flagsRaw(forScrubbed: 99))
        let next = RecognizerStateMirrorTransitions.afterKeysPressed(
            state: s, eventType: .flagsChanged, modifierFlags: wrong
        )
        XCTAssertEqual(next, .rejected)
    }

    func testRejectedClearsToPossibleWhenScrubbedEmpty() {
        let s = RecognizerStateMirror.rejected
        let empty = NSEvent.ModifierFlags(rawValue: flagsRaw(forScrubbed: 0))
        let next = RecognizerStateMirrorTransitions.afterKeysPressed(
            state: s, eventType: .keyDown, modifierFlags: empty
        )
        XCTAssertEqual(next, .possible)
    }

    func testRecognizerMaskConstantsUnchanged() {
        XCTAssertEqual(RecognizerStateMirrorTransitions.leftCommandKeyMask, 0b000100000000000000001000)
        XCTAssertEqual(RecognizerStateMirrorTransitions.rightCommandKeyMask, 0b000100000000000000010000)
        XCTAssertEqual(RecognizerStateMirrorTransitions.emptyMask, 0)
    }
}
