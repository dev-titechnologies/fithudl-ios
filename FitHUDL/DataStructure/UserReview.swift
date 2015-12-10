//
//  UserReview.swift
//  FitHUDL
//
//  Created by Ti Technologies on 09/12/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

class UserReview: NSManagedObject {

    @NSManaged var profileID: NSNumber
    @NSManaged var profileName: String
    @NSManaged var profilePic: String
    @NSManaged var userRating: NSNumber
    @NSManaged var userReview: String
    @NSManaged var user: User

    class func saveUserReviewList(id: Int, name: String, imageURL: String, rate: Int, review: String, user: User) -> UserReview {
        var userReview:UserReview = NSEntityDescription.insertNewObjectForEntityForName("UserReview", inManagedObjectContext: appDelegate.managedObjectContext!) as! UserReview
        userReview.profileID      = id
        userReview.profileName    = name
        userReview.profilePic     = imageURL
        userReview.userReview     = review
        userReview.userRating     = rate
        userReview.user           = user
        return userReview
    }
    
    class func fetchUserReviewList(id: Int?) -> NSArray? {
        var error: NSError? = nil
        var fetchRequest    = NSFetchRequest(entityName: "UserReview")
        if let userID = id {
            fetchRequest.predicate = NSPredicate(format: "user.profileID = %d", argumentArray: [userID])
        }
        var result:NSArray  = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        println(result)
        return result.count == 0 ? nil : result
    }
    
    class func deleteUserReviewList(id: Int?) {
        var error: NSError? = nil
        var fetchRequest    = NSFetchRequest(entityName: "UserReview")
        if let userID = id {
            fetchRequest.predicate = NSPredicate(format: "user.profileID = %d", argumentArray: [userID])
        }
        var result:NSArray  = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        var i:Int=0
        for i = 0; i<result.count; i++ {
            let reviews: UserReview = result[i] as! UserReview
            appDelegate.managedObjectContext?.deleteObject(reviews)
        }
    }
}
