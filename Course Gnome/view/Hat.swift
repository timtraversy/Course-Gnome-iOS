//
//  Hat.swift
//  Course Gnome
//
//  Created by Tim Traversy on 1/13/18.
//  Copyright © 2018 (null). All rights reserved.
//
//  Generated by PaintCode
//  http://www.paintcodeapp.com
//
//  This code was generated by Trial version of PaintCode, therefore cannot be used for commercial purposes.
//



import UIKit

public class Hat {

    func getHatPath() -> CGPath {
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 59.32, y: 95.49))
        bezier2Path.addCurve(to: CGPoint(x: 29.66, y: 102.11), controlPoint1: CGPoint(x: 59.32, y: 99.14), controlPoint2: CGPoint(x: 46.04, y: 102.11))
        bezier2Path.addCurve(to: CGPoint(x: 0, y: 95.49), controlPoint1: CGPoint(x: 13.28, y: 102.11), controlPoint2: CGPoint(x: 0, y: 99.14))
        bezier2Path.addCurve(to: CGPoint(x: 29.66, y: 88.86), controlPoint1: CGPoint(x: 0, y: 91.83), controlPoint2: CGPoint(x: 13.28, y: 88.86))
        bezier2Path.addCurve(to: CGPoint(x: 59.32, y: 95.49), controlPoint1: CGPoint(x: 46.04, y: 88.86), controlPoint2: CGPoint(x: 59.32, y: 91.83))
        bezier2Path.close()
        bezier2Path.move(to: CGPoint(x: 59.32, y: 95.26))
        bezier2Path.addLine(to: CGPoint(x: 31.25, y: 1.3))
        bezier2Path.addLine(to: CGPoint(x: 31.25, y: 1.31))
        bezier2Path.addCurve(to: CGPoint(x: 28.99, y: 0.02), controlPoint1: CGPoint(x: 30.99, y: 0.34), controlPoint2: CGPoint(x: 29.98, y: -0.24))
        bezier2Path.addCurve(to: CGPoint(x: 27.69, y: 1.28), controlPoint1: CGPoint(x: 28.36, y: 0.18), controlPoint2: CGPoint(x: 27.87, y: 0.66))
        bezier2Path.addLine(to: CGPoint(x: 0.14, y: 94.82))
        bezier2Path.lineWidth = 2
        return bezier2Path.cgPath
    }
}