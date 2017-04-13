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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Row Stepper Event Handling
    @IBAction func rowStep(_ sender: UIStepper) {
        let numRows = Int(sender.value)
        numRowsTextField.text = "\(numRows)"
        engine.updateNumRows(Rows: numRows)
    }

    //MARK: Column Stepper Event Handling
    @IBAction func colStep(_ sender: UIStepper) {
    }
    
    //MARK: Row TextField Event Handling
    @IBAction func rowEditingEndedOnExit(_ sender: UITextField) {
    }
    
    //MARK: Col TextField Event Handling
    @IBAction func colEditingEndedOnExit(_ sender: UITextField) {
    }
    
}

