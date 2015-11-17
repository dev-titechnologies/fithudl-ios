//
//  CustomPopupViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 01/10/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class CustomPopupViewController: UIViewController {

    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var bioView: UIView!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var rateView: UIView!
    @IBOutlet weak var timeOkButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeTitleLabel: UILabel!
    @IBOutlet weak var timeMsgLabel: UILabel!
    
    var viewTag = 0
    var bioText: String?
    var timeDictionary: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bioView.hidden  = true
        rateView.hidden = true
        timeView.hidden = true
        
        bioView.layer.cornerRadius  = 10.0
        timeView.layer.cornerRadius = 10.0
        rateView.layer.cornerRadius = 10.0
        
        timeOkButton.layer.cornerRadius = 23.0
        timeOkButton.layer.borderWidth  = 2.0
        timeOkButton.layer.borderColor  = AppColor.statusBarColor.CGColor
        
        
        switch (viewTag) {
        case ViewTag.bioText:
            bioView.hidden = false
            attributedBioText()
        case ViewTag.timeView:
            timeView.hidden = false
            setValueForTimeView()
        case ViewTag.rateView:
            rateView.hidden = false
        default:
            timeView.hidden = false
        }

        println(timeDictionary)
        // Do any additional setup after loading the view.
    }

    func setValueForTimeView() {
        if let time = timeDictionary {
            timeLabel.text = time["time"] as? String
            if time["disabled"] as? Bool == true {
                timeTitleLabel.text = "Activate the time"
                timeMsgLabel.text   = "By clicking OK you will be activating your time"
            } else {
                timeTitleLabel.text = "Deactivate the time"
                timeMsgLabel.text   = "By clicking OK you will be deactivating your time"
            }
        }
    }
    
    func attributedBioText() {
        var bioTitle = NSMutableAttributedString(string: "BIO", attributes: [NSFontAttributeName: UIFont(name: "OpenSans", size: 14.0)!, NSForegroundColorAttributeName: AppColor.yellowTextColor])
        bioTitle.appendAttributedString(NSAttributedString(string: ":", attributes: [NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 14.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()]))
        bioTitle.appendAttributedString(NSAttributedString(string: " \(bioText!)", attributes: [NSFontAttributeName: UIFont(name: "OpenSans-Light", size: 13.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()]))
        bioTextView.attributedText = bioTitle
    }
    
    @IBAction func timeOkButtonClicked(sender: UIButton) {

    }
    
    @IBAction func closeButtonClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
