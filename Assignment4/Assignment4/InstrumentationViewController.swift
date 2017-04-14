//
//  InstrumentationViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class InstrumentationViewController: UIViewController {
    
    @IBOutlet weak var rowStepper: UIStepper!
    @IBOutlet weak var colStepper: UIStepper!
    @IBOutlet weak var refreshRate: UISlider!
    @IBOutlet weak var refreshOnOff: UISwitch!
    @IBOutlet weak var numRowsTextField: UITextField!
    @IBOutlet weak var numColsTextField: UITextField!
    
    var engine: StandardEngine!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        engine = StandardEngine.shared()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        engine = StandardEngine.shared()
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
}

