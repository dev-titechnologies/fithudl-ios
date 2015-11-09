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
    let noStarImage   = UIImage(named: "emptystar")
    let halfStarImage = UIImage(named: "halfstar")
    let fullStarImage = UIImage(named: "fullstar")
    var view: UIView!
    
    @IBAction func feedRate(sender: UIButton)
    {
        
        let button_image = sender.imageForState(UIControlState.Normal)
        
        if sender == starOne {
            
            if button_image == noStarImage {
                
                self.delegate?.rateData(1)
                starOne.setImage(fullStarImage, forState: UIControlState.Normal)
                
                
            }
            else
            {
                self.delegate?.rateData(0)
                starOne.setImage(noStarImage, forState: UIControlState.Normal)
                starTwo.setImage(noStarImage, forState: UIControlState.Normal)
                starThree.setImage(noStarImage, forState: UIControlState.Normal)
                starFour.setImage(noStarImage, forState: UIControlState.Normal)
                starFive.setImage(noStarImage, forState: UIControlState.Normal)
            }
        }
        else if sender == starTwo{
            if button_image == noStarImage
            {
                self.delegate?.rateData(2)
                starOne.setImage(fullStarImage, forState: UIControlState.Normal)
                starTwo.setImage(fullStarImage, forState: UIControlState.Normal)
            }
            else {
                self.delegate?.rateData(1)
                starTwo.setImage(noStarImage, forState: UIControlState.Normal)
                starThree.setImage(noStarImage, forState: UIControlState.Normal)
                starFour.setImage(noStarImage, forState: UIControlState.Normal)
                starFive.setImage(noStarImage, forState: UIControlState.Normal)
                
            }
            
        }
        else if sender == starThree {
            if button_image == noStarImage{
                self.delegate?.rateData(3)
                starOne.setImage(fullStarImage, forState: UIControlState.Normal)
                starTwo.setImage(fullStarImage, forState: UIControlState.Normal)
                starThree.setImage(fullStarImage, forState: UIControlState.Normal)
                
            }
            else {
                self.delegate?.rateData(2)
                starThree.setImage(noStarImage, forState: UIControlState.Normal)
                starFour.setImage(noStarImage, forState: UIControlState.Normal)
                starFive.setImage(noStarImage, forState: UIControlState.Normal)
                
            }
        }
        else if sender == starFour{
            if button_image == noStarImage {
                self.delegate?.rateData(4)
                starOne.setImage(fullStarImage, forState: UIControlState.Normal)
                starTwo.setImage(fullStarImage, forState: UIControlState.Normal)
                starThree.setImage(fullStarImage, forState: UIControlState.Normal)
                starFour.setImage(fullStarImage, forState: UIControlState.Normal)
            }
            else {
                self.delegate?.rateData(3)
                starFour.setImage(noStarImage, forState: UIControlState.Normal)
                starFive.setImage(noStarImage, forState: UIControlState.Normal)
            }
        }
        else if sender == starFive{
            if button_image == noStarImage {
                self.delegate?.rateData(5)
                starOne.setImage(fullStarImage, forState: UIControlState.Normal)
                starTwo.setImage(fullStarImage, forState: UIControlState.Normal)
                starThree.setImage(fullStarImage, forState: UIControlState.Normal)
                starFour.setImage(fullStarImage, forState: UIControlState.Normal)
                starFive.setImage(fullStarImage, forState: UIControlState.Normal)
            }
            else {
                self.delegate?.rateData(4)
                starFive.setImage(noStarImage, forState: UIControlState.Normal)
            }
            
        }
    }
    
    func showRateView(rateCount : Int)
    {
        switch(rateCount) {
        case 0:
            starOne.setImage(noStarImage, forState: UIControlState.Normal)
            starTwo.setImage(noStarImage, forState: UIControlState.Normal)
            starThree.setImage(noStarImage, forState: UIControlState.Normal)
            starFour.setImage(noStarImage, forState: UIControlState.Normal)
            starFive.setImage(noStarImage, forState: UIControlState.Normal)
            
            break
        case 1:
            starOne.setImage(fullStarImage, forState: UIControlState.Normal)
            starTwo.setImage(noStarImage, forState: UIControlState.Normal)
            starThree.setImage(noStarImage, forState: UIControlState.Normal)
            starFour.setImage(noStarImage, forState: UIControlState.Normal)
            starFive.setImage(noStarImage, forState: UIControlState.Normal)
            break
        case 2:
            starOne.setImage(fullStarImage, forState: UIControlState.Normal)
            starTwo.setImage(fullStarImage, forState: UIControlState.Normal)
            starThree.setImage(noStarImage, forState: UIControlState.Normal)
            starFour.setImage(noStarImage, forState: UIControlState.Normal)
            starFive.setImage(noStarImage, forState: UIControlState.Normal)
            break
            
        case 3:
            starOne.setImage(fullStarImage, forState: UIControlState.Normal)
            starTwo.setImage(fullStarImage, forState: UIControlState.Normal)
            starThree.setImage(fullStarImage, forState: UIControlState.Normal)
            starFour.setImage(noStarImage, forState: UIControlState.Normal)
            starFive.setImage(noStarImage, forState: UIControlState.Normal)
            break
        case 4:
            starOne.setImage(fullStarImage, forState: UIControlState.Normal)
            starTwo.setImage(fullStarImage, forState: UIControlState.Normal)
            starThree.setImage(fullStarImage, forState: UIControlState.Normal)
            starFour.setImage(fullStarImage, forState: UIControlState.Normal)
            starFive.setImage(noStarImage, forState: UIControlState.Normal)
            break
        case 5:
            starOne.setImage(fullStarImage, forState: UIControlState.Normal)
            starTwo.setImage(fullStarImage, forState: UIControlState.Normal)
            starThree.setImage(fullStarImage, forState: UIControlState.Normal)
            starFour.setImage(fullStarImage, forState: UIControlState.Normal)
            starFive.setImage(fullStarImage, forState: UIControlState.Normal)
            break
        default:
            starOne.setImage(noStarImage, forState: UIControlState.Normal)
            starTwo.setImage(noStarImage, forState: UIControlState.Normal)
            starThree.setImage(noStarImage, forState: UIControlState.Normal)
            starFour.setImage(noStarImage, forState: UIControlState.Normal)
            starFive.setImage(noStarImage, forState: UIControlState.Normal)
            break
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
