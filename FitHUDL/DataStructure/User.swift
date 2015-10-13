//
//  User.swift
//  FitHUDL
//
//  Created by Ti Technologies on 12/10/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class User: NSObject {
    var profileID: String = ""
    var name: String = ""
    var email: String = ""
    var bio: String?
    var imageURL: String?
    var totalHours: String?
    var usageCount: Int?
    var rating: Float?
    var availableTimeArray  = NSMutableArray()
    var userReviewsArray    = NSMutableArray()
    var sportsArray         = NSMutableArray()
    var badgesArray         = NSMutableArray()
    
}
