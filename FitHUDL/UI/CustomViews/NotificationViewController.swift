//
//  NotificationViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 06/11/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {

    @IBOutlet weak var notificationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib  = UINib(nibName: "NotificationCell", bundle: nil)
        notificationTableView.registerNib(nib, forCellReuseIdentifier: "Cell")
        
        // Do any additional setup after loading the view.
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
extension NotificationViewController : UITableViewDataSource {
    
   
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NotificationCell
        cell.roundLabel.layer.cornerRadius = 10.0
        cell.roundLabel.layer.borderColor = UIColor.clearColor().CGColor
        cell.roundLabel.clipsToBounds=true
        
        cell.profilePic.layer.cornerRadius = 25.0
        cell.profilePic.layer.borderColor = UIColor.clearColor().CGColor
        cell.profilePic.clipsToBounds=true

        return cell
    }
}

extension NotificationViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
}
