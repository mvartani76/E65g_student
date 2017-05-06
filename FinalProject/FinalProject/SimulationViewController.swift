//
//  SimulationViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

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
    
    func loadSampleGrid(notification:Notification) -> Void {
        guard let gridStruct = notification.userInfo!["gridstruct"] else { return }
        
        engine.grid = engine.loadGridFrom(gridStruct: (gridStruct as! GridConfig))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        engine = StandardEngine.shared()
        engine.delegate = self
        gridView.drawGrid = self
        
        // Observe "SampleEngineUpdate" notifications
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "SampleEngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil,
            using: loadSampleGrid)
        
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
        var gridStruct = GridConfig(title: "savedefault", contents: [], maxDim: engine.grid.size.rows)        
        gridStruct.contents = engine.loadgridStructFrom(engine: engine, contents: gridStruct.contents)

        // Store user defaults for num rows/cols & grid values (only alive/empty)
        saveConfigDefaults(gridStruct: gridStruct, config_gridStructKeyName: "simConfig_gridStruct", config_NumRowsKeyName: "simConfig_rows", config_NumColsKeyName: "simConfig_cols")
    }
    
    @IBAction func resetButtonAction(_ sender: UIButton) {
        // Reset grid by creating a new empty grid
        engine.engineCreateNewGrid()
        
        gridView.setNeedsDisplay()
    }
    
    // Function to save configuration values to user defaults
    func saveConfigDefaults(gridStruct: GridConfig, config_gridStructKeyName: String, config_NumRowsKeyName: String, config_NumColsKeyName: String) {
        
        let gridDict: Dictionary<String, Array<Array<Int>>>
        
        gridDict = ["gridStructContents" : gridStruct.contents]
        
        defaults.set(gridDict, forKey: config_gridStructKeyName)
        defaults.set(engine.grid.size.rows, forKey: config_NumRowsKeyName)
        defaults.set(engine.grid.size.cols, forKey: config_NumColsKeyName)
    }
}

