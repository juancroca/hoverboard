/*
 * Mirrors the layout math in `Window+Grid.swift` (visible-frame Y tweak, cell
 * rect, centered origin for non-resizable windows). If you change that setter,
 * update this file so tests continue to describe current behaviour.
 */

import XCTest
import AppKit
@testable import HoverboardKit

private enum WindowGridLayoutMirror {

    static func workingVisibleFrame(visibleFrame: NSRect,
                                    screenFrameHeight: CGFloat) -> NSRect {
        var frame = visibleFrame
        frame.origin.y = screenFrameHeight - visibleFrame.maxY
        return frame
    }

    static func cellBounds(for grid: Grid, visibleFrame: NSRect) -> NSRect {
        let width = visibleFrame.width
        let height = visibleFrame.height
        let x = grid.x / grid.width
        let y = grid.y / grid.height
        return NSRect(
            x: visibleFrame.origin.x + x * width,
            y: visibleFrame.origin.y + y * height,
            width: grid.xnum * width / grid.width,
            height: grid.ynum * height / grid.height
        )
    }

    static func centeredOrigin(cellBounds bounds: NSRect,
                               windowSize: NSSize) -> NSPoint {
        return NSPoint(
            x: bounds.origin.x + round(bounds.width - windowSize.width) / 2,
            y: bounds.origin.y + round(bounds.height - windowSize.height) / 2
        )
    }
}

final class WindowGridLayoutTests: XCTestCase {

    func testWorkingVisibleFrameYAdjustmentMatchesWindowGrid() {
        let visible = NSRect(x: 100, y: 200, width: 800, height: 600)
        let screenHeight: CGFloat = 900
        let adjusted = WindowGridLayoutMirror.workingVisibleFrame(
            visibleFrame: visible,
            screenFrameHeight: screenHeight
        )
        var expected = visible
        expected.origin.y = screenHeight - visible.maxY
        XCTAssertEqual(adjusted.origin.x, expected.origin.x)
        XCTAssertEqual(adjusted.origin.y, expected.origin.y)
        XCTAssertEqual(adjusted.size.width, visible.size.width)
        XCTAssertEqual(adjusted.size.height, visible.size.height)
    }

    func testCellBoundsFullGridOneByOne() {
        let vf = NSRect(x: 10, y: 20, width: 300, height: 200)
        var g = Grid()
        g.normalize()
        let b = WindowGridLayoutMirror.cellBounds(for: g, visibleFrame: vf)
        XCTAssertEqual(b, vf)
    }

    func testCellBoundsThreeByThreeBottomLeftCell() {
        let vf = NSRect(x: 0, y: 0, width: 300, height: 300)
        var g = Grid()
        g.width = 3
        g.height = 3
        g.x = 0
        g.y = 0
        g.normalize()
        let b = WindowGridLayoutMirror.cellBounds(for: g, visibleFrame: vf)
        XCTAssertEqual(b.origin.x, 0)
        XCTAssertEqual(b.origin.y, 0)
        XCTAssertEqual(b.width, 100, accuracy: 0.001)
        XCTAssertEqual(b.height, 100, accuracy: 0.001)
    }

    func testCellBoundsThreeByThreeTopRightTwoByOneSpan() {
        let vf = NSRect(x: 50, y: 60, width: 600, height: 300)
        var g = Grid()
        g.width = 3
        g.height = 3
        g.x = 2
        g.y = 2
        g.xnum = 1
        g.ynum = 2
        g.normalize()
        let b = WindowGridLayoutMirror.cellBounds(for: g, visibleFrame: vf)
        XCTAssertEqual(b.origin.x, 50 + 400)
        XCTAssertEqual(b.origin.y, 60 + 200)
        XCTAssertEqual(b.width, 200, accuracy: 0.001)
        XCTAssertEqual(b.height, 200, accuracy: 0.001)
    }

    func testCenteredOriginUsesRoundOnDeltaBeforeHalving() {
        let cell = NSRect(x: 10, y: 20, width: 100, height: 100)
        let origin = WindowGridLayoutMirror.centeredOrigin(
            cellBounds: cell,
            windowSize: NSSize(width: 50, height: 40)
        )
        XCTAssertEqual(origin.x, 35)
        XCTAssertEqual(origin.y, 50)
    }

    /// Every unit cell in a 3×3 grid maps to one ninth of the visible rect.
    func testAllUnitCellsThreeByThree() {
        let vf = NSRect(x: -100, y: 50, width: 300, height: 300)
        let cellW: CGFloat = 100
        let cellH: CGFloat = 100
        for gx in 0..<3 {
            for gy in 0..<3 {
                var g = Grid()
                g.width = 3
                g.height = 3
                g.x = CGFloat(gx)
                g.y = CGFloat(gy)
                g.normalize()
                let b = WindowGridLayoutMirror.cellBounds(for: g, visibleFrame: vf)
                XCTAssertEqual(b.origin.x, vf.minX + CGFloat(gx) * cellW, accuracy: 0.01)
                XCTAssertEqual(b.origin.y, vf.minY + CGFloat(gy) * cellH, accuracy: 0.01)
                XCTAssertEqual(b.width, cellW, accuracy: 0.01)
                XCTAssertEqual(b.height, cellH, accuracy: 0.01)
            }
        }
    }

    /// Full-width × full-height cell (single tile).
    func testFullSpanThreeByThree() {
        let vf = NSRect(x: 0, y: 0, width: 333, height: 222)
        var g = Grid()
        g.width = 3
        g.height = 3
        g.xnum = 3
        g.ynum = 3
        g.normalize()
        let b = WindowGridLayoutMirror.cellBounds(for: g, visibleFrame: vf)
        XCTAssertEqual(b, vf)
    }

    /// Resizable target rect matches cell bounds (mirror of `Window.grid` when resizable).
    func testResizableFrameEqualsCellBounds() {
        let vf = NSRect(x: 10, y: 20, width: 300, height: 200)
        var g = Grid()
        g.width = 2
        g.height = 2
        g.x = 1
        g.y = 1
        g.normalize()
        let b = WindowGridLayoutMirror.cellBounds(for: g, visibleFrame: vf)
        XCTAssertEqual(b.origin.x, 160)
        XCTAssertEqual(b.origin.y, 120)
        XCTAssertEqual(b.width, 150)
        XCTAssertEqual(b.height, 100)
    }
}
