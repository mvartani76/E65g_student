//
//  InstrumentationViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

let finalProjectURL = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"

struct GridConfig {
    var title: String
    var contents: [[Int]]
    var maxDim: Int
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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var engine: StandardEngine!
    var gridConfigs: [GridConfig] = []
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.gray;
        activityIndicator.center = view.center;
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        engine = StandardEngine.shared()
        refreshOnOff.setOn(false, animated: false)
        
        activityIndicator.startAnimating()

        // Load Configuration from UserDefaults
        loadConfigDefaults(config_gridStruct: "simConfig_gridStruct", config_NumRows: "simConfig_rows", config_NumCols: "simConfig_cols")
        
        // Set the stepper/textfield row/col values
        setRowColUIValuesFrom(engine: engine)
        
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
                let gridConfig = GridConfig(title: jsonTitle, contents: jsonContents, maxDim: maxDim)
                self.gridConfigs.append(gridConfig)
            }
            
            OperationQueue.main.addOperation ({
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            })
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        engine = StandardEngine.shared()
        
        navigationController?.isNavigationBarHidden = false
        
        setRowColUIValuesFrom(engine: engine)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Row Stepper Event Handling
    @IBAction func rowStep(_ sender: UIStepper) {
        let numRows = Int(sender.value)
        numRowsTextField.text = "\(numRows)"
        StandardEngine.shared().updateNumRowsOrCols(rowOrCol: "row", numRows: numRows, numCols: engine.cols)
    }

    //MARK: Column Stepper Event Handling
    @IBAction func colStep(_ sender: UIStepper) {
        let numCols = Int(sender.value)
        numColsTextField.text = "\(numCols)"
        StandardEngine.shared().updateNumRowsOrCols(rowOrCol: "col", numRows: engine.rows, numCols: numCols)
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
        StandardEngine.shared().updateNumRowsOrCols(rowOrCol: "row", numRows: val, numCols: engine.cols)
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
        StandardEngine.shared().updateNumRowsOrCols(rowOrCol: "col", numRows: engine.rows, numCols: val)
    }

    //MARK: Timer RefreshRate Event Handling
    @IBAction func updateTimerRefreshRate(_ sender: UISlider) {
        engine.refreshTimer?.invalidate()
        engine.refreshRate = 1 / Double(Double(sender.value))
    }
    
    @IBAction func toggleTimer(_ sender: UISwitch) {
        StandardEngine.shared().toggleTimer(switchOn: refreshOnOff.isOn)
    }

    //MARK: Add Config Event Handler
    @IBAction func addConfig(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Add Grid Config",
                                      message: "Please enter a name for the Grid Config and a positive integer for the Grid Size.",
                                      preferredStyle: .alert)
        
        // Submit button
        let submitAction = UIAlertAction(title: "Submit", style: .default, handler: { (action) -> Void in

            if let configMaxDim = alert.textFields?[1] {
                if let configMaxDim = configMaxDim.text {
                    // Check if Grid Size Text Field is not an integer
                    if !(Int(configMaxDim) != nil) {
                        self.setAlertErrorWith(errorTitle: "Grid Size Error", errorMessage: "Please enter an Integer Grid Size")
                    }
                    // Check if input text field integer is less than zero
                    else if (Int(configMaxDim)! <= 0) {
                        self.setAlertErrorWith(errorTitle: "Grid Size Error", errorMessage: "Grid Size must be Positive")
                    }
                    else
                    {
                        // Grid Size value is verified, now lets check the Config Name
                        if let configTitle = alert.textFields?[0] {
                            if let configTitle = configTitle.text {
                                // Check if a Config Name has been entered
                                if (configTitle == "") {
                                    self.setAlertErrorWith(errorTitle: "Config Name Error", errorMessage: "Missing Config Name")
                                }
                                else
                                {
                                    let newConfig = GridConfig(title: configTitle, contents: [], maxDim: Int(configMaxDim)!/2)
                                    self.gridConfigs.insert(newConfig, at: 0)
                                    
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        // Add configTitle textField and customize it
        saveAlertTextFieldWith(placeholder: "Config Name", alert: alert)

        // Add configMaxNum textField and customize it
        saveAlertTextFieldWith(placeholder: "Grid Size", alert: alert)
        
        // Add action buttons and present the Alert
        alert.addAction(submitAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
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
        return gridConfigs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "basic"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let label = cell.contentView.subviews.first as! UILabel
        label.text = gridConfigs[indexPath.item].title

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        if let indexPath = indexPath {
            let gridStruct = gridConfigs[indexPath.row]
            if let vc = segue.destination as? GridEditorViewController {
                navigationItem.title = "Cancel"
                vc.gridStruct = gridStruct
                vc.saveClosure = { newValue in
                    self.gridConfigs[indexPath.row].contents = []
                    for j in 0..<(newValue.contents.count)
                    {
                        self.gridConfigs[indexPath.row].contents.append(newValue.contents[j])
                    }
                    self.gridConfigs[indexPath.row].title = newValue.title
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // Function to save alert textfield configuration
    func saveAlertTextFieldWith(placeholder: String, alert: UIAlertController) {
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .numberPad
            textField.autocorrectionType = .default
            textField.placeholder = placeholder
            textField.clearButtonMode = .whileEditing
        }
    }
    
    // Function to load configuration values from user defaults
    func loadConfigDefaults(config_gridStruct: String, config_NumRows: String, config_NumCols: String) {
        
        guard let gridDict = defaults.object(forKey: config_gridStruct) else { return }
        guard let gridRows = defaults.object(forKey: config_NumRows) else { return }
        guard let gridCols = defaults.object(forKey: config_NumCols) else { return }
        
        let gridDict2 = gridDict as! NSDictionary
        let gridValues = gridDict2["gridStructContents"] as! [[Int]]
        let gridStruct = GridConfig(title: "", contents: gridValues, maxDim: (gridRows as! Int)/2)
        
        engine.grid = engine.loadGridFrom(gridStruct: gridStruct)
        engine.rows = gridRows as! Int
        engine.cols = gridCols as! Int
    }
    
    // Function to set the stepper and text field values for rows/cols
    func setRowColUIValuesFrom(engine: StandardEngine) {
        rowStepper.value = Double(engine.rows)
        colStepper.value = Double(engine.cols)
    
        numRowsTextField.text = "\(engine.rows)"
        numColsTextField.text = "\(engine.cols)"
    }
    
    // Function that presents error alerts with Dismiss action
    func setAlertErrorWith(errorTitle: String, errorMessage: String) {
        let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}

