//
//  RateView.swift
//  FitHUDL
//
//  Created by Ti Technologies on 16/10/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class RateView: UIView {
    
    let noStarImage   = UIImage(named: "emptystar")
    let halfStarImage = UIImage(named: "halfstar")
    let fullStarImage = UIImage(named: "fullstar")
    
    var view: UIView!
    
    @IBAction func rateOne(sender: AnyObject) {
        println("Rate One")
    }
    
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.backgroundColor  = UIColor.clearColor()
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle  = NSBundle(forClass: self.dynamicType)
        let nib     = UINib(nibName: "RateView", bundle: bundle)
        let view    = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    


    
}
