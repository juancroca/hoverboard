/*
 * Live `Session.process` vs `SessionGridMutationMirror` (requires `WindowManager`
 * / event tap). Skips when `WindowManager()` cannot be created.
 */

import XCTest
import AppKit
@testable import HoverboardKit

private final class GridCapture: SessionDelegate {
    private(set) var lastGrid: Grid?
    private(set) var endCount = 0

    func session(_ session: Session, didUpdate grid: Grid) {
        lastGrid = grid
    }

    func sessionDidEnd(_ session: Session) {
        endCount += 1
    }
}

final class SessionProcessIntegrationTests: XCTestCase {

    private var savedTimeout: TimeInterval!

    override func setUp() {
        super.setUp()
        savedTimeout = Session.timeout
        Session.timeout = 86_400
    }

    override func tearDown() {
        Session.timeout = savedTimeout
        super.tearDown()
    }

    private func keyDown(keyCode: UInt16, shift: Bool = false) -> NSEvent {
        let mods: NSEvent.ModifierFlags = shift ? .shift : []
        guard let ev = NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: mods,
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: "",
            charactersIgnoringModifiers: "",
            isARepeat: false,
            keyCode: keyCode
        ) else {
            XCTFail("NSEvent.keyEvent failed")
            fatalError()
        }
        return ev
    }

    private func withLiveSession(
        _ body: (Session, GridCapture) throws -> Void
    ) throws {
        guard let manager = try? WindowManager() else {
            throw XCTSkip("WindowManager init failed (event tap unavailable)")
        }
        let session = Session(manager: manager)
        let capture = GridCapture()
        session.delegate = capture
        try body(session, capture)
        session.end()
    }

    func testArrowKeysMatchMirrorSingleSteps() throws {
        let cases: [(UInt16, Bool)] = [
            (123, false), (123, true),
            (124, false), (124, true),
            (125, false), (125, true),
            (126, false), (126, true)
        ]
        for (code, shift) in cases {
            try withLiveSession { session, capture in
                let expected = SessionGridMutationMirror.gridAfterArrow(
                    from: Grid(), keyCode: code, shift: shift
                )
                XCTAssertTrue(session.process(event: keyDown(keyCode: code, shift: shift)))
                XCTAssertEqual(capture.lastGrid, expected, "key \(code) shift \(shift)")
            }
        }
    }

    func testArrowSequenceMatchesMirror() throws {
        try withLiveSession { session, capture in
            var g = Grid()
            SessionGridMutationMirror.applyRight(grid: &g, shift: false)
            g.normalize()
            SessionGridMutationMirror.applyDown(grid: &g, shift: false)
            g.normalize()
            SessionGridMutationMirror.applyLeft(grid: &g, shift: true)
            g.normalize()
            let expected = g

            XCTAssertTrue(session.process(event: keyDown(keyCode: 124)))
            XCTAssertTrue(session.process(event: keyDown(keyCode: 125)))
            XCTAssertTrue(session.process(event: keyDown(keyCode: 123, shift: true)))
            XCTAssertEqual(capture.lastGrid, expected)
        }
    }

    func testModifierResetKeyDoesNotEndSessionAndDoesNotUpdateGrid() throws {
        try withLiveSession { session, capture in
            XCTAssertTrue(session.isActive)
            XCTAssertTrue(session.process(event: keyDown(keyCode: 54)))
            XCTAssertTrue(session.isActive)
            XCTAssertNil(capture.lastGrid)
        }
    }

    func testUnknownKeyEndsSessionReturnsFalse() throws {
        try withLiveSession { session, capture in
            XCTAssertTrue(session.isActive)
            let handled = session.process(event: keyDown(keyCode: 11))
            XCTAssertFalse(handled)
            XCTAssertFalse(session.isActive)
            XCTAssertEqual(capture.endCount, 1)
        }
    }

    func testEscapeEndsSessionAndReturnsHandledTrue() throws {
        try withLiveSession { session, capture in
            XCTAssertTrue(session.process(event: keyDown(keyCode: 53)))
            XCTAssertFalse(session.isActive)
            XCTAssertEqual(capture.endCount, 1)
        }
    }
}

/// Property-style checks on the mirrored session grid mutations (no `WindowManager`).
final class SessionGridMirrorStressTests: XCTestCase {

    private func assertNormalizedInvariants(_ g: Grid, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertLessThanOrEqual(g.width, 3, file: file, line: line)
        XCTAssertLessThanOrEqual(g.height, 3, file: file, line: line)
        XCTAssertGreaterThanOrEqual(g.x, 0, file: file, line: line)
        XCTAssertGreaterThanOrEqual(g.y, 0, file: file, line: line)
        XCTAssertLessThanOrEqual(g.x + g.xnum, g.width, file: file, line: line)
        XCTAssertLessThanOrEqual(g.y + g.ynum, g.height, file: file, line: line)
    }

    func testRandomArrowWalksPreserveInvariants() {
        let codes: [UInt16] = [123, 124, 125, 126]
        for _ in 0..<300 {
            var g = Grid()
            for _ in 0..<40 {
                let code = codes[Int(arc4random_uniform(4))]
                let shift = arc4random_uniform(2) == 1
                SessionGridMutationMirror.applyArrow(grid: &g, keyCode: code, shift: shift)
                g.normalize()
                assertNormalizedInvariants(g)
            }
        }
    }
}
