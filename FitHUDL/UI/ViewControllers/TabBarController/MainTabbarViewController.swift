//
//  MainTabbarViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 29/09/15.
//  Copyright © 2015 Ti Technologies. All rights reserved.
//

import UIKit

class MainTabbarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = UIColor.whiteColor()
        
        for tabItem in tabBar.items! {
            (tabItem as! UITabBarItem).setTitleTextAttributes([NSFontAttributeName: UIFont(name: "OpenSans", size: 11.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
            (tabItem as! UITabBarItem).image = (tabItem as! UITabBarItem).image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        }
        
        if IS_IPHONE6 || IS_IPHONE6PLUS {
            
             tabBar.selectionIndicatorImage = UIImage(named: "tabselectionLarge")
            
        } else {
           
             tabBar.selectionIndicatorImage = UIImage(named: "tabselection")
        }
        
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "timerStartNotification:", name: PushNotification.timerNotif, object: nil)
        
        let toLeftSwipe = UISwipeGestureRecognizer(target: self, action: "swipeRightToLeft")
        toLeftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        view.addGestureRecognizer(toLeftSwipe)
       
        let toRightSwipe = UISwipeGestureRecognizer(target: self, action: "swipeLeftToRight")
        toRightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(toRightSwipe)
        
        // Do any additional setup after loading the view.
    }
    
    func swipeRightToLeft() {
        println("to left")
        if selectedIndex == 3 {
            return
        }
        selectedIndex += 1
    }
    
    func swipeLeftToRight() {
        println("to right")
        if selectedIndex == 0 {
            return
        }
        selectedIndex -= 1
    }
    
    
    func timerStartNotification(notif:NSNotification) {
        let userInfo: NSDictionary  = notif.userInfo!
        showTimer(userInfo["session"] as! NSMutableDictionary, time: userInfo["time"] as! Int)
    }
    
    func showTimer(session: NSMutableDictionary, time: Int) {
        let controller  = storyboard?.instantiateViewControllerWithIdentifier("SessionTimerViewController") as! SessionTimerViewController
        controller.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        
        controller.sessionDictionary      = session
        controller.time                   = time
        selectedViewController!.presentViewController(controller, animated: true, completion: nil)
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        if selectedIndex == 1 {
            (selectedViewController as! UINavigationController).popToRootViewControllerAnimated(true)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
