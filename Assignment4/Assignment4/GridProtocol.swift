//
//  GridProtocol.swift
//  Assignment4
//
//  Created by Michael Vartanian on 4/11/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

public struct GridPosition: Equatable {
    var row: Int
    var col: Int
    
    public static func == (lhs: GridPosition, rhs: GridPosition) -> Bool {
        return (lhs.row == rhs.row && lhs.col == rhs.col)
    }
}

public struct GridSize {
    var rows: Int
    var cols: Int
}

public enum CellState {
    case alive, empty, born, died
    
    public var isAlive: Bool {
        switch self {
        case .alive, .born: return true
        default: return false
        }
    }
    func description() -> String {
        switch self {
        case .alive: return "alive"
        case .empty: return "empty"
        case .born: return "born"
        case .died: return "died"
        }
    }
}

public protocol GridViewDataSource {
    subscript (row: Int, col: Int) -> CellState { get set }
}

public protocol GridProtocol: CustomStringConvertible {
    init(_ size: GridSize, cellInitializer: (GridPosition) -> CellState)
    var size: GridSize { get }
    subscript (row: Int, col: Int) -> CellState { get set }
    func next() -> Self
}
