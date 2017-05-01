//
//  GridEditorViewController.swift
//  FinalProject
//
//  Created by Michael Vartanian on 4/23/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class GridEditorViewController: UIViewController, GridViewDataSource {
    
    var fruitValue: String?
    var gridStruct: GridInit?
    var saveClosure: ((GridInit) -> Void)?
    var sampleEngine: StandardEngine!
    
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var fruitValueTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        if gridStruct != nil {
            sampleEngine = StandardEngine(rows: 2*gridStruct!.maxDim, cols: 2*gridStruct!.maxDim)
            self.gridView.gridRows = sampleEngine.rows
            self.gridView.gridCols = sampleEngine.cols
            
            for cell in gridStruct!.contents {
                let row = cell[0]
                let col = cell[1]
                sampleEngine.grid[row,col] = CellState.alive
            }
            
            gridView.drawGrid = self
            
            self.navigationController?.navigationBar.topItem?.title = gridStruct?.title
            
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
        (0 ..< sampleEngine.grid.size.rows).forEach { row in
            (0 ..< sampleEngine.grid.size.cols).forEach { col in
                let cell = sampleEngine.grid[row,col]
                if (cell.isAlive) {
                    gridStruct!.contents.append([row,col])
                }
            }
        }
        
        // Pass the updated gridStruct back to the InstrumentationViewController
        if let newValue = gridStruct,
            let saveClosure = saveClosure {
            saveClosure(newValue)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
