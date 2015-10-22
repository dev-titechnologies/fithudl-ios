//
//  UsersList.swift
//  FitHUDL
//
//  Created by Ti Technologies on 22/10/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit
import CoreData

class UsersList: NSManagedObject {
    
    @NSManaged var userName:String
    @NSManaged var userID:String
   
    class func saveUserList(usersName : String, usersID : String) {
        
        
        var userlist:UsersList = NSEntityDescription.insertNewObjectForEntityForName("UsersList", inManagedObjectContext: appDelegate.managedObjectContext!) as! UsersList
        userlist.userName=usersName
        userlist.userID=usersID
        appDelegate.saveContext()
        
    }
    
    class func fetchUsersList() -> NSArray? {
        
        var error: NSError?=nil
        var fetchRequest   = NSFetchRequest(entityName: "UsersList")
        var result:NSArray = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        println(result)
        return result.count == 0 ? nil : result
    }
    
    class func deleteUserList() {
        
        var error: NSError? = nil
        var fetchRequest    = NSFetchRequest(entityName: "UsersList")
        var result:NSArray  = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        var i:Int=0
        for i=0;i<result.count;i++ {
            
            let users: UsersList = result[i] as! UsersList
            appDelegate.managedObjectContext?.deleteObject(users)
            
        }
        
    }
}
