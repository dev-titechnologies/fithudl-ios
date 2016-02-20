//
//  UserTime.swift
//  FitHUDL
//
//  Created by Ti Technologies on 09/12/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

class UserTime: NSManagedObject {

    @NSManaged var date: String
    @NSManaged var timeEnds: String
    @NSManaged var timeStarts: String
    @NSManaged var user: User
    

    class func saveUserTimeList(date: String, startTime: String, endTime: String, user: User) -> UserTime {
        var userTime:UserTime = NSEntityDescription.insertNewObjectForEntityForName("UserTime", inManagedObjectContext: appDelegate.managedObjectContext!) as! UserTime
        userTime.date           = date
        userTime.timeStarts     = startTime
        userTime.timeEnds       = endTime
        userTime.user           = user
        return userTime
    }
    
    class func fetchUserTimeList(id: Int?) -> NSArray? {
        var error: NSError? = nil
        var fetchRequest    = NSFetchRequest(entityName: "UserTime")
        if let userID = id {
            fetchRequest.predicate = NSPredicate(format: "user.profileID = %d", argumentArray: [userID])
        }
        var result:NSArray  = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        println(result)
        return result.count == 0 ? nil : result
    }
    
    class func deleteUserTimeList(id: Int?) {
        var error: NSError? = nil
        var fetchRequest    = NSFetchRequest(entityName: "UserTime")
        if let userID = id {
            fetchRequest.predicate = NSPredicate(format: "user.profileID = %d", argumentArray: [userID])
        }
        var result:NSArray  = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        var i:Int=0
        for i = 0; i<result.count; i++ {
            let time: UserTime = result[i] as! UserTime
            appDelegate.managedObjectContext?.deleteObject(time)
        }
    }
}
