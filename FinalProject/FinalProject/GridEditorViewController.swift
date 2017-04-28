//
//  GridEditorViewController.swift
//  FinalProject
//
//  Created by Michael Vartanian on 4/23/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class GridEditorViewController: UIViewController {
    
    var fruitValue: String?
    var gridStruct: GridInit?
    var saveClosure: ((String) -> Void)?
    var sampleEngine: StandardEngine!
    
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var fruitValueTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        if let gridStruct = gridStruct {
            sampleEngine = StandardEngine(rows: 2*gridStruct.maxDim, cols: 2*gridStruct.maxDim, refreshRate: 1)
            self.gridView.gridRows = sampleEngine.rows
            self.gridView.gridCols = sampleEngine.cols
            gridView.setNeedsDisplay()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(_ sender: UIButton) {
        if let newValue = fruitValueTextField.text,
            let saveClosure = saveClosure {
            saveClosure(newValue)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
}
