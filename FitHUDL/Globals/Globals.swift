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
    
}
