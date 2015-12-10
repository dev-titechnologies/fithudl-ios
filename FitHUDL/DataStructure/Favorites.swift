//
//  Favorites.swift
//  FitHUDL
//
//  Created by Ti Technologies on 09/12/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

class Favorites: NSManagedObject {

    @NSManaged var favID: NSNumber
    @NSManaged var name: String
    @NSManaged var profilePic: String
    @NSManaged var rateCount: NSNumber
    @NSManaged var session: NSNumber

    class func saveFavorite(id: Int, name: String, picURL: String, rate: Int, session: Int) -> Favorites {
        var favorite:Favorites = NSEntityDescription.insertNewObjectForEntityForName("Favorites", inManagedObjectContext: appDelegate.managedObjectContext!) as! Favorites
        favorite.favID      = id
        favorite.name       = name
        favorite.profilePic = picURL
        favorite.rateCount  = rate
        favorite.session    = session
        return favorite
    }
    
    class func fetchFavorites() -> NSArray? {
        var error: NSError?=nil
        var fetchRequest   = NSFetchRequest(entityName: "Favorites")
        var result:NSArray = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        println(result)
        return result.count == 0 ? nil : result
    }
    
    class func deleteFavorites() {
        var error: NSError? = nil
        var fetchRequest    = NSFetchRequest(entityName: "Favorites")
        var result:NSArray  = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        var i:Int = 0
        for i=0; i<result.count; i++ {
            let favorite: Favorites = result[i] as! Favorites
            appDelegate.managedObjectContext?.deleteObject(favorite)
        }
    }
}
