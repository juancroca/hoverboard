/*
 * Unit tests for OnboardKit helpers and public model APIs.
 */

import XCTest
import AppKit
@testable import OnboardKit

final class TitleFormatterTests: XCTestCase {

    func testPlainStringSubstitutesBundleNamePlaceholder() {
        let template = "Welcome to $(CFBundleName)"
        let result: String? = TitleFormatter.format(string: template)
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        XCTAssertEqual(result, "Welcome to \(bundleName ?? "")")
    }

    func testPlainStringWithoutPlaceholderUnchanged() {
        let result: String? = TitleFormatter.format(string: "No placeholder")
        XCTAssertEqual(result, "No placeholder")
    }

    func testPlainStringNilInput() {
        let result: String? = TitleFormatter.format(string: nil)
        XCTAssertNil(result)
    }

    func testAttributedStringReplacesPlaceholderWithColoredName() {
        let template = "X $(CFBundleName) Y"
        let attr: NSAttributedString? = TitleFormatter.format(string: template)
        XCTAssertNotNil(attr)
        let plain = attr?.string ?? ""
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
        XCTAssertTrue(plain.contains(bundleName))
        XCTAssertFalse(plain.contains("$(CFBundleName)"))
    }
}

final class EdgeInsetsExtensionTests: XCTestCase {

    func testHorizontalAndVerticalSums() {
        let e = NSEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
        XCTAssertEqual(e.horizontal, 6)
        XCTAssertEqual(e.vertical, 4)
    }
}

final class OnboardItemAPITests: XCTestCase {

    func testFluentButtonAndViewAccumulation() {
        let item = OnboardItem(title: "t", description: "d")
        let view1 = NSView(frame: NSRect(x: 0, y: 0, width: 1, height: 1))
        let view2 = NSView(frame: NSRect(x: 0, y: 0, width: 2, height: 2))
        _ = item
            .button(type: .default, title: "OK") { _ in }
            .button(type: .normal, title: "Skip") { _ in }
            .view(view1)
            .view(view2)
        XCTAssertEqual(item.buttons.count, 2)
        XCTAssertEqual(item.views.count, 2)
        XCTAssertEqual(item.title, "t")
        XCTAssertEqual(item.description, "d")
    }
}

// MARK: - OnboardController (internal data source)

final class OnboardControllerLayoutTests: XCTestCase {

    func testNumberOfCellsMatchesItemCount() {
        let items = (0..<5).map { OnboardItem(title: "\($0)", description: "d") }
        let c = OnboardController(title: "T", items: items)
        _ = c.view
        guard let cv = c.view as? CollectionView else {
            XCTFail("Expected CollectionView root")
            return
        }
        XCTAssertEqual(c.numberOfCells(in: cv), 5)
    }

    func testHorizontalDirectionUsesThirdWidthCells() {
        let items = [
            OnboardItem(title: "a", description: "a"),
            OnboardItem(title: "b", description: "b")
        ]
        let c = OnboardController(title: "T", items: items)
        c.direction = .horizontal
        _ = c.view
        guard let cv = c.view as? CollectionView else {
            XCTFail("Expected CollectionView root")
            return
        }
        cv.frame = NSRect(x: 0, y: 0, width: 600, height: 200)
        let sz = c.collectionView(cv, sizeForItemAt: IndexPath(item: 1, section: 0))
        XCTAssertEqual(sz.width, 200, accuracy: 0.01)
        XCTAssertEqual(sz.height, 200, accuracy: 0.01)
    }

    func testVerticalDirectionSelectedVsCollapsedHeights() {
        let items = [
            OnboardItem(title: "a", description: "a"),
            OnboardItem(title: "b", description: "b")
        ]
        let c = OnboardController(title: "T", items: items)
        c.direction = .vertical
        c.indexOfSelectedItem = 0
        _ = c.view
        guard let cv = c.view as? CollectionView else {
            XCTFail("Expected CollectionView root")
            return
        }
        cv.frame = NSRect(x: 0, y: 0, width: 400, height: 500)
        let selected = c.collectionView(cv, sizeForItemAt: IndexPath(item: 0, section: 0))
        let other = c.collectionView(cv, sizeForItemAt: IndexPath(item: 1, section: 0))
        XCTAssertEqual(selected.height, 120)
        XCTAssertEqual(other.height, 52)
        XCTAssertEqual(selected.width, 400)
        XCTAssertEqual(other.width, 400)
    }

    func testSelectItemUpdatesIndex() {
        let items = [
            OnboardItem(title: "a", description: "a"),
            OnboardItem(title: "b", description: "b")
        ]
        let c = OnboardController(title: "T", items: items)
        c.selectItem(atIndex: 1, animated: false)
        XCTAssertEqual(c.indexOfSelectedItem, 1)
    }
}

// MARK: - OnboardWindow centering (mirrors `OnboardWindowController.showWindow`)

final class OnboardWindowCenteringFormulaTests: XCTestCase {

    private func centerOrigin(visibleFrame: NSRect, windowFrame: NSRect) -> NSPoint {
        NSPoint(
            x: visibleFrame.midX - windowFrame.midX,
            y: visibleFrame.midY - windowFrame.midY
        )
    }

    func testCenteringAgainstVisibleFrame() {
        let vis = NSRect(x: 0, y: 0, width: 2000, height: 1500)
        let win = NSRect(x: 0, y: 0, width: 600, height: 400)
        let o = centerOrigin(visibleFrame: vis, windowFrame: win)
        XCTAssertEqual(o.x, 700)
        XCTAssertEqual(o.y, 550)
    }
}

// MARK: - CAMediaTimingFunction.spring

final class CAMediaTimingSpringTests: XCTestCase {

    func testSpringReturnsTimingFunction() {
        let f = CAMediaTimingFunction.spring()
        XCTAssertTrue(type(of: f) == CAMediaTimingFunction.self)
    }
}
