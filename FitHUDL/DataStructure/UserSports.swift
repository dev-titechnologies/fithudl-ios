//
//  UserSports.swift
//  FitHUDL
//
//  Created by Ti Technologies on 09/12/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

class UserSports: NSManagedObject {

    @NSManaged var expertLevel: String
    @NSManaged var logo: String
    @NSManaged var sportsID: NSNumber
    @NSManaged var sportsName: String
    @NSManaged var user: User

    class func saveUserSportsList(id: Int, sportsName: String, level: String, imageURL:String, user: User) -> UserSports {
        var userSport:UserSports = NSEntityDescription.insertNewObjectForEntityForName("UserSports", inManagedObjectContext: appDelegate.managedObjectContext!) as! UserSports
        userSport.sportsID      = id
        userSport.sportsName    = sportsName
        userSport.expertLevel   = level
        userSport.logo          = imageURL
        userSport.user          = user
        return userSport
    }
    
    class func fetchUserSportsList(id: Int?) -> NSArray? {
        var error: NSError? = nil
        var fetchRequest    = NSFetchRequest(entityName: "UserSports")
        if let userID = id {
            fetchRequest.predicate = NSPredicate(format: "user.profileID = %d", argumentArray: [userID])
        }
        var result:NSArray  = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        println(result)
        return result.count == 0 ? nil : result
    }
    
    class func deleteUserSportsList(id: Int?) {
        var error: NSError? = nil
        var fetchRequest    = NSFetchRequest(entityName: "UserSports")
        if let userID = id {
            fetchRequest.predicate = NSPredicate(format: "user.profileID = %d", argumentArray: [userID])
        }
        var result:NSArray  = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        var i:Int=0
        for i = 0; i<result.count; i++ {
            let sports: UserSports = result[i] as! UserSports
            appDelegate.managedObjectContext?.deleteObject(sports)
        }
    }
}
