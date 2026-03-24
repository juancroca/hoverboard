/*
 * Test-only helpers. `Grid` is not Equatable in the framework; this extension
 * lives only in the test target.
 */

import Foundation
@testable import HoverboardKit

extension Grid: Equatable {
    static func == (lhs: Grid, rhs: Grid) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
            && lhs.xnum == rhs.xnum && lhs.ynum == rhs.ynum
            && lhs.width == rhs.width && lhs.height == rhs.height
    }
}
