//
//  AppConstants.swift
//  FitHUDL
//
//  Created by Ti Technologies on 22/09/15.
//  Copyright © 2015 Ti Technologies. All rights reserved.
//
///// changes by ardra
import UIKit
let STRIPE_URL = "192.168.1.65/fithudl/donate/"
let SERVER_URL = "http://api.pillar.fit/"
let SHARE_URL  = "http://www.pillar.fit/"
let ITUNES_LINK = "https://itunes.apple.com/us/app/fithudl/id1062264534?ls=1&mt=8"
//let SERVER_URL = "http://192.168.1.65:1337/"

let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

let alertTitle  = "Pillar"

let IS_IPHONE4S     = UIScreen.mainScreen().bounds.size.height == 480 ? true : false
let IS_IPHONE5      = UIScreen.mainScreen().bounds.size.height == 568 ? true : false
let IS_IPHONE6      = UIScreen.mainScreen().bounds.size.width == 375 ? true : false
let IS_IPHONE6PLUS  = UIScreen.mainScreen().bounds.size.width == 414 ? true : false
let BIOTEXT_LENGTH  = 45
let BIOLIMIT        = 70
let animateInterval: NSTimeInterval = 0.3
let secondsValue: Int    = 60

struct AppColor {
    
    static let statusBarColor   = UIColor(red: 0, green: 120/255, blue: 109/255, alpha: 1.0)
    static let placeholderText  = UIColor(red: 216/255, green: 1, blue: 251/255, alpha: 1.0)
    static let yellowTextColor  = UIColor(red: 1, green: 204/255, blue: 59/255, alpha: 1.0)
    static let textDisableColor = UIColor(red: 0, green: 170/255, blue: 155/255, alpha: 1.0)
    static let boxBorderColor   = UIColor(red: 242/255, green: 141/255, blue: 44/255, alpha: 1.0)
    static let badgeSilverColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0)
    static let timerColor       = UIColor(red: 183/255, green: 183/255, blue: 183/255, alpha: 1.0)
    static let notifReadColor   = UIColor(red: 140/255, green: 138/255, blue: 143/255, alpha: 1.0)
    static let promoGreenColor  = UIColor(red: 0, green: 142/255, blue: 129/255, alpha: 1.0)
    static let promoGrayColor   = UIColor(red: 129/255, green: 134/255, blue: 134/255, alpha: 1.0)
    static let redCompletedThisWeek   = UIColor(red: 176/255, green: 32/255, blue: 2/255, alpha: 1.0)
    static let goldCompletedThisWeek   = UIColor(red: 240/255, green: 196/255, blue: 21/255, alpha: 1.0)
    
}

struct Message {
    
    static let Offline  = "Not connected to the internet!"
    static let Error    = "Internal Error"
}

struct TimeOut {
    static let Image: NSTimeInterval = 60
    static let Data: NSTimeInterval  = 60
    static let sessionDuration: String = "GENERAL_SESSION_DURATION"
    static let sessionInterval: String = "GENERAL_BOOKING_INTERVAL"
}

struct HttpMethod {
    static let post = "POST"
    static let get  = "GET"
    static let put  = "PUT"
}

struct Connection {
    static let login          = 9
    static let signup         = 10
    static let checkUserFB    = 11
    static let checkUser      = 12
    static let resetPassword  = 13
    static let sportsList     = 14
    static let userProfile    = 15
    static let favouriteList  = 16
    static let unfavourite    = 17
    static let updateSports   = 18
    static let ratecategory   = 19
    static let submitfeedback = 20
    static let logout         = 21
    static let searchUserName = 22
    static let userSportsList = 23
    static let bookingRequest = 24
    static let notificationRequest  = 25
    static let bookingAcceptRequest = 26
    static let packagesListRequest  = 27
    static let userRatingRequest    = 28
    static let shareImageRequest    = 29
    static let sessionExtend        = 30
    static let sessionComplete      = 31
    static let sessionsList         = 32
    static let sessionCancel        = 33
    static let notifReadStatus      = 34
    static let transactionRequest   = 35
    static let promoCodeRequest     = 36
    static let contentChangeRequest = 37
    static let striperequest = 38
    static let reportRequest = 39
<<<<<<< HEAD
    static let stripeAccount = 40
=======
>>>>>>> 97574d3d8b8d17cf182d45352b06f5b4dc419d40
}

struct SportsLevel {
    static let beginner = "Beginner"
    static let moderate = "Moderate"
    static let expert   = "Expert"
    static let typeAdd  = "ADD"
    static let typeDelete = "DELETE"
    static let typeUpdate = "UPDATE"
    static let noType   = "NO"
}

struct Gender {
    static let male     = "male"
    static let female   = "female"
}

struct ViewTag {
    static let bioText          = 1
    static let timeView         = 2
    static let rateView         = 3
    static let bookView         = 4
    static let termsView        = 5
    static let privacyView      = 6
    static let promoDisplayView = 7
    static let promoEntryView   = 8
    static let mobilePrivacy    = 9
    static let agreement        = 10
    static let contentChange    = 11
    static let whatisStripe     = 12
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
    static let requested                    = "training_req"
    static let accepted                     = "training_req_accept"
    static let requestrejected              = "training_req_rejected"
    static let traingFee                    = "training_fee"
    static let traingRequestCancelled       = "training_req_accept_canceled"
    static let traingRequestCancelledByUser = "training_req_accept_canceled_by_user"
    static let accountRecharge              = "account_recharge"
    static let pendingCanceled              = "pending_cancel"
    static let acceptCanceled               = "accept_cancel"
    static let eightHoursCompleted          = "user_weekly_time"
    static let sessionAutoCancel            = "session_auto_cancel_to_suspended_trainer"
}

struct Session {
    static let complete = 0
    static let extend   = 1
}

struct PushNotification {
    static let sportsList   = "signupSportsList"
    static let sessionStart = "session_start"
    static let sessionEnd   = "session_end"
    static let sessionExtend  = "session_extension"
    static let sessionSuccess = "session_extension_success"
    static let sessionFail  = "session_extension_failed"
    static let timerNotif   = "TimerNotification"
    static let favNotif     = "FavoriteNotification"
    static let sessionNotif = "SessionCanExtend"
}

class AppConstants: NSObject {

}
