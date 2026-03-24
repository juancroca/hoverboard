/*
 * Small, non–event-tap-dependent checks (Key, Error text, screen id, auth query).
 */

import XCTest
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
}
