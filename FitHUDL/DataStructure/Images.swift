//
//  Images.swift
//  FitHUDL
//
//  Created by Ti Technologies on 13/10/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

class Images: NSManagedObject {

    @NSManaged var imageURL: String
    @NSManaged var imageData: NSData

    class func fetch(imageURL: String) -> NSArray? {
        var error: NSError? = nil
        var fetchRequest                    = NSFetchRequest(entityName: "Images")
        fetchRequest.predicate              = NSPredicate(format: "imageURL = %@", argumentArray: [imageURL])
        fetchRequest.returnsObjectsAsFaults = false
        var result: NSArray                 = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        return result.count == 0 ? nil : result
    }
    
    
    class func save(imageURL: String, imageData: NSData) {
        
        var newImage: Images    = NSEntityDescription.insertNewObjectForEntityForName("Images", inManagedObjectContext: appDelegate.managedObjectContext!) as! Images
        newImage.imageURL       = imageURL
        newImage.imageData      = imageData
        appDelegate.saveContext()
    }
    
    class func deleteImages() {
        var error: NSError?              = nil
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Images")
        var results: NSArray             = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        var i:Int
        for i in 0..<results.count {
            let image: Images = results[i] as! Images
            appDelegate.managedObjectContext?.deleteObject(image)
        }
        appDelegate.saveContext()
    }
    
}
