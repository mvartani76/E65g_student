//
//  Grid.swift
//
import Foundation

fileprivate func norm(_ val: Int, to size: Int) -> Int { return ((val % size) + size) % size }

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
    subscript (row: Int, col: Int) -> CellState { get set }
    var size: GridSize { get }
    func next() -> Self
}

public let lazyPositions = { (size: GridSize) in
    return (0 ..< size.rows)
        .lazy
        .map { zip( [Int](repeating: $0, count: size.cols) , 0 ..< size.cols ) }
        .flatMap { $0 }
        .map { GridPosition(row: $0.0,col: $0.1) }
}

fileprivate let offsets: [GridPosition] = [
    GridPosition(row: -1, col:  -1), GridPosition(row: -1, col:  0), GridPosition(row: -1, col:  1),
    GridPosition(row:  0, col:  -1),                                 GridPosition(row:  0, col:  1),
    GridPosition(row:  1, col:  -1), GridPosition(row:  1, col:  0), GridPosition(row:  1, col:  1)
]

public extension GridProtocol {
}

public struct Grid: GridProtocol, GridViewDataSource {
    private var _cells: [[CellState]]
    public var size: GridSize

    public subscript (row: Int, col: Int) -> CellState {
        get { return _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] }
        set { _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] = newValue }
    }
    
    public init(_ size: GridSize, cellInitializer: (GridPosition) -> CellState = { _ in .empty }) {
        _cells = [[CellState]](
            repeatElement(
                [CellState]( repeatElement(.empty, count: size.cols)),
                count: size.rows
            )
        )
        self.size = size
        lazyPositions(self.size).forEach { self[$0.row, $0.col] = cellInitializer($0) }
    }
    
    public var description: String {
        return lazyPositions(self.size)
            .map { (self[$0.row, $0.col].isAlive ? "*" : " ") + ($0.col == self.size.cols - 1 ? "\n" : "") }
            .joined()
    }
    
    private func neighborStates(of pos: GridPosition) -> [CellState] {
        return offsets.map { self[pos.row + $0.row, pos.col + $0.col] }
    }
    
    private func nextState(of pos: GridPosition) -> CellState {
        let iAmAlive = self[pos.row, pos.col].isAlive
        let numLivingNeighbors = neighborStates(of: pos).filter({ $0.isAlive }).count
        switch numLivingNeighbors {
        case 2 where iAmAlive,
             3: return iAmAlive ? .alive : .born
        default: return iAmAlive ? .died  : .empty
        }
    }
    
    public func next() -> Grid {
        var nextGrid = Grid(size) { _ in .empty }
        lazyPositions(self.size).forEach { nextGrid[$0.row, $0.col] = self.nextState(of: $0) }
        return nextGrid
    }
}

extension Grid: Sequence {
    fileprivate var living: [GridPosition] {
        return lazyPositions(self.size).filter { return  self[$0.row, $0.col].isAlive   }
    }
    
    public struct GridIterator: IteratorProtocol {
        private class GridHistory: Equatable {
            let positions: [GridPosition]
            let previous:  GridHistory?
            
            static func == (lhs: GridHistory, rhs: GridHistory) -> Bool {
                return lhs.positions.elementsEqual(rhs.positions, by: ==)
            }
            
            init(_ positions: [GridPosition], _ previous: GridHistory? = nil) {
                self.positions = positions
                self.previous = previous
            }
            
            var hasCycle: Bool {
                var prev = previous
                while prev != nil {
                    if self == prev { return true }
                    prev = prev!.previous
                }
                return false
            }
        }
        
        private var grid: GridProtocol
        private var history: GridHistory!
        
        init(grid: Grid) {
            self.grid = grid
            self.history = GridHistory(grid.living)
        }
        
        public mutating func next() -> GridProtocol? {
            if history.hasCycle { return nil }
            let newGrid:Grid = grid.next() as! Grid
            history = GridHistory(newGrid.living, history)
            grid = newGrid
            return grid
        }
    }
    
    public func makeIterator() -> GridIterator { return GridIterator(grid: self) }
}

