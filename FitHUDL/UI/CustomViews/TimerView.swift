//
//  TimerView.swift
//  FitHUDL
//
//  Created by Ti Technologies on 16/11/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class TimerView: UIView {
    var timerLabel: UILabel!
    var pathLayer   = CAShapeLayer()
    
    override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
        if self.subviews.count == 0 {
        }

        return self
    }
    
    func resetView() {
        let duration = NSTimeInterval(appDelegate.configDictionary[TimeOut.sessionDuration]!.integerValue*secondsValue)
        animateCircle(duration-1)
    }
    
    func animateCircle(duration: NSTimeInterval) {
        let animation       = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue   = 1
        animation.duration  = duration
        animation.delegate  = self
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        pathLayer.strokeEnd     = 1.0
        pathLayer.addAnimation(animation, forKey: "animateCircle")
    }
    
    override func animationDidStart(anim: CAAnimation!) {
        println("animtion started")
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        println("animation stopped")
    }
    
//  Only override drawRect: if you perform custom drawing.
//  An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
//      Drawing code
        let center              = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let radius: CGFloat     = max(bounds.width, bounds.height)
        self.layer.cornerRadius = radius/2
        let arcWidth: CGFloat   = 2
        let startAngle: CGFloat = CGFloat(-M_PI_2)
        let endAngle: CGFloat   = CGFloat(3/2*M_PI)
        var path                = UIBezierPath(arcCenter: center, radius: radius/2-arcWidth/2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        pathLayer.path          = path.CGPath
        pathLayer.fillColor     = UIColor.clearColor().CGColor
        pathLayer.strokeColor   = AppColor.boxBorderColor.CGColor
        pathLayer.lineWidth     = arcWidth
        layer.addSublayer(pathLayer)
    }

}
