//
//  ReportViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 28/03/16.
//  Copyright (c) 2016 Ti Technologies. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {

    @IBOutlet weak var violenceButton: UIButton!
    @IBOutlet weak var nudityButton: UIButton!
    @IBOutlet weak var annoyingButton: UIButton!
    @IBOutlet weak var spamButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    var ProfileIDOtherUser: NSString = ""
    @IBOutlet weak var descriptionTextView: UITextView!
    var placeholderLabel : UILabel!
    var reportType: NSString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "Enter your comments..."
        placeholderLabel.font = UIFont.italicSystemFontOfSize(descriptionTextView.font.pointSize)
        placeholderLabel.sizeToFit()
        descriptionTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPointMake(5, descriptionTextView.font.pointSize / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.hidden = !descriptionTextView.text.isEmpty
        
        submitButton.layer.cornerRadius = 1.0
        submitButton.layer.borderWidth  = 1.0
        submitButton.layer.borderColor = AppColor.statusBarColor.CGColor
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchased:", name: IAPHelperProductPurchasedNotification, object: nil)
    }
    
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = !textView.text.isEmpty
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    //MARK: TextField operations
    
    
    func keyboardWasShown(notification: NSNotification)
    {
        //Need to calculate keyboard exact size due to Apple suggestions
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.view.frame.origin.y -= keyboardSize!.height-50
        
    }
    
    func keyboardWillBeHidden(notification: NSNotification)
    {
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.view.frame.origin.y += keyboardSize!.height-50
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var closeButtonAction: UIButton!
    
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func checkBoxAction(sender: UIButton) {
        
        
        if sender == spamButton{
            sender.selected = true
            annoyingButton.selected = false
            nudityButton.selected = false
            violenceButton.selected = false
            reportType = "Abuse & Spam"
        } else if sender == annoyingButton {
            sender.selected = true
            spamButton.selected = false
            nudityButton.selected = false
            violenceButton.selected = false
            reportType = "Underage Children"
        } else if sender == nudityButton {
            
            sender.selected = true
            spamButton.selected = false
            annoyingButton.selected = false
            violenceButton.selected = false
            reportType = "Harassment & Offensive"
        } else if sender == violenceButton {
            
            sender.selected = true
            spamButton.selected = false
            annoyingButton.selected = false
            nudityButton.selected = false
            reportType = "Other"
        }
        
    }
    
    
    @IBAction func SubmitAction(sender: UIButton) {
        
        
        if reportType == "" {
           // descriptionTextView.resignFirstResponder()
            UIAlertView(title: alertTitle, message: "Please select a type", delegate: self, cancelButtonTitle: "OK").show()
            return
        } else if descriptionTextView.text == "" {
            //descriptionTextView.resignFirstResponder()
            UIAlertView(title: alertTitle, message: "Please enter your comments", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        

        self.sendRequestToUpdateBooking()
        
    }

    
    //MARK: Report User API Call
    
    func sendRequestToUpdateBooking() {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
            var otherId:Int = ProfileIDOtherUser.integerValue
            requestDictionary.setObject(appDelegate.user!.profileID, forKey: "user_id")
            requestDictionary.setObject(otherId, forKey: "profile_id")
            requestDictionary.setObject(reportType, forKey: "report_type")
           requestDictionary.setObject(descriptionTextView.text, forKey: "description")
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "user/reportAbuse", requestType: HttpMethod.post),delegate: self,tag: Connection.reportRequest)
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
                if connection.connectionTag == Connection.reportRequest {
                    if status == ResponseStatus.success {
                        self.dismissViewControllerAnimated(true, completion: nil)
                        if let message = jsonResult["message"] as? String {
                            UIAlertView(title: alertTitle, message: "Reported Successfully", delegate: self, cancelButtonTitle: "OK").show()
                        }
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
                } else {
                    
                }
            }
        }
        showLoadingView(false)
    }
    
    func connection(connection: CustomURLConnection, didFailWithError error: NSError) {
        showDismissiveAlertMesssage(error.localizedDescription)
        showLoadingView(false)
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
