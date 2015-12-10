//
//  UserBadges.swift
//  FitHUDL
//
//  Created by Ti Technologies on 09/12/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

class UserBadges: NSManagedObject {

    @NSManaged var count: NSNumber
    @NSManaged var imageURL: String
    @NSManaged var name: String
    @NSManaged var sessionCount: NSNumber
    @NSManaged var user: User

    class func saveUserBadgesList(count: Int, sessionCount: Int, name: String, imageURL: String, user: User) -> UserBadges {
        var userBadge:UserBadges = NSEntityDescription.insertNewObjectForEntityForName("UserBadges", inManagedObjectContext: appDelegate.managedObjectContext!) as! UserBadges
        userBadge.count         = count
        userBadge.sessionCount  = sessionCount
        userBadge.name          = name
        userBadge.imageURL      = imageURL
        userBadge.user          = user
        return userBadge
    }
    
    class func fetchUserBadgesList(id: Int?) -> NSArray? {
        var error: NSError? = nil
        var fetchRequest    = NSFetchRequest(entityName: "UserBadges")
        if let userID = id {
            fetchRequest.predicate = NSPredicate(format: "user.profileID = %d", argumentArray: [userID])
        }
        var result:NSArray  = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        println(result)
        return result.count == 0 ? nil : result
    }
    
    class func deleteUserBadgesList(id: Int?) {
        var error: NSError? = nil
        var fetchRequest    = NSFetchRequest(entityName: "UserBadges")
        if let userID = id {
            fetchRequest.predicate = NSPredicate(format: "user.profileID = %d", argumentArray: [userID])
        }
        var result:NSArray  = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        var i:Int=0
        for i = 0; i<result.count; i++ {
            let badges: UserBadges = result[i] as! UserBadges
            appDelegate.managedObjectContext?.deleteObject(badges)
        }
    }
}
