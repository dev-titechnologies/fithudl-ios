//
//  CardDetailsViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 15/02/16.
//  Copyright (c) 2016 Ti Technologies. All rights reserved.
//

import UIKit

class CardDetailsViewController: UIViewController {
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cardNumberField: UITextField!
    @IBOutlet weak var expiryDateField: UITextField!
    @IBOutlet weak var ccvField: UITextField!
    @IBOutlet weak var contentViewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var monthPicker: UIView!
    var activeField : UITextField!
    @IBOutlet weak var monthPick: SRMonthPicker!
    var selectedDate : NSDate = NSDate()
    var stripToken : String = ""
    var rechargeAmount : NSInteger = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        if IS_IPHONE4S || IS_IPHONE5 {
         
            contentViewHeightConstant.constant = 400
        }
        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        let dateFormatter        = NSDateFormatter()
        dateFormatter.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MMM yyyy"
        //monthButton.setTitle(dateFormatter.stringFromDate(NSDate()).uppercaseString, forState: .Normal)
        dateFormatter.dateFormat = "YYYY"
        monthPick.minimumYear    = dateFormatter.stringFromDate(NSDate()).toInt()!
        monthPick.maximumYear    = monthPick.minimumYear+25
        monthPick.font           = UIFont(name: "Open-Sans", size: 17.0)
        monthPick.fontColor      = UIColor(red: 0, green: 120/255, blue: 109/255, alpha: 1.0)
        
       
    }
    
    
    @IBAction func stripeDoneAction(sender: AnyObject) {
        
        if nameTextField.text.isEmpty {
            self.alertMessage("Please Enter Your Name")
        } else if cardNumberField.text.isEmpty {
            self.alertMessage("Please Enter Your Card Number")
        } else if expiryDateField.text.isEmpty {
            self.alertMessage("Please Enter Expiration Date")
        } else if ccvField.text.isEmpty {
            self.alertMessage("Please Enter Security Code")
        }
        else {
            
        showLoadingView(true)
        let creditCard = STPCard()
        creditCard.number = cardNumberField.text
        creditCard.cvc = ccvField.text
        creditCard.name = nameTextField.text
        
        if (!expiryDateField.text.isEmpty){
            
            let formatter    = NSDateFormatter()
            formatter.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
            formatter.dateFormat = "MM yyyy"
            
            let expArr = formatter.stringFromDate(selectedDate).componentsSeparatedByString(" ")
            if (expArr.count > 1)
            {
                var expMonth: NSNumber = expArr[0].toInt()!
                var expYear: NSNumber = expArr[1].toInt()!
                println("month \(expMonth)")
                creditCard.expMonth = expMonth.unsignedLongValue
                creditCard.expYear = expYear.unsignedLongValue
            }
        }
        
        var error: NSError?
        if (creditCard.validateCardReturningError(&error)){
            var stripeError: NSError!
            Stripe.createTokenWithCard(creditCard, completion: { (token, stripeError) -> Void in
                if (stripeError != nil){
                    println("there is error");
                     self.alertMessage("Some Error Occured")
                     self.showLoadingView(false)
                }
                else{
                    self.cardNumberField.text = ""
                    self.expiryDateField.text = ""
                    self.ccvField.text = ""
                    self.nameTextField.text = ""
                    
//                    var alert = UIAlertController(title: "Your stripe token is: " + token.tokenId, message: "", preferredStyle: UIAlertControllerStyle.Alert)
//                    var defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
//                    alert.addAction(defaultAction)
//                    self.presentViewController(alert, animated: true, completion: nil)
                    self.stripToken = token.tokenId
                    self.postStripeToken(token)
                    
                }
            })
        }else{
             showLoadingView(false)
            var alert = UIAlertController(title: "Please enter valid credit card details", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            var defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        }
    }
    
    func alertMessage(message : String){
        
        UIAlertView(title: alertTitle, message: message, delegate: self, cancelButtonTitle: "OK").show()
        
    }
    
    @IBAction func expiryButtonAction(sender: AnyObject) {
        
        nameTextField.resignFirstResponder()
        cardNumberField.resignFirstResponder()
        ccvField.resignFirstResponder()
        monthPicker.hidden = false
        activeField = expiryDateField
    }
    
    @IBAction func monthPickerCancelAction(sender: AnyObject) {
        monthPicker.hidden = true
        
    }
    
    
    @IBAction func monthPickerDoneButtonClicked(sender: AnyObject) {
        
        let components   = NSDateComponents()
        components.month = monthPick.selectedMonth
        components.year  = monthPick.selectedYear
        selectedDate = NSCalendar.currentCalendar().dateFromComponents(components)!
        let formatter    = NSDateFormatter()
        formatter.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "MMM yyyy"
        expiryDateField.text = formatter.stringFromDate(selectedDate).uppercaseString
        monthPicker.hidden = true
        
    }
    
    //MARK: TextField operations
    
    
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
        } else if textField == cardNumberField {
            let validCharSet    = NSCharacterSet(charactersInString: "1234567890")
            let nameText        = NSCharacterSet(charactersInString: textField.text.stringByAppendingString(string))
            let stringIsValid   = validCharSet.isSupersetOfSet(nameText)
            return stringIsValid
        }
        return true;
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backAction(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }


    func postStripeToken(token: STPToken) {
        println("STRIPE Token")
        let URL = "http://192.168.1.65/fithudl/donate/payment.php"
        let params = ["stripeToken":token.tokenId,"amount":rechargeAmount,"currency":"usd","description":"HELLOOO"]
        println("PARAM \(params)")
        
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.POST(URL, parameters: params, success: { (operation, responseObject) -> Void in
            
            if let response = responseObject as? [String: String] {
                println("STRIPE \(response)")
                
//                UIAlertView(title: response["status"],
//                    message: response["message"],
//                    delegate: nil,
//                    cancelButtonTitle: "OK").show()
                    //self.showLoadingView(false)
                
                self.requestForSendingTransactionId()
            }
            
            }) { (operation, error) -> Void in
               println("STRIPE ERROR \(error)")
                self.alertMessage("Some Error Occured")
                  self.showLoadingView(false)
        }
    }
    
    
    
    func requestForSendingTransactionId() {
        if !Globals.isInternetConnected() {
            return
        }
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(rechargeAmount, forKey: "amount")
        requestDictionary.setObject(0, forKey: "discount")
        requestDictionary.setObject(0, forKey: "package_id")
        requestDictionary.setObject("", forKey: "package_name")
        requestDictionary.setObject("Stripe", forKey: "transaction_method")
        
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "sessions/transaction", requestType: HttpMethod.post),delegate: self,tag: Connection.transactionRequest)
        
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
                if connection.connectionTag == Connection.transactionRequest {
                    if status == ResponseStatus.success {
                        UIAlertView(title: alertTitle, message: "Package purchase successful", delegate: nil, cancelButtonTitle: "OK").show()
                        showLoadingView(false)
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
    
    
        /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
