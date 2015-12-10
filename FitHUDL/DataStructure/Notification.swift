//
//  Notification.swift
//  FitHUDL
//
//  Created by Ti Technologies on 09/12/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

class Notification: NSManagedObject {

    @NSManaged var allotedDate: String
    @NSManaged var endTime: String
    @NSManaged var location: String
    @NSManaged var readStatus: NSNumber
    @NSManaged var requestID: NSNumber
    @NSManaged var sportsID: NSNumber
    @NSManaged var sportsName: String
    @NSManaged var startTime: String
    @NSManaged var trainerID: NSNumber
    @NSManaged var trainerImage: String
    @NSManaged var trainerName: String
    @NSManaged var type: String
    @NSManaged var userID: NSNumber
    @NSManaged var userImage: String
    @NSManaged var userName: String

    class func saveNotification(name: String, userID: Int, requestID: Int, trainerID: Int, spID: Int, spName: String, type: String, loc: String, readStatus: Int, startTime: String, endTime: String, allotedDate: String, userImage: String, trainerName: String, trainerImage: String) {
        var notification: Notification = NSEntityDescription.insertNewObjectForEntityForName("Notification", inManagedObjectContext: appDelegate.managedObjectContext!) as! Notification
        notification.userName   = name
        notification.userID     = userID
        notification.readStatus = readStatus
        notification.requestID  = requestID
        notification.trainerID  = trainerID
        notification.sportsID   = spID
        notification.sportsName = spName
        notification.allotedDate = allotedDate
        notification.location   = loc
        notification.type       = type
        notification.startTime  = startTime
        notification.endTime    = endTime
        notification.userImage  = userImage
        notification.trainerImage = trainerImage
        notification.trainerName  = trainerName
        appDelegate.saveContext()
    }
    
    class func fetchNotifications() -> NSArray? {
        var error: NSError?=nil
        var fetchRequest   = NSFetchRequest(entityName: "Notification")
        var result:NSArray = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        println(result)
        return result.count == 0 ? nil : result
    }
    
    class func deleteNotificationList() {
        var error: NSError? = nil
        var fetchRequest    = NSFetchRequest(entityName: "Notification")
        var result:NSArray  = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        var i:Int = 0
        for i=0; i<result.count; i++ {
            let users: Notification = result[i] as! Notification
            appDelegate.managedObjectContext?.deleteObject(users)
        }
    }
}
