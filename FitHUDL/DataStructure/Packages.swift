//
//  Packages.swift
//  FitHUDL
//
//  Created by Ti Technologies on 09/12/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

class Packages: NSManagedObject {

    @NSManaged var cost: String
    @NSManaged var currencyFormat: String
    @NSManaged var discount: String
    @NSManaged var displayPrice: String
    @NSManaged var id: NSNumber
    @NSManaged var name: String

    class func savePackage(id: Int, displayPrice: String, format: String, cost: String, discount: String, name: String) -> Packages {
        var package:Packages = NSEntityDescription.insertNewObjectForEntityForName("Packages", inManagedObjectContext: appDelegate.managedObjectContext!) as! Packages
        package.id   = id
        package.name = name
        package.displayPrice    = displayPrice
        package.currencyFormat  = format
        package.cost        = cost
        package.discount    = discount
        return package
    }
    
    class func fetchPackages() -> NSArray? {
        var error: NSError?=nil
        var fetchRequest   = NSFetchRequest(entityName: "Packages")
        var result:NSArray = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        println(result)
        return result.count == 0 ? nil : result
    }
    
    class func deletePackages() {
        var error: NSError? = nil
        var fetchRequest    = NSFetchRequest(entityName: "Packages")
        var result:NSArray  = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        var i:Int=0
        for i=0; i<result.count; i++ {
            let package: Packages = result[i] as! Packages
            appDelegate.managedObjectContext?.deleteObject(package)
        }
    }
}
