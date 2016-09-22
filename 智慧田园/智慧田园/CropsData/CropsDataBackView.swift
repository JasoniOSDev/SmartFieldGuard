//
//  CropsDataBackView.swift
//  智慧田园
//
//  Created by jason on 2016/9/20.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class CropsDataBackView: UIView {
    
    var lineArray = [CAShapeLayer]()
    var pathArray = [UIBezierPath]()
    var pathAnimation:CABasicAnimation{
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = 0
        animation.toValue = 1
        
        return animation
    }
    func strokeLine(startPoint:[CGPoint],endPoint:[CGPoint]){
        setPathArray(startPoint, endPoint: endPoint)
        for i in 0..<startPoint.count{
            UIGraphicsBeginImageContext(self.frame.size)
            let path = pathArray[i]
            let layer = lineArray[i]
            layer.path = path.CGPath
            UIGraphicsEndImageContext()
        }
    }
    
    func setPathArray(startPoint:[CGPoint],endPoint:[CGPoint]){
        pathArray.removeAll(keepCapacity: false)
        if(lineArray.count < startPoint.count){
            let num = lineArray.count
            for _ in num ..< startPoint.count{
                let layer = CAShapeLayer()
                layer.strokeColor = UIColor.whiteColor().CGColor
                layer.lineWidth = 1
                layer.fillColor = UIColor.whiteColor().CGColor
                self.layer.addSublayer(layer)
                lineArray.append(layer)
            }
        }
        for i in 0..<startPoint.count{
            let path = UIBezierPath()
            let start = startPoint[i]
            let end = endPoint[i]
            if(start.x == end.x || start.y == end.y){
                path.moveToPoint(start)
                path.addArcWithCenter(start, radius: 2, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
                path.addLineToPoint(end)
                path.moveToPoint(end)
                path.addArcWithCenter(end, radius: 2, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
                path.closePath()
                pathArray.append(path)
                continue
            }
//            var direction = start.y - end.y < 0 ? 1 : 0
//            direction = (direction << 1) + (start.x - end.x < 0 ? 1:0)
//            //顺时针0132
//            var midPoint:CGPoint
//            switch direction {
//            case 0:
//                midPoint = CGPointMake((start.x + end.x)/2, (start.y + (start.y + end.y)/2)/2)
//            case 1:
//                midPoint = CGPointMake((start.x + end.x)/2, (start.y + (start.y + end.y)/2)/2)
//            default:
//                <#code#>
//            }
            let midPoint = CGPointMake((start.x + end.x)/2, (start.y + (start.y + end.y)/2)/2)
            path.moveToPoint(start)
            path.addArcWithCenter(start, radius: 2, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
            path.addLineToPoint(midPoint)
            path.moveToPoint(midPoint)
            path.addLineToPoint(end)
            path.moveToPoint(end)
            path.addArcWithCenter(end, radius: 2, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
            path.closePath()
            pathArray.append(path)
        }
        
    }

}
