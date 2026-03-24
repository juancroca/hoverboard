/*
 * MUST stay in sync with `Recognizer.swift` (`flagsChanged`, `keysPressed`, masks).
 * Models state transitions without constructing `EventTap`.
 */

import AppKit
import Foundation

/// Parallel to `Recognizer.State` (internal); keep cases aligned.
enum RecognizerStateMirror: String, Equatable {
    case possible
    case pressedCommandOnce
    case releasedCommandOnce
    case pressedCommandTwice
    case rejected
    case recognized
}

enum RecognizerStateMirrorTransitions {

    static let leftCommandKeyMask: UInt = 0b000100000000000000001000
    static let rightCommandKeyMask: UInt = 0b000100000000000000010000
    static let emptyMask: UInt = 0

    static func scrub(_ flags: NSEvent.ModifierFlags) -> UInt {
        flags.rawValue ^ 0b100000000
    }

    /// Mirrors `Recognizer.flagsChanged(event:)` effect on `state`.
    static func afterFlagsChanged(state: RecognizerStateMirror,
                                  modifierFlags: NSEvent.ModifierFlags) -> RecognizerStateMirror {
        let rawValue = scrub(modifierFlags)

        if rawValue == leftCommandKeyMask || rawValue == rightCommandKeyMask {
            if modifierFlags.contains(.command) {
                return .pressedCommandOnce
            }
            return .possible
        }
        if rawValue == emptyMask {
            return state
        }
        return .possible
    }

    /// Mirrors `Recognizer.keysPressed(event:)` given current `state`.
    static func afterKeysPressed(state: RecognizerStateMirror,
                                 eventType: NSEvent.EventType,
                                 modifierFlags: NSEvent.ModifierFlags) -> RecognizerStateMirror {
        let rawValue = scrub(modifierFlags)

        switch state {
        case .pressedCommandOnce:
            if eventType == .flagsChanged && rawValue == emptyMask {
                return .releasedCommandOnce
            }
            return .rejected
        case .releasedCommandOnce:
            if eventType == .flagsChanged {
                if rawValue == leftCommandKeyMask || rawValue == rightCommandKeyMask {
                    return .pressedCommandTwice
                }
                return .rejected
            }
            return .rejected
        case .pressedCommandTwice:
            if eventType == .flagsChanged && rawValue == emptyMask {
                return .recognized
            }
            return .rejected
        case .rejected:
            if rawValue == emptyMask {
                return .possible
            }
            return state
        default:
            return state
        }
    }
}
