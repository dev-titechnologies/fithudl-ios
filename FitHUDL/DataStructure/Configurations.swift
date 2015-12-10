//
//  Configurations.swift
//  FitHUDL
//
//  Created by Ti Technologies on 09/12/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

class Configurations: NSManagedObject {

    @NSManaged var code: String
    @NSManaged var id: NSNumber
    @NSManaged var value: String

    class func saveConfig(id: Int, code: String, value: String) {
        var configList:Configurations = NSEntityDescription.insertNewObjectForEntityForName("Configurations", inManagedObjectContext: appDelegate.managedObjectContext!) as! Configurations
        configList.id       = id
        configList.code     = code
        configList.value    = value
        appDelegate.saveContext()
    }
    
    class func fetchConfig() -> NSArray? {
        var error: NSError?     = nil
        var fetchRequest        = NSFetchRequest(entityName: "Configurations")
        var result:NSArray      = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        return result.count == 0 ? nil : result
    }
    
    class func deleteConfigList() {
        var error: NSError? = nil
        var fetchRequest    = NSFetchRequest(entityName: "Configurations")
        var result:NSArray  = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        var i:Int=0
        for i=0; i<result.count; i++ {
            let config: Configurations = result[i] as! Configurations
            appDelegate.managedObjectContext?.deleteObject(config)
        }
    }
}
