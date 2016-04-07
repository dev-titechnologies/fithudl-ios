//
//  FaceBookShareViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 18/02/16.
//  Copyright (c) 2016 Ti Technologies. All rights reserved.
//

import UIKit

class FaceBookShareViewController: UIViewController {


    @IBOutlet weak var shareOkButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        shareOkButton.layer.cornerRadius    = 23.0
        shareOkButton.layer.borderWidth     = 2.0
        shareOkButton.layer.borderColor     = AppColor.statusBarColor.CGColor
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func closeAction(sender: AnyObject) {
         dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareButtonAction(sender: AnyObject) {
        
        self.showShareDialogBox("khlfg")
        
    }

    func showShareDialogBox(shareImageURL: String) {
        
        println("Show share dialogs fb")
        let shareContent            = FBSDKShareLinkContent()
        shareContent.contentTitle   = alertTitle
        //shareContent.imageURL       = NSURL(string: SERVER_URL.stringByAppendingString(shareImageURL))
        shareContent.contentURL     = NSURL(string: SHARE_URL)
        shareContent.contentDescription = "Hurray, I have completed 8 hours this week. Get fit with Pillar!"
        
        let shareDialog             = FBSDKShareDialog()
        shareDialog.shareContent    = shareContent
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "fb://")!) {
            shareDialog.mode        = FBSDKShareDialogMode.Native
        } else {
            shareDialog.mode        = FBSDKShareDialogMode.FeedWeb
        }
        shareDialog.fromViewController = self
        shareDialog.delegate        = self
        shareDialog.show()
        
        var error: NSError?
        if (!shareDialog.validateWithError(&error)){
            println(error)
        }
        
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
extension FaceBookShareViewController: FBSDKSharingDelegate {
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        println("FBBBBB \(results)")
        println("SHAREE \(sharer)")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        
        println("CAncel")
        
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        
        println("Eorror \(error)")
        
    }
}


