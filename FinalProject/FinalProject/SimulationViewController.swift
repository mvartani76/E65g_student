//
//  SimulationViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

var gridValues = String()

class SimulationViewController: UIViewController, GridViewDataSource, EngineDelegate {
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var stepButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    var engine: StandardEngine!
    var delegate: EngineDelegate?

    var refreshRate: Double = 0.0
    var rows: Int = 10
    var cols: Int = 10
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        engine = StandardEngine.shared()
        engine.delegate = self
        gridView.drawGrid = self

        // Load Configuration from UserDefaults
        loadConfigDefaults(config_gridValues: "simConfig_gridValues", config_NumRows: "simConfig_rows", config_NumCols: "simConfig_cols")
        
        // Make sure that the SimulationViewController knows about updated row/col size
        // before first time displayed
        self.gridView.gridRows = engine.rows
        self.gridView.gridCols = engine.cols

        gridView.setNeedsDisplay()
    }

    func engineDidUpdate(withGrid: GridProtocol) {
        self.gridView.gridRows = StandardEngine.shared().rows
        self.gridView.gridCols = StandardEngine.shared().cols
        self.gridView.setNeedsDisplay()
    }

    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func stepButtonAction(_ sender: UIButton) {
        engine.grid = engine.step()
    }

    @IBAction func saveButtonAction(_ sender: UIButton) {
        
        // Load gridStruct.contents with values in grid
        var gridValues = String()
        (0 ..< engine.grid.size.rows).forEach { row in
            (0 ..< engine.grid.size.cols).forEach { col in
                let cell = engine.grid[row,col]
                if (cell.isAlive) {
                    gridValues.append("\(row),")
                    gridValues.append("\(col),")
                }
            }
        }

        // Store user defaults for num rows/cols & grid values (only alive/empty)
        saveConfigDefaults(config_gridValues: "simConfig_gridValues", config_NumRows: "simConfig_rows", config_NumCols: "simConfig_cols")
    }
    
    @IBAction func resetButtonAction(_ sender: UIButton) {
        // Reset grid by creating a new empty grid
        engine.engineCreateNewGrid()
        
        gridView.setNeedsDisplay()
    }
    
    // Function to load configuration values from user defaults
    func loadConfigDefaults(config_gridValues: String, config_NumRows: String, config_NumCols: String) {
        
        if let gridValues = defaults.object(forKey: config_gridValues)
        {
            if let gridRows = defaults.object(forKey: config_NumRows)
            {
                if let gridCols = defaults.object(forKey: config_NumCols)
                {
                    let sArray = String(describing: gridValues).components(separatedBy: ",")
                    let sArraySize = sArray.count/2
                    var iArray = Array(repeating: Array(repeating: 0, count: 2), count: sArraySize)
                    
                    for i in 0..<(sArraySize) {
                        for j in 0..<2 {
                            iArray[i][j] = Int(sArray[2*i+j])!
                        }
                    }
                    
                    StandardEngine.shared().updateNumRowsOrCols(rowOrCol: "both", numRows: gridRows as! Int, numCols: gridCols as! Int)
                    
                    gridView.setNeedsDisplay()
                    
                    for cell in iArray {
                        let row = cell[0]
                        let col = cell[1]
                        engine.grid[row,col] = CellState.alive
                    }
                }
            }
        }
    }
    // Function to save configuration values to user defaults
    func saveConfigDefaults(config_gridValues: String, config_NumRows: String, config_NumCols: String) {
        defaults.set(gridValues, forKey: config_gridValues)
        defaults.set(engine.grid.size.rows, forKey: config_NumRows)
        defaults.set(engine.grid.size.cols, forKey: config_NumCols)
    }
}

