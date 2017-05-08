//
//  GridEditorViewController.swift
//  FinalProject
//
//  Created by Michael Vartanian on 4/23/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class GridEditorViewController: UIViewController, GridViewDataSource {
    
    var gridStruct: GridConfig?
    var saveClosure: ((GridConfig) -> Void)?
    var sampleEngine: StandardEngine!
    
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var configNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false

        if gridStruct != nil {
            sampleEngine = StandardEngine(rows: 2*gridStruct!.maxDim, cols: 2*gridStruct!.maxDim)
            
            sampleEngine.grid = sampleEngine.loadGridFrom(gridStruct: gridStruct!)
            
            gridView.drawGrid = self
            
            // Display the name of the gridConfig in the title bar
            self.title = gridStruct?.title
            configNameTextField.text = gridStruct?.title
            
            self.gridView.gridRows = sampleEngine.rows
            self.gridView.gridCols = sampleEngine.cols
            gridView.setNeedsDisplay()
        }
    }
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return sampleEngine.grid[row,col] }
        set { sampleEngine.grid[row,col] = newValue }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {

        // Load gridStruct.contents with values in grid
        gridStruct!.contents = []
        gridStruct!.contents = sampleEngine.loadgridStructFrom(engine: sampleEngine, contents: gridStruct!.contents)

        gridStruct!.maxDim = Int(sampleEngine.grid.size.rows/2)
        
        let engine = StandardEngine.shared()
        
        engine.grid = engine.loadGridFrom(gridStruct: gridStruct!)
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "SampleEngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["gridstruct" : gridStruct!])
        nc.post(n)
        
        gridStruct!.title = configNameTextField.text!
        
        // Pass the updated gridStruct back to the InstrumentationViewController
        if let newValue = gridStruct,
            let saveClosure = saveClosure {
            saveClosure(newValue)
            _ = navigationController?.popViewController(animated: true)
        }
    }
}
