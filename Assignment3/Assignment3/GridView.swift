//
//  GridView.swift
//  Assignment3
//
//  Created by Michael Vartanian on 3/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

@IBDesignable class GridView: UIView {
    
    @IBInspectable var size: Int = 5
    @IBInspectable var livingColor = UIColor.init(
                            red: CGFloat(0/255),
                            green: CGFloat(0/255),
                            blue: CGFloat(0/255),
                            alpha: CGFloat(1.0))
    @IBInspectable var emptyColor = UIColor.init(
                            red: CGFloat(255/255),
                            green: CGFloat(255/255),
                            blue: CGFloat(255/255),
                            alpha: CGFloat(1.0))
    @IBInspectable var bornColor = UIColor.init(
                            red: CGFloat(0/255),
                            green: CGFloat(0/255),
                            blue: CGFloat(244/255),
                            alpha: CGFloat(1.0))
    @IBInspectable var diedColor = UIColor.init(
                            red: CGFloat(0/255),
                            green: CGFloat(130/255),
                            blue: CGFloat(130/255),
                            alpha: CGFloat(1.0))
    @IBInspectable var gridColor = UIColor.init(
                            red: CGFloat(0/255),
                            green: CGFloat(0/255),
                            blue: CGFloat(0/255),
                            alpha: CGFloat(1.0))
    @IBInspectable var gridWidth = CGFloat(1.0)
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        //var drawGrid = Grid(self.size, self.size)
        var drawGrid = Grid(5,5){ _,_ in arc4random_uniform(3) == 2 ? .alive : .empty }
        
        let drawSize = CGSize(
            width: rect.size.width / CGFloat(size),
            height: rect.size.height / CGFloat(size)
        )
        let base = rect.origin
        
        let lineWidth: CGFloat = gridWidth
        
        // Create separate forEach loop for gridlines
        // Not the most efficient but it is cleaner and easier to handle
        // the extra horizontal/vertical gridlines
        (0 ... size).forEach { i in
            // Draw the Vertical Lines
            drawLine(
                start: CGPoint(
                    x: rect.origin.x + (CGFloat(i)*drawSize.width),
                    y: rect.origin.y),
                end: CGPoint(
                    x: rect.origin.x + (CGFloat(i)*drawSize.width),
                    y: rect.origin.y + rect.size.height),
                lineWidth: gridWidth,
                lineColor: gridColor)
            
            // Draw the Horizontal Lines
            drawLine(
                start: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y + (CGFloat(i)*drawSize.height)),
                end: CGPoint(
                    x: rect.origin.x + rect.size.width,
                    y: rect.origin.y + (CGFloat(i)*drawSize.height)),
                lineWidth: gridWidth,
                lineColor: gridColor)
        }

        // Draw Circles
        (0 ..< size).forEach { i in
            (0 ..< size).forEach { j in
                let origin = CGPoint(
                    x: base.x + (CGFloat(i) * drawSize.width) + gridWidth + 1,
                    y: base.y + (CGFloat(j) * drawSize.height) + gridWidth + 1
                )
                
                let subDrawSize = CGSize(
                    width: rect.size.width / CGFloat(size) - gridWidth - 2,
                    height: rect.size.height / CGFloat(size) - gridWidth - 2
                )
                
                let subRect = CGRect(
                    origin: origin,
                    size: subDrawSize
                )
                let path = UIBezierPath(ovalIn: subRect)
                
                switch drawGrid[(i,j)].description()
                {
                    case "empty":
                        emptyColor.setFill()
                    case "alive":
                        livingColor.setFill()
                    case "born":
                        bornColor.setFill()
                    case "dead":
                        diedColor.setFill()
                    default:
                        emptyColor.setFill()
                }
                
                path.fill()
            }
        }
        
    }
    
    // Function to draw lines
    func drawLine(start: CGPoint, end: CGPoint, lineWidth: CGFloat, lineColor: UIColor){
        //create the path
        let path = UIBezierPath()
        /*var start = CGPoint(
            x: rect.origin.x + (CGFloat(i)*drawSize.width),
            y: rect.origin.y
        )
        var end = CGPoint(
            x: rect.origin.x + (CGFloat(i)*drawSize.width),
            y: rect.origin.y + rect.size.height
        )
        */
        //set the path's line width to the height of the stroke
        path.lineWidth = lineWidth
        
        //move the initial point of the path
        //to the start of the horizontal stroke
        path.move(to: start)
        
        //add a point to the path at the end of the stroke
        path.addLine(to: end)
        
        //draw the stroke
        lineColor.setStroke()
        path.stroke()
        
    }
}
