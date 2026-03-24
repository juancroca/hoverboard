/*
 * Small, non–event-tap-dependent checks (Key, Error text, screen id, auth query).
 */

import XCTest
import AppKit
@testable import HoverboardKit

final class HoverboardKitMiscTests: XCTestCase {

    func testKeyRawValuesStable() {
        XCTAssertEqual(Key.command.rawValue, "command")
        XCTAssertEqual(Key.left.rawValue, "left")
        XCTAssertEqual(Key.right.rawValue, "right")
        XCTAssertEqual(Key.down.rawValue, "down")
        XCTAssertEqual(Key.up.rawValue, "up")
        XCTAssertEqual(Key.shift.rawValue, "shift")
    }

    func testErrorDescriptionsIncludeCode() {
        XCTAssertTrue(Error.unauthorized.description.contains("(-1)"))
        XCTAssertTrue(Error.eventTapFailed.description.contains("(-2)"))
        XCTAssertTrue(Error.runLoopSourceFailed.description.contains("(-3)"))
        XCTAssertTrue(Error.invalidEventTap.description.contains("(-4)"))
    }

    func testMainScreenHasDisplayIDWhenAvailable() {
        guard let main = NSScreen.main else {
            XCTFail("NSScreen.main unexpectedly nil")
            return
        }
        XCTAssertNotNil(main.directDisplayID)
    }

    func testAuthorizationManagerIsAuthorizedQueryDoesNotCrash() {
        _ = AuthorizationManager().isAuthorized
    }

    /// `WindowManager.start()` must fail when the process is not trusted for accessibility.
    func testWindowManagerStartThrowsWhenUnauthorized() throws {
        if AuthorizationManager().isAuthorized {
            throw XCTSkip("Skipping: process already trusted for accessibility")
        }
        guard let wm = try? WindowManager() else {
            throw XCTSkip("WindowManager init failed (event tap unavailable)")
        }
        XCTAssertThrowsError(try wm.start())
    }

    /// Smoke: `Recognizer` can be constructed when the system allows a global event tap.
    func testRecognizerInitWhenPermitted() throws {
        guard let _ = try? Recognizer(closure: {}) else {
            throw XCTSkip("Recognizer init failed (event tap unavailable)")
        }
    }
}
