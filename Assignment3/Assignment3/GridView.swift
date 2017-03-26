//
//  GridView.swift
//  Assignment3
//
//  Created by Michael Vartanian on 3/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

@IBDesignable class GridView: UIView {
    
    @IBInspectable var size: Int = 20 {
        didSet {
            drawGrid = Grid(size, size)
        }
    }
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
    @IBInspectable var gridWidth = CGFloat(1.0)
    
    var drawGrid = Grid(20,20)
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let drawSize = CGSize(
            width: rect.size.width / CGFloat(size),
            height: rect.size.height / CGFloat(size)
        )
        let base = rect.origin
        
        // Create separate forEach loop for gridlines
        // Not the most efficient but it is cleaner and easier to handle
        // the extra horizontal/vertical gridlines
        (0 ... size).forEach {
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
    }
    
    var lastTouchedPosition: Position?
    
    func process(touches: Set<UITouch>) -> Position? {
        guard touches.count == 1 else { return nil }
        let pos = convert(touch: touches.first!)
        guard lastTouchedPosition?.row != pos.row
            || lastTouchedPosition?.col != pos.col
            else { return pos }
        
        drawGrid[pos] = drawGrid[pos].toggle(value: drawGrid[pos])
        setNeedsDisplay()
        return pos
    }
    
    func convert(touch: UITouch) -> Position {
        let touchY = touch.location(in: self).y
        let gridHeight = frame.size.height
        let row = touchY / gridHeight * CGFloat(size)
        let touchX = touch.location(in: self).x
        let gridWidth = frame.size.width
        let col = touchX / gridWidth * CGFloat(size)
        let position = (row: Int(row), col: Int(col))
        return position
    }
}
