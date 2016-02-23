//
//  SessionTimerViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 16/11/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class SessionTimerViewController: UIViewController {
//    @IBOutlet weak var circleView: UIView!
//    @IBOutlet weak var timerView: TimerView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var timerLabel: MZTimerLabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    
    @IBOutlet weak var starView: UIView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var rateOkButton: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var rateView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var sportsImageView: UIImageView!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var shareOkButton: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var sessionDictionary: NSDictionary!
    var starOne: UIButton!
    var starTwo: UIButton!
    var starThree: UIButton!
    var starFour: UIButton!
    var starFive: UIButton!
    var userRate = 0
    var isTrainer = false
    var imagePath = ""
    var notShared = false
    var time:Int  = 0
    var circleTimer: CircularTimer!
    var sessionTimer: NSTimer!
    var alertInteracted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timerLabel.timerType = MZTimerLabelTypeTimer
        timerLabel.timeLabel = timerLabel
        timerLabel.delegate  = self
        timerLabel.setCountDownTime(NSTimeInterval(time*secondsValue))
        
        rateOkButton.layer.cornerRadius     = 23.0
        rateOkButton.layer.borderWidth      = 2.0
        rateOkButton.layer.borderColor      = AppColor.statusBarColor.CGColor
        shareOkButton.layer.cornerRadius    = 23.0
        shareOkButton.layer.borderWidth     = 2.0
        shareOkButton.layer.borderColor     = AppColor.statusBarColor.CGColor
        commentTextView.layer.borderWidth   = 0.5
        commentTextView.layer.borderColor   = AppColor.statusBarColor.CGColor
        
        starOne     = starView.viewWithTag(90) as! UIButton
        starTwo     = starView.viewWithTag(91) as! UIButton
        starThree   = starView.viewWithTag(92) as! UIButton
        starFour    = starView.viewWithTag(93) as! UIButton
        starFive    = starView.viewWithTag(94) as! UIButton
        
        let sportsName = sessionDictionary["sports_name"] as? String
        
        
        if let currentUser = appDelegate.user {
            if sessionDictionary["user_id"] as! Int == currentUser.profileID {
                isTrainer = false
                let name  = sessionDictionary["trainer_name"] as? String
                nameLabel.text = "\(sportsName!) session with \(name!)"
            } else if sessionDictionary["trainer_id"] as! Int == currentUser.profileID {
                isTrainer = true
                let name  = sessionDictionary["user_name"] as? String
                nameLabel.text = "\(sportsName!) session with \(name!)"
            }
        }

        let startTime = Globals.convertTimeTo12Hours((sessionDictionary["start_time"] as? String)!)
        let endTime = Globals.convertTimeTo12Hours((sessionDictionary["end_time"] as? String)!)
        
        startTimeLabel.text = "START TIME " + startTime
        endTimeLabel.text   = "END TIME " + endTime
        
        if !isTrainer {
            let filteredArray = appDelegate.sportsArray.filteredArrayUsingPredicate(NSPredicate(format: "sportsId = %d", argumentArray: [sessionDictionary.objectForKey("sports_id") as! Int])) as NSArray
            let sportsUrl   = (filteredArray.firstObject as! SportsList).logo
            sportsImageView.image = UIImage(named: "default_image")
            sportsImageView.contentMode = UIViewContentMode.ScaleAspectFit
            CustomURLConnection.downloadAndSetImage(sportsUrl, imageView: sportsImageView, activityIndicatorView: indicatorView)
            let name        = sessionDictionary["user_name"] as! String
            let sport       = (sessionDictionary["sports_name"] as! String).uppercaseString
            shareLabel.text = "\(name) just completed a \(sport) session on"
            timeLabel.text  = "Time: \(startTime) to \(endTime)"
            sendRequestforShareImageUrl(Globals.createShareImage(sportsImageView.image!, shareText: shareLabel.text!, parentView: self.view))
        }
        // Do any additional setup after loading the view.
    }
    
    func getDate(stringDate: String) -> NSDate {
        let dateFormatter        = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.dateFromString(stringDate)!
    }
    
    func createTimer() {
        
        circleTimer = CircularTimer(position: CGPoint(x: (self.view.frame.size.width-160)/2, y: 125), radius: 80, internalRadius: 78, circleStrokeColor: AppColor.timerColor, activeCircleStrokeColor: AppColor.boxBorderColor, initialDate: getDate((sessionDictionary["start_time"] as? String)!), finalDate: getDate((sessionDictionary["end_time"] as? String)!), startCallback: { () -> Void in
            }, endCallback: { () -> Void in
        })
        
        println("contentview frame \(self.view.frame.size.width)")
        circleTimer.translatesAutoresizingMaskIntoConstraints()
      //  circleTimer.center = CGPoint(x: timerLabel.center.x, y: circleTimer.center.y)
        circleTimer.layoutIfNeeded()
        view.addSubview(circleTimer)
        statusLabel.text = "The session has been started."
        timerLabel.start()
    }
    
    func removeTimer() {
        if let timer = circleTimer {
            circleTimer.removeFromSuperview()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        createTimer()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startSessionExtension:", name: PushNotification.sessionNotif, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        removeTimer()
    }
    
    func showUserRateView() {
        removeTimer()
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.contentView.hidden  = true
            self.rateView.hidden     = false
        })
    }
    
    func startSessionExtension(notif: NSNotification) {
        if let userInfo = notif.userInfo {
            let session = userInfo["session"] as! NSDictionary
            if let type = session["type"] as? String {
                if type == PushNotification.sessionFail {
                    if !isTrainer {
                        showUserRateView()
                    } else {
                        dismissViewControllerAnimated(true, completion: nil)
                    }
                    return
                }
            }
            if let extend = session["extend"] as? Int {
                if extend == 1 {
                    self.rateView.hidden     = true
                    self.shareView.hidden    = true
                    self.contentView.hidden  = false
                    sessionDictionary        = session
                    timerLabel.reset()
                    let formatter        = NSDateFormatter()
                    formatter.dateFormat = "HH:mm"
                    formatter.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
                    let endTimer         = formatter.dateFromString(session["end_time"] as! String)
                    let currentTime      = formatter.dateFromString(Globals.convertTime(NSDate()))
                    let timeDiff         = endTimer!.timeIntervalSinceDate(currentTime!)/NSTimeInterval(secondsValue)
                    timerLabel.setCountDownTime(NSTimeInterval(Int(timeDiff)*secondsValue))
                    removeTimer()
                    
                    let startTime = Globals.convertTimeTo12Hours((sessionDictionary["start_time"] as? String)!)
                    let endTime = Globals.convertTimeTo12Hours((sessionDictionary["end_time"] as? String)!)
                    startTimeLabel.text = "START TIME " + startTime
                    endTimeLabel.text   = "END TIME " + endTime
                    createTimer()
                    
                } else {
                    dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    func showFBShareView() {
        sendRequestforShareImageUrl(Globals.createShareImage(sportsImageView.image!, shareText: shareLabel.text!, parentView: self.view))
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.rateView.hidden     = true
            self.shareView.hidden    = false
        })
    }
    
    func showShareDialogBox(shareImageURL: String) {
        let shareContent            = FBSDKShareLinkContent()
        shareContent.contentTitle   = alertTitle
        shareContent.imageURL       = NSURL(string: SERVER_URL.stringByAppendingString(shareImageURL))
        shareContent.contentURL     = NSURL(string: SHARE_URL)
        shareContent.contentDescription = "Join \(alertTitle)!"
        
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

    
    @IBAction func userRate(sender: UIButton) {
        let selectedState = sender.selected
        if sender == starOne {
            if !selectedState {
                userRate = 1
            } else {
                userRate = 0
                starTwo.selected    = false
                starThree.selected  = false
                starFour.selected   = false
                starFive.selected   = false
            }
        } else if sender == starTwo {
            if !selectedState {
                userRate = 2
                starOne.selected = true
            } else {
                userRate = 1
                starThree.selected  = false
                starFour.selected   = false
                starFive.selected   = false
            }
        } else if sender == starThree {
            if !selectedState {
                userRate = 3
                starOne.selected    = true
                starTwo.selected    = true
            } else {
                userRate = 2
                starFour.selected   = false
                starFive.selected   = false
            }
        } else if sender == starFour{
            if !selectedState {
                userRate = 4
                starOne.selected    = true
                starTwo.selected    = true
                starThree.selected  = true
            } else {
                userRate = 3
                starFive.selected   = false
            }
        } else if sender == starFive{
            if !selectedState {
                userRate = 5
                starOne.selected    = true
                starTwo.selected    = true
                starThree.selected  = true
                starFour.selected   = true
            } else {
                userRate = 4
            }
        }
        sender.selected = !selectedState
    }
    
    @IBAction func rateOkButtonClicked(sender: UIButton) {
        sendRequestToRateUser()
        if !isTrainer {
            showFBShareView()
        }
    }
    
    @IBAction func shareOkButtonClicked(sender: UIButton) {
        if imagePath == "" {
            showLoadingView(true)
            notShared = true
        } else {
            showShareDialogBox(imagePath)
        }
    }
    
    @IBAction func closeButtonClicked(sender: UIButton) {
        if !isTrainer && shareView.hidden {
            showFBShareView()
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func autoCompleteSession() {
        presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        sendRequestToExtendSession(Session.complete)
    }
    
    func showSessionExtensionAlert() {
        let alert = UIAlertController(title: "", message: "The session is complete. Do you wish to extend the session?", preferredStyle: UIAlertControllerStyle.Alert)
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (yesAction) -> Void in
            self.sessionTimer.invalidate()
            self.alertInteracted = true
            self.sendRequestToExtendSession(Session.extend)
        }
        let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) { (noAction) -> Void in
            self.sessionTimer.invalidate()
            self.alertInteracted = true
            self.sendRequestToExtendSession(Session.complete)
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        presentViewController(alert, animated: true) { () -> Void in
            self.sessionTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(4*secondsValue), target: self, selector: "autoCompleteSession", userInfo: nil, repeats: false)
            return
        }
    }
    
    func showSessionAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (okAction) -> Void in
            if !self.isTrainer {
                self.showUserRateView()
            }
            return
        }
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - API
    
    func sendRequestToExtendSession(extends: Int) {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(sessionDictionary["booking_id"]!, forKey: "booking_id")
        requestDictionary.setObject(extends, forKey: "session_extends")
        var connectTag = Connection.sessionComplete
        if extends == Session.extend {
            connectTag = Connection.sessionExtend
        }
        alertInteracted = false
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "sessions/sessionExtension", requestType: HttpMethod.post),delegate: self,tag: connectTag)
    }
    
    func sendRequestToRateUser() {
        if !Globals.isInternetConnected() {
            return
        }
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(userRate, forKey: "rating_count")
        requestDictionary.setObject(commentTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()), forKey: "rating_comment")
        
        var userID = 0
        if isTrainer {
            userID = sessionDictionary["user_id"] as! Int
        } else {
            userID = sessionDictionary["trainer_id"] as! Int
        }
        requestDictionary.setObject(userID, forKey: "trainer_id")
        
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "rating/add", requestType: HttpMethod.post),delegate: self,tag: Connection.userRatingRequest)
    }
    
    func sendRequestforShareImageUrl(shareImage: UIImage) {
        if !Globals.isInternetConnected() {
            return
        }
        let requestDictionary = NSMutableDictionary()
        let imageData = UIImageJPEGRepresentation(shareImage, 1.0)
        let imageString = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
        requestDictionary.setObject(imageString, forKey: "image")
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "user/generateImageUrl", requestType: HttpMethod.post),delegate: self,tag: Connection.shareImageRequest)
    }
    
    func connection(connection: CustomURLConnection, didReceiveResponse: NSURLResponse) {
        connection.receiveData.length = 0
    }
    
    func connection(connection: CustomURLConnection, didReceiveData data: NSData) {
        connection.receiveData.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: CustomURLConnection) {
        let response = NSString(data: connection.receiveData, encoding: NSUTF8StringEncoding)
        println(response)
        var error : NSError?
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(connection.receiveData, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
            if let status = jsonResult["status"] as? Int {
                if connection.connectionTag == Connection.userRatingRequest {
                    if status == ResponseStatus.success {

                    } else if status == ResponseStatus.error {
                        if let message = jsonResult["message"] as? String {
                            showDismissiveAlertMesssage(message)
                        } else {
                            showDismissiveAlertMesssage(ErrorMessage.invalid)
                        }
                    } else {
                        if let message = jsonResult["message"] as? String {
                            showDismissiveAlertMesssage(message)
                        } else {
                            showDismissiveAlertMesssage(ErrorMessage.sessionOut)
                        }
                    }
                } else if connection.connectionTag == Connection.shareImageRequest {
                    if status == ResponseStatus.success {
                        if let path = jsonResult["imagePath"] as? String {
                            imagePath = path
                            if notShared {
                                notShared = false
                                showShareDialogBox(imagePath)
                            }
                        } else {
                            showDismissiveAlertMesssage("No image path available")
                        }
                    }
                } else {
                    if status == ResponseStatus.success {
                        if connection.connectionTag == Connection.sessionExtend {
                            if let extend = jsonResult["extend"] as? Int {
                                if extend == 1 {
                                    showDismissiveAlertMesssage("Please wait till your trainer respond to your session extension request!")
                                } else {
                                    if let message = jsonResult["message"] as? String {
                                        showSessionAlert(message)
                                    } else {
                                        showSessionAlert("This session cannot be extended!")
                                    }
                                }
                            }
                        } else if connection.connectionTag == Connection.sessionComplete {
                            if !isTrainer {
                                showUserRateView()
                            }
                        }
                    } else if status == ResponseStatus.error {
                        if let message = jsonResult["message"] as? String {
                            showDismissiveAlertMesssage(message)
                        } else {
                            showDismissiveAlertMesssage(ErrorMessage.invalid)
                        }
                        rateOkButton.hidden = false
                    } else {
                        if let message = jsonResult["message"] as? String {
                            showDismissiveAlertMesssage(message)
                        } else {
                            showDismissiveAlertMesssage(ErrorMessage.sessionOut)
                        }
                        rateOkButton.hidden = false
                    }
                }
            }
        }
        showLoadingView(false)
    }
    
    func connection(connection: CustomURLConnection, didFailWithError error: NSError) {
        showDismissiveAlertMesssage(error.localizedDescription)
        showLoadingView(false)
        if connection.connectionTag == Connection.sessionComplete || connection.connectionTag == Connection.sessionExtend {
            rateOkButton.hidden = false
        }
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

extension SessionTimerViewController: MZTimerLabelDelegate {
    func timerLabel(timerLabel: MZTimerLabel!, finshedCountDownTimerWithTime countTime: NSTimeInterval) {
        statusLabel.text = "This session is complete."
        if !isTrainer {
            showSessionExtensionAlert()
        } //else {
//            showUserRateView()
//        }
    }
}

extension SessionTimerViewController: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        if count(textView.text) == 0 {
            placeholderLabel.hidden = false
        } else {
            placeholderLabel.hidden = true
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            if count(textView.text) == 0 {
                placeholderLabel.hidden = false
            }
            return false
        }
        return true
    }
}

extension SessionTimerViewController: FBSDKSharingDelegate {
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        println(results)
        println(sharer)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        
    }
}