public extension Grid {
    public static func gliderInitializer(pos: GridPosition) -> CellState {
        switch pos {
        case GridPosition(row: 0, col: 1), GridPosition(row: 1, col: 2), GridPosition(row: 2, col: 0),
             GridPosition(row: 2, col: 1), GridPosition(row: 2, col: 2): return .alive
        default: return .empty
        }
    }
}

protocol EngineDelegate {
    func engineDidUpdate(withGrid: GridProtocol)
}

protocol EngineProtocol {
    var delegate: EngineDelegate? { get set }
    var grid: GridProtocol { get }
    var refreshRate: Double { get set }
    var refreshTimer: Timer? { get set }
    var rows: Int { get set }
    var cols: Int { get set }
    func step() -> GridProtocol
}

class StandardEngine: EngineProtocol {
    var delegate: EngineDelegate?
    var grid: GridProtocol
    var refreshTimer: Timer?
    var refreshRate: Double = 0.0 {
        didSet {
            if (timerOn && (refreshRate > 0.0)) {
                refreshTimer = Timer.scheduledTimer(
                    withTimeInterval: refreshRate,
                    repeats: true
                ) { (t: Timer) in
                    _ = self.step()
                }
            }
            else {
                refreshTimer?.invalidate()
                refreshTimer = nil
            }
        }
    }
    var timerOn = false
    var rows: Int
    var cols: Int

    private static var engine: StandardEngine = StandardEngine(rows: 10, cols: 10, refreshRate: 1.0)
    
    // Initialize grid with refreshRate
    init(rows: Int, cols: Int, refreshRate: Double) {
        self.grid = Grid(GridSize(rows: rows, cols: cols))
        self.rows = rows
        self.cols = cols
        self.refreshRate = refreshRate
    }
    
    // Initialize grid without refreshRate
    init(rows: Int, cols: Int) {
        self.grid = Grid(GridSize(rows: rows, cols: cols))
        self.rows = rows
        self.cols = cols
    }
    
    func step() -> GridProtocol {
        let newGrid = grid.next()
        grid = newGrid
        delegate?.engineDidUpdate(withGrid: grid)
        engineUpdateNotify()
        
        return grid
    }

    // Function to load grid from gridStruct
    func loadGridFrom(gridStruct: GridConfig) -> (GridProtocol) {
        updateNumRowsOrCols(rowOrCol: "both", numRows: gridStruct.maxDim*2, numCols: gridStruct.maxDim*2)
        
        for cell in gridStruct.contents {
            let row = cell[0]
            let col = cell[1]
            StandardEngine.engine.grid[row,col] = CellState.alive
        }
        return StandardEngine.engine.grid
    }
    
    func updateNumRowsOrCols(rowOrCol: String, numRows: Int, numCols: Int) {
        if rowOrCol == "row"
        {
            StandardEngine.engine.rows = numRows
            self.rows = numRows
        }
        else if rowOrCol == "col"
        {
            StandardEngine.engine.cols = numCols
            self.cols = numCols
        }
        else
        {
            StandardEngine.engine.rows = numRows
            self.cols = numRows
            StandardEngine.engine.cols = numCols
            self.cols = numCols
        }
        
        // Create New Grid Instance
        engineCreateNewGrid()
    }
    
    public func engineCreateNewGrid()
    {
       // Create New Grid Instance
        grid = Grid(GridSize(rows: self.rows, cols: self.cols))
        delegate?.engineDidUpdate(withGrid: grid)
    
        engineUpdateNotify()
    }
    
    public func engineUpdateNotify()
    {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
        nc.post(n)
        
        var gridValues = String()
        (0 ..< StandardEngine.engine.grid.size.rows).forEach { row in
            (0 ..< StandardEngine.engine.grid.size.cols).forEach { col in
                let cell = StandardEngine.engine.grid[row,col]
                if (cell.isAlive) {
                    gridValues.append("\(row),")
                    gridValues.append("\(col),")
                }
            }
        }
    }
    
    // MARK: Engine toggleTimer
    func toggleTimer(switchOn: Bool) {
        // set the internal switch state value to what was passed in by the function
        // need to set refreshRate equal to itself to force the didSet{} code to run
        // we want this code to run as it enables/disables the timer through the
        // invalide method
        timerOn = switchOn
        refreshRate = StandardEngine.engine.refreshRate
    }

    class func shared() -> StandardEngine {
        return engine
    }
}
