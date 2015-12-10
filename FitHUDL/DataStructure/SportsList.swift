//
//  SportsList.swift
//  FitHUDL
//
//  Created by Ti Technologies on 09/12/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

class SportsList: NSManagedObject {

    @NSManaged var logo: String
    @NSManaged var sportsId: NSNumber
    @NSManaged var sportsName: String
    @NSManaged var status: NSNumber
    @NSManaged var level: String
    
    class func saveSportsList(id: Int, spName: String, status: Int, logo: String, level: String) {
        var sportsList:SportsList = NSEntityDescription.insertNewObjectForEntityForName("SportsList", inManagedObjectContext: appDelegate.managedObjectContext!) as! SportsList
        sportsList.sportsId     = id
        sportsList.sportsName   = spName
        sportsList.status       = status
        sportsList.logo         = logo
        sportsList.level        = level
        appDelegate.saveContext()
    }
    
    class func fetchSportsList() -> NSArray? {
        var error: NSError?=nil
        var fetchRequest   = NSFetchRequest(entityName: "SportsList")
        var result:NSArray = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        println(result)
        return result.count == 0 ? nil : result
    }
    
    class func deleteSportsList() {
        var error: NSError? = nil
        var fetchRequest    = NSFetchRequest(entityName: "SportsList")
        var result:NSArray  = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        var i:Int = 0
        for i=0; i<result.count; i++ {
            let sports: SportsList = result[i] as! SportsList
            appDelegate.managedObjectContext?.deleteObject(sports)
            
        }
    }
}
