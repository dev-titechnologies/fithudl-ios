//
//  SessionTimerViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 16/11/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class SessionTimerViewController: UIViewController {
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var timerView: TimerView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var timerLabel: MZTimerLabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var starView: UIView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var rateOkButton: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var rateView: UIView!
    
    var sessionDictionary: NSDictionary!
    var starOne: UIButton!
    var starTwo: UIButton!
    var starThree: UIButton!
    var starFour: UIButton!
    var starFive: UIButton!
    var userRate = 0
    var isTrainer = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let radius        = max(circleView.frame.size.width,circleView.frame.size.height)
        circleView.layer.cornerRadius = CGFloat(radius)/2.0
        circleView.layer.borderWidth  = 2.0
        circleView.layer.borderColor  = AppColor.timerColor.CGColor
        timerLabel.timerType = MZTimerLabelTypeTimer
        timerLabel.timeLabel = timerLabel
        timerLabel.delegate  = self
        timerLabel.setCountDownTime(NSTimeInterval(appDelegate.configDictionary[TimeOut.sessionDuration]!.integerValue*secondsValue))
        
        rateOkButton.layer.cornerRadius     = 23.0
        rateOkButton.layer.borderWidth      = 2.0
        rateOkButton.layer.borderColor      = AppColor.statusBarColor.CGColor
        commentTextView.layer.borderWidth   = 0.5
        commentTextView.layer.borderColor   = AppColor.statusBarColor.CGColor
        
        starOne     = starView.viewWithTag(90) as! UIButton
        starTwo     = starView.viewWithTag(91) as! UIButton
        starThree   = starView.viewWithTag(92) as! UIButton
        starFour    = starView.viewWithTag(93) as! UIButton
        starFive    = starView.viewWithTag(94) as! UIButton
        
        if sessionDictionary["user_id"] as! Int == appDelegate.user.profileID {
            isTrainer = false
            nameLabel.text = sessionDictionary["trainer_name"] as? String
        } else if sessionDictionary["trainer_id"] as! Int == appDelegate.user.profileID {
            isTrainer = true
            nameLabel.text = sessionDictionary["user_name"] as? String
        }
        startTimeLabel.text = "START TIME " + Globals.convertTimeTo12Hours((sessionDictionary["start_time"] as? String)!)
        endTimeLabel.text   = "END TIME " + Globals.convertTimeTo12Hours((sessionDictionary["end_time"] as? String)!)
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        timerLabel.start()
        timerView.resetView()
    }
    
    func showUserRateView() {
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.contentView.hidden  = true
            self.rateView.hidden     = false
            self.closeButton.hidden  = false
        })
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
    }
    
    @IBAction func closeButtonClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showSessionExtensionAlert() {
        let alert = UIAlertController(title: "", message: "The session is complete. Do you wish to extend the session?", preferredStyle: UIAlertControllerStyle.Alert)
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (yesAction) -> Void in
            self.timerView.layer.sublayers.removeLast()
            self.timerView.setNeedsDisplay()
            self.timerLabel.reset()
            self.timerView.resetView()
            self.timerLabel.start()
            self.statusLabel.text = "This session has been started."
        }
        let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) { (noAction) -> Void in
            self.showUserRateView()
//            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func sendRequestToRateUser() {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
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
                if status == ResponseStatus.success {
                    self.dismissViewControllerAnimated(true, completion: nil)
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
            }
        }
        showLoadingView(false)
    }
    
    func connection(connection: CustomURLConnection, didFailWithError error: NSError) {
        showDismissiveAlertMesssage(error.localizedDescription)
        showLoadingView(false)
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
        showSessionExtensionAlert()
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
