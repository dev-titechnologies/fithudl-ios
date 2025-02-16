//
//  UserReviewView.swift
//  FitHUDL
//
//  Created by Ti Technologies on 29/09/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class UserReviewView: UIView
{
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var starView: StarRateView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var view: UIView!
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle  = NSBundle(forClass: self.dynamicType)
        let nib     = UINib(nibName: "UserReviewView", bundle: bundle)
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

}
