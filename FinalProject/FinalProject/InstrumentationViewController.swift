//
//  InstrumentationViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

let finalProjectURL = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"

struct GridInit {
    var title: String
    let contents: [[Int]]
    let maxDim: Int
}

var jsonTitles:Array<String> = Array<String>()

class InstrumentationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var rowStepper: UIStepper!
    @IBOutlet weak var colStepper: UIStepper!
    @IBOutlet weak var refreshRate: UISlider!
    @IBOutlet weak var refreshOnOff: UISwitch!
    @IBOutlet weak var numRowsTextField: UITextField!
    @IBOutlet weak var numColsTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var engine: StandardEngine!
    var jsonTitles2:Array<String> = Array<String>()
    var gridInits: [GridInit] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        engine = StandardEngine.shared()
        refreshOnOff.setOn(false, animated: false)
        
        rowStepper.value = Double(engine.rows)
        colStepper.value = Double(engine.cols)
        
        numRowsTextField.text = "\(engine.rows)"
        numColsTextField.text = "\(engine.cols)"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let fetcher = Fetcher()
        fetcher.fetchJSON(url: URL(string:finalProjectURL)!) { (json: Any?, message: String?) in
            guard message == nil else {
                print(message ?? "nil")
                return
            }
            guard let json = json else {
                print("no json")
                return
            }

            var maxDim: Int
            var temp: Int
            let resultString = (json as AnyObject).description
            let jsonArray = json as! NSArray
            
            for i in 0..<jsonArray.count {
                let jsonDictionary = jsonArray[i] as! NSDictionary
            
                let jsonTitle = jsonDictionary["title"] as! String
                let jsonContents = jsonDictionary["contents"] as! [[Int]]
                
                maxDim = 0
                temp = 0
                for j in 0..<(jsonContents.count) {
                    if (jsonContents[j][0] > jsonContents[j][1])
                    {
                        temp = jsonContents[j][0]
                    }
                    else
                    {
                        temp = jsonContents[j][1]
                    }
                    if (temp > maxDim)
                    {
                        maxDim = temp
                    }
                }
                let gridInit = GridInit(title: jsonTitle, contents: jsonContents, maxDim: maxDim)
                self.gridInits.append(gridInit)
            }
            
            OperationQueue.main.addOperation ({
                self.tableView.reloadData()
            })
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        engine = StandardEngine.shared()
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Row Stepper Event Handling
    @IBAction func rowStep(_ sender: UIStepper) {
        let numRows = Int(sender.value)
        numRowsTextField.text = "\(numRows)"
        StandardEngine.shared().updateNumRowsOrCols(rowOrCol: "row", num: numRows)
    }

    //MARK: Column Stepper Event Handling
    @IBAction func colStep(_ sender: UIStepper) {
        let numCols = Int(sender.value)
        numColsTextField.text = "\(numCols)"
        StandardEngine.shared().updateNumRowsOrCols(rowOrCol: "col", num: numCols)
    }
    
    //MARK: Row TextField Event Handling
    @IBAction func rowEditingEndedOnExit(_ sender: UITextField) {
        guard let text = sender.text else { return }
        guard let val = Int(text) else {
            showErrorAlert(withMessage: "Invalid value: \(text), please try again.") {
                sender.text = "\(self.engine.grid.size.rows)"
            }
            return
        }
        rowStepper.value = Double(val)
        StandardEngine.shared().updateNumRowsOrCols(rowOrCol: "row", num: val)
    }
    
    //MARK: Col TextField Event Handling
    @IBAction func colEditingEndedOnExit(_ sender: UITextField) {
        guard let text = sender.text else { return }
        guard let val = Int(text) else {
            showErrorAlert(withMessage: "Invalid value: \(text), please try again.") {
                sender.text = "\(self.engine.grid.size.cols)"
            }
            return
        }
        colStepper.value = Double(val)
        StandardEngine.shared().updateNumRowsOrCols(rowOrCol: "col", num: val)
    }

    //MARK: Timer RefreshRate Event Handling
    @IBAction func updateTimerRefreshRate(_ sender: UISlider) {
        engine.refreshTimer?.invalidate()
        engine.refreshRate = 1 / Double(Double(sender.value))
    }
    
    @IBAction func toggleTimer(_ sender: UISwitch) {
        StandardEngine.shared().toggleTimer(switchOn: refreshOnOff.isOn)
    }
    

    //MARK: AlertController Handling
    func showErrorAlert(withMessage msg:String, action: (() -> Void)? ) {
        let alert = UIAlertController(
            title: "Alert",
            message: msg,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true) { }
            OperationQueue.main.addOperation { action?() }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gridInits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "basic"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let label = cell.contentView.subviews.first as! UILabel
        label.text = gridInits[indexPath.item].title

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        if let indexPath = indexPath {
            let gridStruct = gridInits[indexPath.row]
            if let vc = segue.destination as? GridEditorViewController {
                navigationItem.title = "Cancel"
                vc.gridStruct = gridStruct
                vc.saveClosure = { newValue in
                    self.gridInits[indexPath.row] = gridStruct
                    self.tableView.reloadData()
                }
            }
        }
    }

}

