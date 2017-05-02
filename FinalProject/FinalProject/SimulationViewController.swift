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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        engine = StandardEngine.shared()
        engine.delegate = self
        gridView.drawGrid = self
        
        // Make sure that the SimulationViewController knows about updated row/col size
        // before first time displayed
        self.gridView.gridRows = engine.rows
        self.gridView.gridCols = engine.cols
        
        let fileName = "Test"
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        
        var readString = "" // Used to store the file contents
        do {
            // Read the file contents
            readString = try String(contentsOf: fileURL)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
        }
        print("File Text: \(readString)")
        
        let sArray = readString.components(separatedBy: ",")
        let sArraySize = sArray.count/2
        var iArray = Array(repeating: Array(repeating: 0, count: 2), count: sArraySize)

        for i in 0..<(sArraySize) {
            for j in 0..<2 {
                iArray[i][j] = Int(sArray[2*i+j])!
            }
        }

        for cell in iArray {
            let row = cell[0]
            let col = cell[1]
            engine.grid[row,col] = CellState.alive
        }
        
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
        
        // Save data to file
        let fileName = "Test"
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        print("FilePath: \(fileURL.path)")
        
        let writeString = "Write this text to the fileURL as text in iOS using Swift"
        do {
            // Write to the file
            try gridValues.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }
    }
    
    @IBAction func resetButtonAction(_ sender: UIButton) {
        // Reset grid by creating a new empty grid
        engine.engineCreateNewGrid()
        
        gridView.setNeedsDisplay()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

