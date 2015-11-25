//
//  Globals.swift
//  FitHUDL
//
//  Created by Ti Technologies on 22/09/15.
//  Copyright © 2015 Ti Technologies. All rights reserved.
//

import UIKit

class Globals: NSObject {

    class func isInternetConnected() -> Bool {
        let networkReachability = Reachability.reachabilityForInternetConnection()
        let networkStatus:Int   = networkReachability.currentReachabilityStatus().value
        if networkStatus == NotReachable.value {
            UIAlertView(title: alertTitle, message: Message.Offline, delegate: nil, cancelButtonTitle: "OK").show()
            return false
        } else {
            return true
        }
    }
    
    class func isValidEmail (email: String) -> Bool {
        let emailRegex  = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        var emailText   = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailText.evaluateWithObject(email)
    }

    class func selectButton(button1: UIButton, button2: UIButton) {
        button1.selected = true
        button2.selected = false
    }
    
    class func selectButton(buttonArray: [UIButton], selectButton: UIButton) {
        for button in buttonArray {
            if button.isEqual(selectButton) {
                button.selected = !button.selected
            } else {
                button.selected = false
            }
        }
    }
    
    class func convertTimeTo24Hours(time: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h.mm a"
        if let date = dateFormatter.dateFromString(time) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.stringFromDate(date)
        }
        return time
    }
    
    class func convertTimeTo12Hours(time: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let date = dateFormatter.dateFromString(time) {
            dateFormatter.dateFormat = "h.mm a"
            return dateFormatter.stringFromDate(date)
        }
        return time
    }
    
    class func convertDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.stringFromDate(date)
    }
    
    class func convertTime(time: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.stringFromDate(time)
    }
    
    class func clearSession() {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "API_TOKEN")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "deviceToken")
        Images.deleteImages()
    }
    
    class func endOfMonth() -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let months   = NSDateComponents()
        months.month = 1
        
        if let plusOneMonthDate = calendar.dateByAddingComponents(months, toDate: NSDate(), options: nil) {
            let plusOneMonthDateComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth, fromDate: plusOneMonthDate)
            let endOfMonth = calendar.dateFromComponents(plusOneMonthDateComponents)?.dateByAddingTimeInterval(-1)
            return endOfMonth
        }
        return nil
    }
    
    class func attributedBioText(bio: String, lengthExceed: Bool, bioLabel: UILabel) {
        var bioTitle = NSMutableAttributedString(string: "BIO", attributes: [NSFontAttributeName: UIFont(name: "OpenSans", size: 15.0)!, NSForegroundColorAttributeName: AppColor.yellowTextColor])
        bioTitle.appendAttributedString(NSAttributedString(string: ":", attributes: [NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 14.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()]))
        bioTitle.appendAttributedString(NSAttributedString(string: " \(bio)", attributes: [NSFontAttributeName: UIFont(name: "OpenSans-Light", size: 13.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()]))
        if lengthExceed == true {
            bioTitle.appendAttributedString(NSAttributedString(string: "...", attributes: [NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 14.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()]))
        }
        bioLabel.attributedText = bioTitle
    }
    
    class func createShareImage(sportImage: UIImage, shareText: String, parentView: UIView) -> UIImage {
        let contentView             = UIView(frame: CGRect(x: parentView.frame.size.height, y: 0.0, width: 300.0, height: 180.0))
        contentView.backgroundColor = UIColor.whiteColor()
        parentView.addSubview(contentView)
        
        let bgImageView             = UIImageView(image: UIImage(named: "popup_bg"))
        bgImageView.frame           = CGRect(origin: CGPointZero, size: CGSize(width: 300.0, height: 180.0))
        bgImageView.contentMode     = UIViewContentMode.ScaleAspectFill
        bgImageView.clipsToBounds   = true
        contentView.addSubview(bgImageView)
        
        let sportImageView           = UIImageView(image: sportImage)
        sportImageView.frame         = CGRect(origin: CGPoint(x: 15.0, y: 48.0), size: CGSize(width: 85.0, height: 85.0))
        sportImageView.contentMode   = UIViewContentMode.ScaleAspectFill
        sportImageView.clipsToBounds = true
        contentView.addSubview(sportImageView)
        
        let height      = getLabelHeight(shareText)
        let shareLabel  = UILabel(frame: CGRect(origin: CGPoint(x: 105.0, y: (sportImageView.frame.origin.y+sportImageView.frame.size.height+height)/2.0), size: CGSize(width: 170.0, height: height)))
        shareLabel.center = CGPoint(x: shareLabel.center.x, y: sportImageView.center.y)
        shareLabel.text = shareText
        shareLabel.font = UIFont(name: "OpenSans", size: 15.0)
        shareLabel.numberOfLines = 0
        shareLabel.textColor = UIColor.whiteColor()
        contentView.addSubview(shareLabel)
        
        let logo = UIImageView(image: UIImage(named: "app_logo"))
        logo.frame = CGRect(origin: CGPoint(x: shareLabel.frame.origin.x+shareLabel.frame.size.width-logo.image!.size.width, y: shareLabel.frame.origin.y+shareLabel.frame.size.height+1), size: logo.image!.size)
        contentView.addSubview(logo)
        contentView.layer.cornerRadius = 5.0
        return Globals.getScreenshot(contentView)
    }
    
    private class func getLabelHeight(message: String) -> CGFloat {
        let label = UILabel(frame: CGRect(origin: CGPointZero, size: CGSize(width: 162.0, height: 80.0)))
        label.numberOfLines = 0
        label.font = UIFont(name: "OpenSans", size: 15.0)
        label.text = message
        label.sizeToFit()
        return label.frame.height
    }
    
    private class func getScreenshot(view: UIView) -> UIImage {
        //Create the UIImage
//        UIGraphicsBeginImageContext(view.frame.size)
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.mainScreen().scale)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
