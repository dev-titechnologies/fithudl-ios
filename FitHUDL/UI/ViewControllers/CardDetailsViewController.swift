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
                }
                else{
                    self.cardNumberField.text = ""
                    self.expiryDateField.text = ""
                    self.ccvField.text = ""
                    self.nameTextField.text = ""
                    
                    var alert = UIAlertController(title: "Your stripe token is: " + token.tokenId, message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    var defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(defaultAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                   // self.stripToken = token.tokenId
                    // self.sendRequestToGetStripe()
                    
                }
            })
        }else{
            
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backAction(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }

//    
//    func sendRequestToGetStripe() {
//        let requestDictionary = NSMutableDictionary()
//        if !Globals.checkNetworkConnectivity() {
//            return
//        }
//        requestDictionary.setObject(self.stripToken, forKey: "stripeToken")
//        requestDictionary.setObject(20, forKey: "amount")
//        requestDictionary.setObject("usd", forKey: "currency")
//        requestDictionary.setObject("hiiiii Stripe", forKey: "description")
//        showLoadingView(true)
//        CustomURLConnection(request: CustomURLConnection.createRequestForStripe(requestDictionary, methodName: "payment.php", requestType: HttpMethod.post),delegate: self,tag: Connection.striperequest)
//    }
//    
//    func connection(connection: CustomURLConnection, didReceiveResponse: NSURLResponse) {
//        connection.receiveData.length = 0
//    }
//    
//    func connection(connection: CustomURLConnection, didReceiveData data: NSData) {
//        connection.receiveData.appendData(data)
//    }
//    
//    func connectionDidFinishLoading(connection: CustomURLConnection) {
//        let response = NSString(data: connection.receiveData, encoding: NSUTF8StringEncoding)
//        println(response)
//        var error : NSError?
//        if let jsonResult = NSJSONSerialization.JSONObjectWithData(connection.receiveData, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
//            
//            println("STRIPE \(jsonResult)")
//            
//            if let status = jsonResult["status"] as? Int {
//                if connection.connectionTag == Connection.striperequest {
//                    if status == ResponseStatus.success {
//                        
//                        
//                      
//                    } else if status == ResponseStatus.error {
//                        if let message = jsonResult["message"] as? String {
//                            showDismissiveAlertMesssage(message)
//                        } else {
//                            showDismissiveAlertMesssage(ErrorMessage.invalid)
//                        }
//                    } else {
//                        if let message = jsonResult["message"] as? String {
//                            showDismissiveAlertMesssage(message)
//                        } else {
//                            showDismissiveAlertMesssage(ErrorMessage.sessionOut)
//                        }
//                    }
//                }
//            }
//        }
//        
//    }
//    
//    func connection(connection: CustomURLConnection, didFailWithError error: NSError) {
//        showDismissiveAlertMesssage(error.localizedDescription)
//        showLoadingView(false)
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
