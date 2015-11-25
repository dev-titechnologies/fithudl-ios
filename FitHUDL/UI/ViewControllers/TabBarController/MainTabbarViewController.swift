//
//  MainTabbarViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 29/09/15.
//  Copyright © 2015 Ti Technologies. All rights reserved.
//

import UIKit

class MainTabbarViewController: UITabBarController {
    var session = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = UIColor.whiteColor()
        
        for tabItem in tabBar.items! {
            (tabItem as! UITabBarItem).setTitleTextAttributes([NSFontAttributeName: UIFont(name: "OpenSans", size: 14.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
            (tabItem as! UITabBarItem).image = (tabItem as! UITabBarItem).image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        }
        tabBar.selectionIndicatorImage = UIImage(named: "tabselection")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "timerStartNotification:", name: PushNotification.timerNotif, object: nil)
        // Do any additional setup after loading the view.
    }
    
    func timerStartNotification(notif:NSNotification) {
        let userInfo: NSDictionary  = notif.userInfo!
        session                     = userInfo["session"] as! NSDictionary
        let timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(secondsValue*5), target: self, selector: Selector("showTimer"), userInfo: nil, repeats: false)
    }
    
    func showTimer() {
        let controller  = storyboard?.instantiateViewControllerWithIdentifier("SessionTimerViewController") as! SessionTimerViewController
        controller.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        controller.sessionDictionary      = session
        selectedViewController!.presentViewController(controller, animated: true, completion: nil)
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
