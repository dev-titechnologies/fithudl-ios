//
//  AppDelegate.swift
//  FitHUDL
//
//  Created by Ti Technologies on 23/09/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var currentLocation: CLLocation?
    var deviceToken: String?
    
    var configDictionary    = NSMutableDictionary()
    var sportsArray         = NSMutableArray()
    var locationManager     = CLLocationManager()
    var user: User?
    var pushNotification    = NSDictionary()
    var notificationArray   = NSMutableArray()
    
//    var sportsArray: NSMutableArray = [NSMutableDictionary(objects: ["Run", ""], forKeys: ["sport", "level"]), NSMutableDictionary(objects: ["Tennis", ""], forKeys: ["sport","level"]), NSMutableDictionary(objects: ["Cycle", ""], forKeys: ["sport", "level"]), NSMutableDictionary(objects: ["Workout", ""], forKeys: ["sport", "level"]), NSMutableDictionary(objects: ["Yoga", ""], forKeys: ["sport", "level"]), NSMutableDictionary(objects: ["Kayak", ""], forKeys: ["sport", "level"]), NSMutableDictionary(objects: ["Dance", ""], forKeys: ["sport", "level"]), NSMutableDictionary(objects: ["Walk", ""], forKeys: ["sport", "level"]), NSMutableDictionary(objects: ["Swim", ""], forKeys: ["sport", "level"]),NSMutableDictionary(objects: ["Calisthenics", ""], forKeys: ["sport", "level"])]
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKLoginManager.renewSystemCredentials { (result: ACAccountCredentialRenewResult, error: NSError!) -> Void in
        }
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        var types: UIUserNotificationType = UIUserNotificationType.Badge |
            UIUserNotificationType.Alert |
            UIUserNotificationType.Sound
        
        var settings: UIUserNotificationSettings = UIUserNotificationSettings(
            forTypes: types, categories: nil
        )
        
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        sendRequestToGetAllUserNames()
        
        NewRelicAgent.enableFeatures(NRMAFeatureFlags.NRFeatureFlag_SwiftInteractionTracing);
        NewRelic.startWithApplicationToken("AAf8cd598fd69739a9dcdb8f40abcffe51f42c0899")
       
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        Globals.clearSession()
        self.saveContext()
    }
    
    
    // MARK: - Get Search Name
    
    func sendRequestToGetAllUserNames() {
        if !Globals.checkNetworkConnectivity() {
            return
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: SERVER_URL.stringByAppendingString("search/userList"))!)
        request.HTTPMethod = HttpMethod.get
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error == nil {
                if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
                    println("searchUsers",jsonResult)
                    if let status = jsonResult["status"] as? Int {
                        if status == ResponseStatus.success {
                            
                            UsersList.deleteUserList()
                            
                            if let usersList = jsonResult["data"] as? NSArray {
                                
                                var i:Int=0
                                for i=0;i<usersList.count;i++ {
                                    
                                    let userName = usersList[i].objectForKey("name") as! String
                                    let userId   = usersList[i].objectForKey("id") as! Int
                                    UsersList.saveUserList(userName, usersID: "\(userId)")
                                    
                                    }
                                UsersList.fetchUsersList()
                                
                            }
                        }
                    }
                }
            } else {
                
            }
        }
    }
    
    func sendRequestToExtendTrainerSession(bookDictionary: NSDictionary, accept: Int) {
        if !Globals.isInternetConnected() {
            return
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: SERVER_URL.stringByAppendingString("sessions/sessionExtendAcceptTrainer"))!)
        request.HTTPMethod = HttpMethod.post
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var error: NSError? = nil
        let parameters = NSMutableDictionary()
        parameters.setObject(accept, forKey: "accept")
        parameters.setObject(bookDictionary["id"]!, forKey: "booking_id")
        if let deviceToken = appDelegate.deviceToken {
            parameters.setObject(deviceToken, forKey:"device_id")
        } else {
            parameters.setObject("xyz", forKey: "device_id")
        }
        if let apiToken = NSUserDefaults.standardUserDefaults().objectForKey("API_TOKEN") as? String {
            parameters.setObject(apiToken, forKey: "token")
        }
        println("PARAM\(parameters)")
        let jsonData        = NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
        request.HTTPBody = jsonData
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error == nil {
                if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
                    if let status = jsonResult["status"] as? Int {
                        if status == ResponseStatus.success {
                            NSNotificationCenter.defaultCenter().postNotificationName(PushNotification.sessionNotif, object: nil, userInfo: ["session" : jsonResult])

                        } else {
                            if let message = jsonResult["message"] as? String {
                                UIAlertView(title: alertTitle, message: message, delegate: nil, cancelButtonTitle: "Ok").show()
                            }
                        }
                    }
                }
            } else {
                UIAlertView(title: alertTitle, message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Ok").show()
            }
        }

    }
    
    
    //MARK: - General Settings API
    func sendRequestToGetConfig() {
        if !Globals.checkNetworkConnectivity() {
            if let configs = Configurations.fetchConfig() {
                configDictionary.removeAllObjects()
                for config in configs {
                    configDictionary.setObject((config as! Configurations).value, forKey: (config as! Configurations).code)
                }
            }
        } else {
            let request = NSMutableURLRequest(URL: NSURL(string: SERVER_URL.stringByAppendingString("settings/generalSettings"))!)
            request.HTTPMethod = HttpMethod.get
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                if error == nil {
                    if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
                        println("generalSettings",jsonResult)
                        if let status = jsonResult["status"] as? Int {
                            if status == ResponseStatus.success {
                                self.configDictionary.removeAllObjects()
                                let configArray = jsonResult["data"] as! Array<NSMutableDictionary>
                                for config in configArray {
                                    let value: AnyObject? = config["value"]
                                    self.configDictionary.setObject(value!, forKey: config["code"] as! String)
                                    Configurations.saveConfig(config["id"] as! Int, code: config["code"] as! String , value: "\(value)")
                                }
                            }
                        }
                    }
                } else {
                    
                }
            }
        }
    }
    
    // MARK: - Push Notification
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var tokenAsString   =   NSMutableString()
        
        var byteBuffer  =   [UInt8](count: deviceToken.length, repeatedValue: 0x00)
        // deviceToken.getBytes(&byteBuffer)
        deviceToken.getBytes(&byteBuffer, length: deviceToken.length)
        
        for byte in byteBuffer {
            tokenAsString.appendFormat("%02hhX", byte)
        }
        self.deviceToken =   tokenAsString as String
        NSUserDefaults.standardUserDefaults().setObject(tokenAsString, forKey: "deviceToken")
        print("Token = \(tokenAsString)")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        notificationArray.addObject(userInfo)
        if application.applicationState == UIApplicationState.Active {
            if let aps = userInfo["aps"] as? NSDictionary {
                if let message = aps["alert"] as? String {
                    if let details = userInfo["details"] as? NSDictionary {
                        if let type = details["type"] as? String {
                            if type == PushNotification.sessionStart {
                                UIAlertView(title: alertTitle, message: message, delegate: nil, cancelButtonTitle: "Ok").show()
                                deepLinkNotification(details)
                            } else if type == PushNotification.sessionExtend {
                                showSessionExtensionAlert(message)
                            } else if type == PushNotification.sessionSuccess || type == PushNotification.sessionFail {
                                 NSNotificationCenter.defaultCenter().postNotificationName(PushNotification.sessionNotif, object: nil, userInfo: ["session" : details])
                            } else {
                                showNotificationAlert(message)
                            }
                        } else {
                            showNotificationAlert(message)
                        }
                    } else {
                        showNotificationAlert(message)
                    }
                }
            }
        } else {
            notifInactive()
        }
    }
    
    func checkTimeReached(timer: NSTimer) {
        if let userInfo = timer.userInfo as? NSDictionary {
            if let details = userInfo["session"] as? NSDictionary {
                if Globals.convertTime(NSDate()) == (details["start_time"] as! String) {
                    NSNotificationCenter.defaultCenter().postNotificationName(PushNotification.timerNotif, object: nil, userInfo: ["session" : details, "time": appDelegate.configDictionary[TimeOut.sessionDuration]!.integerValue])
                    timer.invalidate()
                }
            }
        }
    }
    
    func deepLinkNotification(details: NSDictionary) {
        if Globals.convertDate(NSDate()) == (details["alloted_date"] as! String) {
            if Globals.convertTime(NSDate()) >= (details["end_time"] as! String) {
                return
            } else if (Globals.convertTime(NSDate())>=(details["start_time"] as! String)) && (Globals.convertTime(NSDate())<(details["end_time"] as! String)) {
                let formatter        = NSDateFormatter()
                formatter.dateFormat = "HH:mm"
                formatter.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
                let startTime        = formatter.dateFromString(details["start_time"] as! String)
                let endTime          = formatter.dateFromString(details["end_time"] as! String)
                let currentTime      = formatter.dateFromString(Globals.convertTime(NSDate()))
                let timeDiff         = endTime!.timeIntervalSinceDate(currentTime!)/NSTimeInterval(secondsValue)
                NSNotificationCenter.defaultCenter().postNotificationName(PushNotification.timerNotif, object: nil, userInfo: ["session" : details, "time": Int(timeDiff)])
            } else if Globals.convertTime(NSDate()) < (details["start_time"] as! String) {
                NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: "checkTimeReached:", userInfo: ["session" : details], repeats: false)
                NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "checkTimeReached:", userInfo: ["session" : details], repeats: true)
            }
            println("show timer")
            
        }
    }
    
    
    func notifInactive() {
        if notificationArray.count > 0 {
            let notificationInfo = notificationArray.lastObject as? NSDictionary
            if let userInfo = notificationInfo {
                println(userInfo)
                if let aps = userInfo["aps"] as? NSDictionary {
                    if let message = aps["alert"] as? String {
                        if let details = userInfo["details"] as? NSDictionary {
                            if let type = details["type"] as? String {
                                if type == PushNotification.sessionStart {
                                    UIAlertView(title: alertTitle, message: message, delegate: nil, cancelButtonTitle: "Ok").show()
                                    deepLinkNotification(details)
                                } else if type == PushNotification.sessionExtend {
                                    showSessionExtensionAlert(message)
                                } else if type == PushNotification.sessionSuccess || type == PushNotification.sessionFail {
                                    NSNotificationCenter.defaultCenter().postNotificationName(PushNotification.sessionNotif, object: nil, userInfo: ["session" : details])
                                }
                            }
                        }
                    }
                }
                
            }
            notificationArray.removeLastObject()
        }
    }
    
    func deepLinkExtendNotification(accept: Int) {
        if notificationArray.count > 0 {
            let notificationInfo = notificationArray.lastObject as? NSDictionary
            if let userInfo = notificationInfo {
                println(userInfo)
                if let details = userInfo["details"] as? NSDictionary {
                    if let type = details["type"] as? String {
                        if type == PushNotification.sessionExtend {
                            sendRequestToExtendTrainerSession(details, accept: accept)
                        }
                    }
                }
            }
            notificationArray.removeLastObject()
        }
    }
    
    func showSessionExtensionAlert(message: String) {
        var alertView       = UIAlertView()
        alertView.delegate  = self
        alertView.title     = alertTitle
        alertView.message   = message
        alertView.tag       = 999
        alertView.addButtonWithTitle("No")
        alertView.addButtonWithTitle("Yes")
        alertView.show()
    }
    
    
    func showNotificationAlert(message: String) {
        var alertView       = UIAlertView()
        alertView.delegate  = self
        alertView.title     = alertTitle
        alertView.message   = message
        alertView.addButtonWithTitle("Ok")
        alertView.show()
    }
    
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex{
        case 0:
            if View.tag == 999 {
                deepLinkExtendNotification(0)
            } else {
                if notificationArray.count > 0 {
                    let notificationUserInfo = notificationArray.lastObject as? NSDictionary
                    notificationArray.removeLastObject()
                }
            }
           
        case 1:
            if View.tag == 999 {
                deepLinkExtendNotification(1)
            } else {
                if notificationArray.count > 0 {
                    let notificationUserInfo = notificationArray.lastObject as? NSDictionary
                    notificationArray.removeLastObject()
                }
            }

        default:
            break;
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location =   manager.location {
            if let currentLocation = appDelegate.currentLocation {
                if (currentLocation.coordinate.latitude == location.coordinate.latitude) && (currentLocation.coordinate.longitude == currentLocation.coordinate.longitude) {
                    return
                }
            }
            currentLocation =   location
            NSNotificationCenter.defaultCenter().postNotificationName("showLocation", object: nil, userInfo: nil)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
    }

    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if url.absoluteString?.hasPrefix("fb") == true {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        return true
    }
    
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "ti.FitHUDL" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("FitHUDL", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("FitHUDL.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        let options = Dictionary(dictionaryLiteral: (NSMigratePersistentStoresAutomaticallyOption, true),(NSInferMappingModelAutomaticallyOption, true))
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

