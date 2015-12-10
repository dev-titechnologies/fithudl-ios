//
//  Bookings.swift
//  FitHUDL
//
//  Created by Ti Technologies on 09/12/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

class Bookings: NSManagedObject {

    @NSManaged var requestID: NSNumber
    @NSManaged var userID: NSNumber
    @NSManaged var trainerID: NSNumber
    @NSManaged var sportsID: NSNumber
    @NSManaged var startTime: String
    @NSManaged var endTime: String
    @NSManaged var allotedDate: String
    @NSManaged var bookingID: NSNumber
    @NSManaged var status: String
    @NSManaged var location: String
    @NSManaged var userName: String
    @NSManaged var sportsName: String
    @NSManaged var trainerName: String
    @NSManaged var userImage: String
    @NSManaged var trainerImage: String

    class func saveBooking(name: String, userID: Int, requestID: Int, trainerID: Int, spID: Int, spName: String, status: String, loc: String, bookID: Int, startTime: String, endTime: String, allotedDate: String, userImage: String, trainerName: String, trainerImage: String) -> Bookings {
        var booking: Bookings = NSEntityDescription.insertNewObjectForEntityForName("Bookings", inManagedObjectContext: appDelegate.managedObjectContext!) as! Bookings
        booking.userName    = name
        booking.userID      = userID
        booking.bookingID   = bookID
        booking.requestID   = requestID
        booking.trainerID   = trainerID
        booking.sportsID    = spID
        booking.sportsName  = spName
        booking.allotedDate = allotedDate
        booking.location    = loc
        booking.status      = status
        booking.startTime   = startTime
        booking.endTime     = endTime
        booking.userImage   = userImage
        booking.trainerImage = trainerImage
        booking.trainerName  = trainerName
        return booking
    }
    
    class func fetchBookings() -> NSArray? {
        var error: NSError?=nil
        var fetchRequest   = NSFetchRequest(entityName: "Bookings")
        var result:NSArray = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        println(result)
        return result.count == 0 ? nil : result
    }
    
    class func deleteBookings() {
        var error: NSError? = nil
        var fetchRequest    = NSFetchRequest(entityName: "Bookings")
        var result:NSArray  = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        var i:Int = 0
        for i=0; i<result.count; i++ {
            let booking: Bookings = result[i] as! Bookings
            appDelegate.managedObjectContext?.deleteObject(booking)
        }
    }
}
