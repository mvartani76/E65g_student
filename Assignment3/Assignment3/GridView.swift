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
                            red: CGFloat(0/255),
                            green: CGFloat(0/255),
                            blue: CGFloat(0/255),
                            alpha: CGFloat(1.0))
    @IBInspectable var bornColor = UIColor.init(
                            red: CGFloat(0/255),
                            green: CGFloat(0/255),
                            blue: CGFloat(0/255),
                            alpha: CGFloat(1.0))
    @IBInspectable var diedColor = UIColor.init(
                            red: CGFloat(0/255),
                            green: CGFloat(0/255),
                            blue: CGFloat(0/255),
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
        (0 ..< size).forEach { i in
            (0 ..< size).forEach { j in
                let origin = CGPoint(
                    x: base.x + (CGFloat(i) * drawSize.width),
                    y: base.y + (CGFloat(j) * drawSize.height)
                )
                let subRect = CGRect(
                    origin: origin,
                    size: drawSize
                )
                let path = UIBezierPath(ovalIn: subRect)
                
                
                print(drawGrid[(0,0)])
                
                gridColor.setFill()
                path.fill()
            }
        }
        
        
    }

}
