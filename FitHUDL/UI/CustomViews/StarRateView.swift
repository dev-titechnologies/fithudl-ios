//
//  StarRateView.swift
//  FitHUDL
//
//  Created by Ti Technologies on 30/09/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class StarRateView: UIView {

    let noStarImage   = UIImage(named: "emptystar")
    let halfStarImage = UIImage(named: "halfstar")
    let fullStarImage = UIImage(named: "fullstar")
    var view: UIView!
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.backgroundColor  = UIColor.clearColor()
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle  = NSBundle(forClass: self.dynamicType)
        let nib     = UINib(nibName: "StarRateView", bundle: bundle)
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
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func setStarViewValue(rating: Float) {
        let star1 = viewWithTag(10) as! UIImageView
        let star2 = viewWithTag(11) as! UIImageView
        let star3 = viewWithTag(12) as! UIImageView
        let star4 = viewWithTag(13) as! UIImageView
        let star5 = viewWithTag(14) as! UIImageView
        switch rating {
        case 0.5:
            star1.image = halfStarImage
        case 1:
            star1.image = fullStarImage
        case 1.5:
            star1.image = fullStarImage
            star2.image = halfStarImage
        case 2:
            star1.image = fullStarImage
            star2.image = fullStarImage
        case 2.5:
            star1.image = fullStarImage
            star2.image = fullStarImage
            star3.image = halfStarImage
        case 3:
            star1.image = fullStarImage
            star2.image = fullStarImage
            star3.image = fullStarImage
        case 3.5:
            star1.image = fullStarImage
            star2.image = fullStarImage
            star3.image = fullStarImage
            star4.image = halfStarImage
        case 4:
            star1.image = fullStarImage
            star2.image = fullStarImage
            star3.image = fullStarImage
            star4.image = fullStarImage
        case 4.5:
            star1.image = fullStarImage
            star2.image = fullStarImage
            star3.image = fullStarImage
            star4.image = fullStarImage
            star5.image = halfStarImage
        case 5:
            star1.image = fullStarImage
            star2.image = fullStarImage
            star3.image = fullStarImage
            star4.image = fullStarImage
            star5.image = fullStarImage
        default:
            star1.image = noStarImage
            star2.image = noStarImage
            star3.image = noStarImage
            star4.image = noStarImage
            star5.image = noStarImage
            
        }
    }

}
