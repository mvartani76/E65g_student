//
//  StatisticsViewController.swift
//  Assignment4
//
//  Created by Michael Vartanian on 4/8/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    @IBOutlet weak var aliveCountLabel: UILabel!
    @IBOutlet weak var bornCountLabel: UILabel!
    @IBOutlet weak var deadCountLabel: UILabel!
    @IBOutlet weak var emptyCountLabel: UILabel!
    
    var engine: StandardEngine!
    
    func updateCounts(withGrid: GridProtocol) {
        
        var aliveCount = 0
        var bornCount = 0
        var deadCount = 0
        var emptyCount = 0
        
        (0 ..< withGrid.size.rows).forEach { i in
            (0 ..< withGrid.size.cols).forEach { j in
                
                switch withGrid[j,i].description()
                {
                    case "alive":
                        aliveCount = aliveCount + 1
                    case "born":
                        bornCount = bornCount + 1
                    case "dead":
                        deadCount = deadCount + 1
                    default:
                        emptyCount = emptyCount + 1
                }
            }
        }
        aliveCountLabel.text = String(aliveCount)
        bornCountLabel.text = String(bornCount)
        deadCountLabel.text = String(deadCount)
        emptyCountLabel.text = String(emptyCount)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        engine = StandardEngine.shared()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        engine = StandardEngine.shared()
        updateCounts(withGrid: engine.grid)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
