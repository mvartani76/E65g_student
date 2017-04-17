//
//  GridView.swift
//  Assignment3
//
//  Created by Michael Vartanian on 3/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

@IBDesignable class GridView: UIView {
    
    @IBInspectable var gridRows: Int = 10
    @IBInspectable var gridCols: Int = 10
    
    @IBInspectable var livingColor: UIColor = UIColor.init(
                            red: CGFloat(0/255),
                            green: CGFloat(0/255),
                            blue: CGFloat(0/255),
                            alpha: CGFloat(1.0))
    @IBInspectable var emptyColor: UIColor = UIColor.init(
                            red: CGFloat(255/255),
                            green: CGFloat(255/255),
                            blue: CGFloat(255/255),
                            alpha: CGFloat(1.0))
    @IBInspectable var bornColor: UIColor = UIColor.init(
                            red: CGFloat(0/255),
                            green: CGFloat(0/255),
                            blue: CGFloat(244/255),
                            alpha: CGFloat(1.0))
    @IBInspectable var diedColor: UIColor = UIColor.init(
                            red: CGFloat(0/255),
                            green: CGFloat(130/255),
                            blue: CGFloat(130/255),
                            alpha: CGFloat(1.0))
    @IBInspectable var gridColor: UIColor = UIColor.init(
                            red: CGFloat(0/255),
                            green: CGFloat(0/255),
                            blue: CGFloat(0/255),
                            alpha: CGFloat(1.0))
    @IBInspectable var gridWidth: CGFloat = CGFloat(2.0)
    
    var drawGrid: GridViewDataSource?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let drawSize = CGSize(
            width: rect.size.width / CGFloat(gridCols),
            height: rect.size.height / CGFloat(gridRows)
        )
        let base = rect.origin
        
        // Create separate forEach loop for gridlines
        // Not the most efficient but it is cleaner and easier to handle
        // the extra horizontal/vertical gridlines
        (0 ... gridCols).forEach {
            // Draw the Vertical Lines
            drawLine(
                start: CGPoint(
                    x: rect.origin.x + (CGFloat($0)*drawSize.width),
                    y: rect.origin.y),
                end: CGPoint(
                    x: rect.origin.x + (CGFloat($0)*drawSize.width),
                    y: rect.origin.y + rect.size.height),
                lineWidth: gridWidth,
                lineColor: gridColor)
        }
        (0 ... gridRows).forEach {
            // Draw the Horizontal Lines
            drawLine(
                start: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y + (CGFloat($0)*drawSize.height)),
                end: CGPoint(
                    x: rect.origin.x + rect.size.width,
                    y: rect.origin.y + (CGFloat($0)*drawSize.height)),
                lineWidth: gridWidth,
                lineColor: gridColor)
        }

        // Draw Circles
        // Add gridWidth to each of the origin values and subtract 2*gridWidth from the width/height to fit the circle inside the gridlines with no overlap
        (0 ..< gridCols).forEach { i in
            (0 ..< gridRows).forEach { j in
                let origin = CGPoint(
                    x: base.x + (CGFloat(i) * drawSize.width) + gridWidth,
                    y: base.y + (CGFloat(j) * drawSize.height) + gridWidth
                )
                
                let subDrawSize = CGSize(
                    width: rect.size.width / CGFloat(gridCols) - 2*gridWidth,
                    height: rect.size.height / CGFloat(gridRows) - 2*gridWidth
                )
                
                let subRect = CGRect(
                    origin: origin,
                    size: subDrawSize
                )
                let path = UIBezierPath(ovalIn: subRect)
                
                
                if let drawGrid = drawGrid {
                
                    // Set the color based on the CellState using the description method
                    switch drawGrid[(j,i)].description()
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
    }
    
    // Function to draw lines
    func drawLine(start: CGPoint, end: CGPoint, lineWidth: CGFloat, lineColor: UIColor){
        //create the path
        let path = UIBezierPath()

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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = nil

        // Engine has updated based on touch events so we need to send out a notification
        let engine = StandardEngine.shared()
        engine.engineUpdateNotify()
    }
    
    var lastTouchedPosition: GridPosition?
    
    func process(touches: Set<UITouch>) -> GridPosition? {
        guard touches.count == 1 else { return nil }
        let pos = convert(touch: touches.first!)
        guard lastTouchedPosition?.row != pos.row
            || lastTouchedPosition?.col != pos.col
            else { return pos }

        if drawGrid != nil {
            drawGrid![pos.row, pos.col] = drawGrid![pos.row, pos.col].isAlive ? .empty : .alive
            setNeedsDisplay()
        }
        
        return pos
    }
    
    func convert(touch: UITouch) -> GridPosition {
        let touchY = touch.location(in: self).y
        let gridHeight = frame.size.height
        let row = touchY / gridHeight * CGFloat(gridRows)
        
        let touchX = touch.location(in: self).x
        let gridWidth = frame.size.width
        let col = touchX / gridWidth * CGFloat(gridCols)
        
        return GridPosition(row: Int(row), col: Int(col))
    }
    
}
