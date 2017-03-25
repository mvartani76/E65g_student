//
//  ViewController.swift
//  Assignment3
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var stepButton: UIButton!
    
    //var drawGrid = Grid(5,5){ _,_ in arc4random_uniform(3) == 2 ? .alive : .empty }
    /*var drawGrid = GridView.init(
        size: 5,
        gridWidth: CGFloat(1.0),
        livingColor: UIColor.black,
        emptyColor: UIColor.black,
        bornColor: UIColor.black,
        diedColor: UIColor.black,
        gridColor: UIColor.black)
    */
    var myGridViewClass = GridView(frame: CGRect(x: 47.5, y: 193.5, width: 280, height: 280) )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.addSubview(myGridViewClass)
        //self.view.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func stepButtonAction(_ sender: Any) {
        myGridViewClass.layoutIfNeeded()
        myGridViewClass.drawGrid = myGridViewClass.drawGrid.next()
        //myGridViewClass.drawGrid = Grid(5,5){ _,_ in arc4random_uniform(3) == 2 ? .alive : .alive }
        //myGridViewClass.drawLine(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 15, y: 15), lineWidth: CGFloat(4.0),lineColor: UIColor.red)
        myGridViewClass.setNeedsDisplay()
        //myGridViewClass.layoutIfNeeded()
    }

}

