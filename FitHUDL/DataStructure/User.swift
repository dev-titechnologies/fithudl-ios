//
//  User.swift
//  FitHUDL
//
//  Created by Ti Technologies on 09/12/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var bio: String
    @NSManaged var currentUser: NSNumber
    @NSManaged var email: String
    @NSManaged var emailVerified: NSNumber
    @NSManaged var imageURL: String
    @NSManaged var interests: String
    @NSManaged var isFavorite: NSNumber
    @NSManaged var name: String
    @NSManaged var profileID: NSNumber
    @NSManaged var profileImage: NSData
    @NSManaged var rating: NSNumber
    @NSManaged var totalHours: String
    @NSManaged var usageCount: String
    @NSManaged var userVerified: NSNumber
    @NSManaged var walletBalance: String
    @NSManaged var availableTime: NSMutableSet
    @NSManaged var badges: NSMutableSet
    @NSManaged var reviews: NSMutableSet
    @NSManaged var sports: NSMutableSet

    class func saveUser(id: Int, name: String, email: String, bio: String, imageURL: String, hours: String, count:String, rate: Int, userVerify: Int, interest: String, balance: String, emailVerify: Int, favourite: Int, image: NSData) {
        var user:User   = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: appDelegate.managedObjectContext!) as! User
        user.name       = name
        user.profileID  = id
        user.email      = email
        user.bio        = bio
        user.imageURL   = imageURL
        user.profileImage   = image
        user.emailVerified  = emailVerify
        user.userVerified   = userVerify
        user.totalHours     = hours
        user.usageCount     = count
        user.rating         = rate
        user.isFavorite     = favourite
        appDelegate.saveContext()
    }
    
    class func fetchUser(fetchPredicate: NSPredicate?) -> User? {
        var error: NSError? = nil
        var fetchRequest    = NSFetchRequest(entityName: "User")
        if let predicate = fetchPredicate {
            fetchRequest.predicate = predicate
        }
        var result:NSArray  = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        println(result)
        return result.count == 0 ? nil : result.firstObject as? User
    }
    
    class func deleteUser(fetchPredicate: NSPredicate?) {
        var error: NSError? = nil
        var fetchRequest    = NSFetchRequest(entityName: "User")
        if let predicate = fetchPredicate {
            fetchRequest.predicate = predicate
        }
        var result:NSArray  = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        var i:Int = 0
        for i = 0; i<result.count; i++ {
            let users: User = result[i] as! User
            appDelegate.managedObjectContext?.deleteObject(users)
            
        }
    }
}
