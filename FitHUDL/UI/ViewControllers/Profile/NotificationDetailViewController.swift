//
//  NotificationDetailViewController.swift
//  
//
//  Created by Ti Technologies on 19/05/16.
//
//

import UIKit

class NotificationDetailViewController: UIViewController {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
     var notification: Notification? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        profilePic.layer.cornerRadius = 35
        profilePic.clipsToBounds = true
        // Do any additional setup after loading the view.
        
        if let notif = notification {
            
            messageLabel.text       = notif.message
            
            var imageUrl:String = ""
            
            if notif.type == TrainingStatus.requested {
                
                imageUrl                 = notif.userImage
                 nameLabel.text          = notif.userName
                 messageLabel.text = "has requested for \(notif.sportsName)"
                
            } else if notif.type == TrainingStatus.accepted {
                imageUrl            = notif.trainerImage
                nameLabel.text = notif.trainerName
                messageLabel.text = "has accepted your booking request"
            } else {
                imageUrl            = notif.userImage
                nameLabel.text      = notif.userName
               
               // messageLabel.numberOfLines = 0;
                messageLabel.text   = notif.message
               // messageLabel.sizeToFit()
            }
            
            profilePic.image       = UIImage(named: "default_image")
            profilePic.contentMode = UIViewContentMode.ScaleAspectFit
            let imageurl                = SERVER_URL.stringByAppendingString(imageUrl as String) as NSString
            if imageurl.length != 0 {
                if var imagesArray = Images.fetch(imageurl as String) {
                    let image      = imagesArray[0] as! Images
                    let coverImage = UIImage(data: image.imageData)!
                    profilePic.contentMode = UIViewContentMode.ScaleAspectFill
                    profilePic.image = UIImage(data: image.imageData)!
                }
        }
            
    }
    }

    @IBAction func closeButtonAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
