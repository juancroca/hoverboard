/*
 * MUST stay in sync with `Session.swift` arrow-key handlers (lines ~85–176).
 * Used to compute expected grids and to cross-check live `Session.process`.
 */

import Foundation
import HoverboardKit

enum SessionGridMutationMirror {

    static func applyLeft(grid: inout Grid, shift: Bool) {
        if shift && (grid.x != 0 || grid.width != 3) {
            grid.xnum += 1
        }

        if grid.width == 3 && grid.x > 0 {
            grid.x -= 1
        }

        if grid.x == 0 {
            grid.width += 1
        } else if grid.width != 3 {
            grid.x -= 1
        }
    }

    static func applyRight(grid: inout Grid, shift: Bool) {
        if grid.x == grid.width - 1 {
            grid.width += 1
        }

        grid.x += 1

        if shift {
            grid.x -= 1
            grid.xnum += 1
        }
    }

    static func applyDown(grid: inout Grid, shift: Bool) {
        if grid.y == grid.height - 1 {
            grid.height += 1
        }

        grid.y += 1

        if shift {
            grid.y -= 1
            grid.ynum += 1
        }
    }

    static func applyUp(grid: inout Grid, shift: Bool) {
        if shift && (grid.y != 0 || grid.height != 3) {
            grid.ynum += 1
        }

        if grid.height == 3 && grid.y > 0 {
            grid.y -= 1
        }

        if grid.y == 0 {
            grid.height += 1
        } else if grid.height != 3 {
            grid.y -= 1
        }
    }

    static func applyArrow(grid: inout Grid, keyCode: UInt16, shift: Bool) {
        switch keyCode {
        case 123: applyLeft(grid: &grid, shift: shift)
        case 124: applyRight(grid: &grid, shift: shift)
        case 125: applyDown(grid: &grid, shift: shift)
        case 126: applyUp(grid: &grid, shift: shift)
        default: break
        }
    }

    /// Same end state as `Session.process` for an arrow key (mutate + normalize).
    static func gridAfterArrow(from initial: Grid = Grid(), keyCode: UInt16,
                               shift: Bool) -> Grid {
        var g = initial
        applyArrow(grid: &g, keyCode: keyCode, shift: shift)
        g.normalize()
        return g
    }
}
