/*
 * Behavioural contract for `Grid.normalize()` — must stay aligned with Session
 * arrow-key handling.
 */

import XCTest
@testable import HoverboardKit

final class GridNormalizationTests: XCTestCase {

    func testDefaultGridUnchanged() {
        var g = Grid()
        g.normalize()
        XCTAssertEqual(g.x, 0)
        XCTAssertEqual(g.y, 0)
        XCTAssertEqual(g.xnum, 1)
        XCTAssertEqual(g.ynum, 1)
        XCTAssertEqual(g.width, 1)
        XCTAssertEqual(g.height, 1)
    }

    func testCapsWidthAndHeightAtThree() {
        var g = Grid()
        g.width = 10
        g.height = 10
        g.normalize()
        XCTAssertEqual(g.width, 3)
        XCTAssertEqual(g.height, 3)
    }

    func testClampsXAndYToValidRange() {
        var g = Grid()
        g.width = 2
        g.height = 2
        g.x = 99
        g.y = -5
        g.normalize()
        XCTAssertEqual(g.x, 1)
        XCTAssertEqual(g.y, 0)
    }

    func testClampsXnumYnumToGridAndPosition() {
        var g = Grid()
        g.width = 2
        g.height = 2
        g.x = 0
        g.y = 0
        g.xnum = 5
        g.ynum = 5
        g.normalize()
        XCTAssertEqual(g.xnum, 2)
        XCTAssertEqual(g.ynum, 2)
    }

    func testEnsuresSelectionFitsInsideGrid() {
        var g = Grid()
        g.width = 3
        g.height = 3
        g.x = 2
        g.y = 2
        g.xnum = 2
        g.ynum = 2
        g.normalize()
        XCTAssertEqual(g.x, 1)
        XCTAssertEqual(g.y, 1)
        XCTAssertEqual(g.xnum, 2)
        XCTAssertEqual(g.ynum, 2)
    }

    func testMaxCornerThreeByThree() {
        var g = Grid()
        g.width = 3
        g.height = 3
        g.x = 2
        g.y = 2
        g.xnum = 1
        g.ynum = 1
        g.normalize()
        XCTAssertEqual(g.x, 2)
        XCTAssertEqual(g.y, 2)
    }
}
