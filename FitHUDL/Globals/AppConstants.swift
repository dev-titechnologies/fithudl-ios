//
//  AppConstants.swift
//  FitHUDL
//
//  Created by Ti Technologies on 22/09/15.
//  Copyright © 2015 Ti Technologies. All rights reserved.
//
///// changes by ardra
import UIKit

let SERVER_URL = "http://fithudl.titechnologies.in/"
//let Server_URL = "http://192.168.1.151:1337/"

let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

let alertTitle  = "FitHUDL"

let IS_IPHONE4S     = UIScreen.mainScreen().bounds.size.height == 480 ? true : false
let IS_IPHONE5      = UIScreen.mainScreen().bounds.size.height == 568 ? true : false
let IS_IPHONE6      = UIScreen.mainScreen().bounds.size.width == 375 ? true : false
let IS_IPHONE6PLUS  = UIScreen.mainScreen().bounds.size.width == 414 ? true : false
let BIOTEXT_LENGTH  = 52
let animateInterval: NSTimeInterval = 0.3

struct AppColor {
    static let statusBarColor  = UIColor(red: 0, green: 120/255, blue: 109/255, alpha: 1.0)
    static let placeholderText = UIColor(red: 216/255, green: 1, blue: 251/255, alpha: 1.0)
    static let yellowTextColor = UIColor(red: 1, green: 204/255, blue: 59/255, alpha: 1.0)
    static let textDisableColor = UIColor(red: 0, green: 170/255, blue: 155/255, alpha: 1.0)
    static let boxBorderColor   = UIColor(red: 242/255, green: 141/255, blue: 44/255, alpha: 1.0)
    static let badgeSilverColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0)
    static let timerColor       = UIColor(red: 183/255, green: 183/255, blue: 183/255, alpha: 1.0)
}

struct Message {
    static let Offline  = "The Internet connection appears to be offline."
    static let Error    = "Internal Error"
}

struct TimeOut {
    static let Image: NSTimeInterval = 60
    static let Data: NSTimeInterval  = 20
    static let sessionDuration: NSTimeInterval = 1800
    static let sessionInterval: NSTimeInterval = 1800
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
    static let favouriteList = 16
    static let unfavourite   = 17
    static let updateSports  = 18
    static let ratecategory   = 19
    static let submitfeedback = 20
    static let logout         = 21
    static let searchUserName = 22
    static let userSportsList = 23
    static let bookingRequest = 24
    static let notificationRequest = 25
    static let bookingAcceptRequest = 26
    static let packagesListRequest = 27
}

struct SportsLevel {
    static let beginner = "Beginner"
    static let moderate = "Moderate"
    static let expert   = "Expert"
    static let typeAdd  = "ADD"
    static let typeDelete = "DELETE"
    static let typeUpdate = "UPDATE"
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

struct TrainingStatus {
    static let requested = "training_req"
    static let accepted  = "training_req_accepted"
}

class AppConstants: NSObject {

}
