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
    
}
