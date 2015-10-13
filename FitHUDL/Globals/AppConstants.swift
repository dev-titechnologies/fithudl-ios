//
//  AppConstants.swift
//  FitHUDL
//
//  Created by Ti Technologies on 22/09/15.
//  Copyright © 2015 Ti Technologies. All rights reserved.
//

import UIKit

let SERVER_URL = "http://192.168.1.64:1337/"
//let Server_URL = "http://192.168.1.151:1337/"

let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

let alertTitle  = "FitHUDL"

let IS_IPHONE4S     = UIScreen.mainScreen().bounds.size.height == 480 ? true : false
let IS_IPHONE5      = UIScreen.mainScreen().bounds.size.height == 568 ? true : false
let IS_IPHONE6      = UIScreen.mainScreen().bounds.size.width == 375 ? true : false
let IS_IPHONE6PLUS  = UIScreen.mainScreen().bounds.size.width == 414 ? true : false
let BIOTEXT_LENGTH  = 52

struct AppColor {
    static let statusBarColor  = UIColor(red: 0, green: 120/255, blue: 109/255, alpha: 1.0)
    static let placeholderText = UIColor(red: 216/255, green: 1, blue: 251/255, alpha: 1.0)
    static let yellowTextColor = UIColor(red: 1, green: 204/255, blue: 59/255, alpha: 1.0)
    static let textDisableColor = UIColor(red: 0, green: 170/255, blue: 155/255, alpha: 1.0)
}

struct Message {
    static let Offline  = "The Internet connection appears to be offline."
    static let Error    = "Internal Error"
}

struct TimeOut {
    static let Image: NSTimeInterval = 60
    static let Data: NSTimeInterval  = 20
}

struct HttpMethod {
    static let post = "POST"
    static let get  = "GET"
    static let put  = "PUT"
}

struct Connection {
    static let login         = 10
    static let signup        = 11
    static let checkUser     = 12
    static let resetPassword = 13
    static let sportsList    = 14
    static let userProfile   = 15
}

struct SportsLevel {
    static let beginner = "Beginner"
    static let moderate = "Moderate"
    static let expert   = "Expert"
}

struct Gender {
    static let male     = "male"
    static let female   = "female"
}

struct ViewTag {
    static let bioText  = 1
    static let timeView = 2
    static let rateView = 3
}

struct ResponseStatus {
    static let success      = 1
    static let error        = 2
    static let sessionOut   = 3
}

struct ErrorMessage {
    static let invalid      = "Invalid Response!"
    static let sessionOut   = "Current Session Expired!"
}

class AppConstants: NSObject {

}
