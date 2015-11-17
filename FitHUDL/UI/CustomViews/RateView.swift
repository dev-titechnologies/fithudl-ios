   //
//  RateView.swift
//  FitHUDL
//
//  Created by Ti Technologies on 16/10/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

protocol FeedbackRateDelegate
{
    
    func rateData(data : Int)
}

class RateView: UIView {
    
    @IBOutlet weak var starOne: UIButton!
    @IBOutlet weak var starTwo: UIButton!
    @IBOutlet weak var starThree: UIButton!
    @IBOutlet weak var starFour: UIButton!
    @IBOutlet weak var starFive: UIButton!
    
    var delegate : FeedbackRateDelegate?
    var view: UIView!
    
    @IBAction func feedRate(sender: UIButton) {
        let selectedState = sender.selected
        
        if sender == starOne {
            if !selectedState {
                self.delegate?.rateData(1)
            } else {
                self.delegate?.rateData(0)
                starTwo.selected    = false
                starThree.selected  = false
                starFour.selected   = false
                starFive.selected   = false
            }
        } else if sender == starTwo {
            if !selectedState {
                self.delegate?.rateData(2)
                starOne.selected = true
            } else {
                self.delegate?.rateData(1)
                starThree.selected  = false
                starFour.selected   = false
                starFive.selected   = false
            }
        } else if sender == starThree {
            if !selectedState {
                self.delegate?.rateData(3)
                starOne.selected    = true
                starTwo.selected    = true
            } else {
                self.delegate?.rateData(2)
                starFour.selected   = false
                starFive.selected   = false
            }
        } else if sender == starFour{
            if !selectedState {
                self.delegate?.rateData(4)
                starOne.selected    = true
                starTwo.selected    = true
                starThree.selected  = true
            } else {
                self.delegate?.rateData(3)
                starFive.selected   = false
            }
        } else if sender == starFive{
            if !selectedState {
                self.delegate?.rateData(5)
                starOne.selected    = true
                starTwo.selected    = true
                starThree.selected  = true
                starFour.selected   = true
            } else {
                self.delegate?.rateData(4)
            }
        }
        sender.selected = !selectedState
    }
    
    func showRateView(rateCount : Int){
        switch(rateCount) {
        case 1:
            starOne.selected    = true
            starTwo.selected    = false
            starThree.selected  = false
            starFour.selected   = false
            starFive.selected   = false
        case 2:
            starOne.selected    = true
            starTwo.selected    = true
            starThree.selected  = false
            starFour.selected   = false
            starFive.selected   = false
        case 3:
            starOne.selected    = true
            starTwo.selected    = true
            starThree.selected  = true
            starFour.selected   = false
            starFive.selected   = false
        case 4:
            starOne.selected    = true
            starTwo.selected    = true
            starThree.selected  = true
            starFour.selected   = true
            starFive.selected   = false
        case 5:
            starOne.selected    = true
            starTwo.selected    = true
            starThree.selected  = true
            starFour.selected   = true
            starFive.selected   = true
        default:
            starOne.selected    = false
            starTwo.selected    = false
            starThree.selected  = false
            starFour.selected   = false
            starFive.selected   = false
        }
        
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
