//
//  SimulationViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController, GridViewDataSource, EngineDelegate {
    @IBOutlet weak var GridView: GridView!
    @IBOutlet weak var stepButton: UIButton!

    var engine: Engine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let size = GridView.gridSize
        engine = Engine(rows: size, cols: size)
        engine.delegate = self
        GridView.drawGrid = self
    }
    
    func engineDidUpdate(engine: Engine) {
        self.GridView.setNeedsDisplay()
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
        engine.step()
    }

}

