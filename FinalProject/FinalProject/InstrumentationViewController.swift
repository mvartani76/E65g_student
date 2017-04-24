//
//  InstrumentationViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

var sectionHeaders = [
    "One", "Two", "Three", "Four", "Five", "Six"
]

var data = [
    [
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date"
    ],
    [
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana"
    ],
    [
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry"
    ],
    [
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Blueberry"
    ]
]

class InstrumentationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var rowStepper: UIStepper!
    @IBOutlet weak var colStepper: UIStepper!
    @IBOutlet weak var refreshRate: UISlider!
    @IBOutlet weak var refreshOnOff: UISwitch!
    @IBOutlet weak var numRowsTextField: UITextField!
    @IBOutlet weak var numColsTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var engine: StandardEngine!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        engine = StandardEngine.shared()
        refreshOnOff.setOn(false, animated: false)
        
        rowStepper.value = Double(engine.rows)
        colStepper.value = Double(engine.cols)
        
        numRowsTextField.text = "\(engine.rows)"
        numColsTextField.text = "\(engine.cols)"
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

    @IBAction func updateTimerRefreshRate(_ sender: UISlider) {
        engine.refreshTimer?.invalidate()
        engine.refreshRate = Double(Double(sender.value))
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
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "basic"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let label = cell.contentView.subviews.first as! UILabel
        label.text = data[indexPath.section][indexPath.item]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaders[section]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var newData = data[indexPath.section]
            newData.remove(at: indexPath.row)
            data[indexPath.section] = newData
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        if let indexPath = indexPath {
            let fruitValue = data[indexPath.section][indexPath.row]
            if let vc = segue.destination as? GridEditorViewController {
                vc.fruitValue = fruitValue
                vc.saveClosure = { newValue in
                    data[indexPath.section][indexPath.row] = newValue
                    self.tableView.reloadData()
                }
            }
        }
    }
}

