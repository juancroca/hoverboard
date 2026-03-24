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

    /// Systematic sweep: every combination in a small range must normalize to invariants.
    func testNormalizeInvariantsForWideRangeOfInputs() {
        for w in 1...4 {
            for h in 1...4 {
                for x in 0...4 {
                    for y in 0...4 {
                        for xn in 1...4 {
                            for yn in 1...4 {
                                var g = Grid()
                                g.width = CGFloat(w)
                                g.height = CGFloat(h)
                                g.x = CGFloat(x)
                                g.y = CGFloat(y)
                                g.xnum = CGFloat(xn)
                                g.ynum = CGFloat(yn)
                                g.normalize()
                                XCTAssertLessThanOrEqual(g.width, 3)
                                XCTAssertLessThanOrEqual(g.height, 3)
                                XCTAssertGreaterThanOrEqual(g.x, 0)
                                XCTAssertGreaterThanOrEqual(g.y, 0)
                                XCTAssertLessThanOrEqual(g.x, g.width - 1)
                                XCTAssertLessThanOrEqual(g.y, g.height - 1)
                                XCTAssertLessThanOrEqual(g.xnum, g.width)
                                XCTAssertLessThanOrEqual(g.ynum, g.height)
                                XCTAssertLessThanOrEqual(g.x + g.xnum, g.width)
                                XCTAssertLessThanOrEqual(g.y + g.ynum, g.height)
                            }
                        }
                    }
                }
            }
        }
    }
}
