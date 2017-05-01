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
        
        let validDictionary = [
            "numericalValue": 1,
            "stringValue": "JSON",
            "arrayValue": [0, 1, 2, 3, 4, 5]
        ] as [String : Any]
        
        let rawData: NSData!
        
        
       print(JSONSerialization.isValidJSONObject(validDictionary))
        
        
        if JSONSerialization.isValidJSONObject(validDictionary) { // True
            do {
                rawData = try JSONSerialization.data(withJSONObject: validDictionary, options: .prettyPrinted) as NSData!
                try rawData.write(to: URL(fileURLWithPath: "newdata.json"), options: .atomic)
                
                let jsonData = NSData(contentsOfFile: "newdata.json")
                let jsonDict = try JSONSerialization.jsonObject(with: jsonData! as Data, options: .mutableContainers)
                // -> ["stringValue": "JSON", "arrayValue": [0, 1, 2, 3, 4, 5], "numericalValue": 1]
                print(jsonDict)
                
            } catch {
                // Handle Error
                print("error")
                print(error.localizedDescription)
            }
        }
        
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!

        
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent("test.json")
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        
        // creating a .json file in the Documents folder
        if !fileManager.fileExists(atPath: (jsonFilePath?.absoluteString)!, isDirectory: &isDirectory) {
            let created = fileManager.createFile(atPath: (jsonFilePath?.absoluteString)!, contents: nil, attributes: nil)
            if created {
                print("File created ")
            } else {
                print("Couldn't create file for some reason")
            }
        } else {
            print("File already exists")
        }
        
        // creating an array of test data
        var numbers = [String]()
        for i in 0 ..< 100 {
            numbers.append("Test\(i)")
        }
        
        // creating JSON out of the above array
        var jsonData: NSData!
        do {
            //jsonData = try JSONSerialization.data(withJSONObject: validDictionary, options: JSONSerialization.WritingOptions()) as NSData!
            jsonData = try JSONSerialization.data(withJSONObject: numbers, options: JSONSerialization.WritingOptions()) as NSData!
            let jsonString = String(data: jsonData as Data, encoding: String.Encoding.utf8)
            print(jsonString)
        } catch let error as NSError {
            print("Array to JSON conversion failed: \(error.localizedDescription)")
        }
        
        // Write that JSON to the file created earlier
        let jsonFilePath2 = documentsDirectoryPath.appendingPathComponent("test.json")
        do {
            let file = try FileHandle(forWritingTo: jsonFilePath2!)
            file.write(jsonData as Data)
            print("JSON data was written to teh file successfully!")
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
        
        
        
        
    }
    
    @IBAction func resetButtonAction(_ sender: UIButton) {
        // Reset grid by creating a new empty grid
        engine.engineCreateNewGrid()
        
        
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
        
        
        let jsonFilePath3 = documentsDirectoryPath.appendingPathComponent("test.json")
        do {
            let file = try FileHandle(forReadingFrom: jsonFilePath3!)
            let data = file.readDataToEndOfFile()
            //var data:NSData = NSData(contentsOfFile: file   )
            let jsony = try JSONSerialization.jsonObject(with: data, options: [])
            //let jsonString = String(data: jsony as! Data, encoding: String.Encoding.utf8)
            print(jsony)
            
            
            print("JSON data was written to teh file successfully!")
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
        
        
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

