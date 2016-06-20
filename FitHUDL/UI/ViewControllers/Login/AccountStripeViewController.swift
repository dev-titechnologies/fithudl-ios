//
//  AccountStripeViewController.swift
//  
//
//  Created by Ti Technologies on 12/05/16.
//
//

import UIKit

class AccountStripeViewController: UIViewController {
    
    var stripeFlag: NSString = ""
    @IBOutlet weak var accountType: UITextField!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var accountNumberField: UITextField!
    @IBOutlet weak var routingNumber: UITextField!
    var activeField : UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        if IS_IPHONE4S || IS_IPHONE5 {
            
            contentViewHeightConstant.constant = 400
        }
        navigationController?.navigationBar.tintColor = AppColor.statusBarColor
        navigationItem.hidesBackButton = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        

        //navigationController?.navigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - What's Stripe
    
    @IBAction func whatsStripeAction(sender: AnyObject) {
        
        let alert       = UIAlertController(title: "What's Stripe", message: "Lyft, Postmates, OrderAhead, Instacart, and thousands of other mobile applications use Stripe’s native iOS & Android libraries to charge on the go. Even collect cards up front for seamless background billing later,", preferredStyle: UIAlertControllerStyle.Alert)
        let noAction    = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (noAction) -> Void in
            return
        }
        let yesAction   = UIAlertAction(title: "Readmore", style: UIAlertActionStyle.Default) { (noAction) -> Void in
            
            let navController = self.storyboard?.instantiateViewControllerWithIdentifier("WebNavigationController") as! UINavigationController
            let webController = navController.topViewController as! WebViewController
            webController.viewTag = ViewTag.whatisStripe
            self.presentViewController(navController, animated: true, completion: nil)
        }
        alert.addAction(noAction)
        alert.addAction(yesAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    func keyboardWasShown(notification: NSNotification)
    {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollview.scrollEnabled = true
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollview.contentInset = contentInsets
        self.scrollview.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        
        println("Frame is\(activeField!.frame)")
        
        if let activeFieldPresent = activeField
        {
            if (!CGRectContainsPoint(aRect, activeField!.frame.origin))
            {
                self.scrollview.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
        
    }
    
    func keyboardWillBeHidden(notification: NSNotification)
    {
        //Once keyboard disappears, restore original positions
        
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollview.contentInset = contentInsets
        self.scrollview.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollview.scrollEnabled = false
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField!)
    {
        
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField!)
    {
        activeField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == nameTextField {
            let validCharSet    = NSCharacterSet(charactersInString: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ")
            let nameText        = NSCharacterSet(charactersInString: textField.text.stringByAppendingString(string))
            let stringIsValid   = validCharSet.isSupersetOfSet(nameText)
            return stringIsValid
        } else if textField == accountNumberField {
            
            let validCharSet    = NSCharacterSet(charactersInString: "1234567890")
            let nameText        = NSCharacterSet(charactersInString: textField.text.stringByAppendingString(string))
            let stringIsValid   = validCharSet.isSupersetOfSet(nameText)
            return (stringIsValid && count(textField.text) + (count(string) - range.length) <= 16)
            
        } else if textField == routingNumber {
            
            let validCharSet    = NSCharacterSet(charactersInString: "1234567890")
            let nameText        = NSCharacterSet(charactersInString: textField.text.stringByAppendingString(string))
            let stringIsValid   = validCharSet.isSupersetOfSet(nameText)
            return (stringIsValid && count(textField.text) + (count(string) - range.length) <= 9)
            
        }
        return true;
    }
    
    
    //Mark: Sending Stripe Details
    
    func alertMessage(message : String){
        
        UIAlertView(title: alertTitle, message: message, delegate: self, cancelButtonTitle: "OK").show()
        
    }
    
    @IBAction func accountTypeSelection(sender: AnyObject) {
        
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "Please select an account type", message: "", preferredStyle: .ActionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            
            self.accountType.text = ""
            print("Cancel")
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let saveActionButton: UIAlertAction = UIAlertAction(title: "Individual", style: .Default)
            { action -> Void in
                self.accountType.text = "Individual"
        }
        actionSheetControllerIOS8.addAction(saveActionButton)
        
        let deleteActionButton: UIAlertAction = UIAlertAction(title: "Company", style: .Default)
            { action -> Void in
                self.accountType.text = "Company"
                print("Delete")
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        self.presentViewController(actionSheetControllerIOS8, animated: true, completion: nil)
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        if nameTextField.text.isEmpty {
            self.alertMessage("Please Enter Your Name")
        } else if accountNumberField.text.isEmpty {
            self.alertMessage("Please Enter Your Account Number")
        } else if accountType.text.isEmpty {
            self.alertMessage("Please Enter Account Type")
        } else if routingNumber.text.isEmpty {
            self.alertMessage("Please Enter Security Code")
        } else if routingNumber.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 9 {
            self.alertMessage("Routing number should contain 9 digits")
        }
        else {
            self.showLoadingView(true)
            self.requestForSendingStripeDetails()
        }
        
    }
    
    @IBAction func questionButtonAction(sender: AnyObject) {
        
        UIAlertView(title: alertTitle, message: "Your bank account should be added as 'Recipient' (Payee) of Pillar Stripe account, to get you paid for sessions. Do not worry, we don't store your bank details anywhere. Stripe is secure enough to handle this.", delegate: self, cancelButtonTitle: "OK").show()
        
    }
    func requestForSendingStripeDetails() {
        if !Globals.isInternetConnected() {
            return
        }
        
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(nameTextField.text, forKey: "cname")
        requestDictionary.setObject(accountNumberField.text, forKey: "accountnumber")
        requestDictionary.setObject(routingNumber.text, forKey: "routingnumber")
        requestDictionary.setObject(accountType.text, forKey: "accounttype")
        requestDictionary.setObject("US", forKey: "country")
        requestDictionary.setObject("USD", forKey: "currency")
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "user/saveCustomer", requestType: HttpMethod.post),delegate: self,tag: Connection.stripeAccount)
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
        // showLoadingView(false)
        var error : NSError?
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(connection.receiveData, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
            if let status = jsonResult["status"] as? Int {
                if connection.connectionTag == Connection.stripeAccount {
                    if status == ResponseStatus.success {
                            performSegueWithIdentifier("stripeToProfile", sender: self)
                        // UIAlertView(title: alertTitle, message: "your stripe account has been created successfully", delegate: nil, cancelButtonTitle: "OK").show()
                        // showLoadingView(false)
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
                    
                    showLoadingView(false)
                }
            }
        }
        
    }
    
    func connection(connection: CustomURLConnection, didFailWithError error: NSError) {
        showDismissiveAlertMesssage(error.localizedDescription)
        showLoadingView(false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "modalSegueToTab" {
            for sport in appDelegate.sportsArray {
                (sport as! SportsList).level      = ""
                (sport as! SportsList).isSelected = false
            }
        }
    }
    
}