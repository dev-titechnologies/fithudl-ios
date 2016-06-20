//
//  LoginViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 22/09/15.
//  Copyright © 2015 Ti Technologies. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var calloutViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var resetEmailTextField: UITextField!
    @IBOutlet weak var calloutView: UIView!
    @IBOutlet weak var calloutContentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rememberMeButton: UIButton!

    @IBOutlet weak var signInButton: UIButton!
    var selectedTextField: UITextField!
    let calloutViewYAxis:CGFloat = 45.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden   = false
                
        let colorAttributes     = [NSForegroundColorAttributeName: AppColor.placeholderText.colorWithAlphaComponent(0.5)]
        var placeHolderString   = NSAttributedString(string: emailTextField.placeholder!, attributes: colorAttributes)
        emailTextField.attributedPlaceholder = placeHolderString
        
        placeHolderString = NSAttributedString(string: passwordTextField.placeholder!, attributes: colorAttributes)
        passwordTextField.attributedPlaceholder = placeHolderString
        
        placeHolderString = NSAttributedString(string: resetEmailTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(red: 136/255, green: 136/255, blue: 136/255, alpha: 1.0)])
        resetEmailTextField.attributedPlaceholder = placeHolderString
        
        if let rememberemailString = NSUserDefaults.standardUserDefaults().valueForKey("rememberEmail") as? String{
            emailTextField.text = rememberemailString
            rememberMeButton.selected = true
        }
        if let rememberPass = NSUserDefaults.standardUserDefaults().valueForKey("rememberPassword") as? String
        {
            passwordTextField.text = rememberPass
        }
//        signInButton.layer.borderColor = UIColor.whiteColor().CGColor
        
//        emailTextField.text     = "ardra@test.com"
//        passwordTextField.text  = "123456"
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func rememberMeAction(sender: UIButton) {
        
        if sender.tag == 0 {
            
            sender.tag = 1
            sender.selected = true
            NSUserDefaults.standardUserDefaults().setValue(emailTextField.text, forKey: "rememberEmail")
            NSUserDefaults.standardUserDefaults().setValue(passwordTextField.text, forKey: "rememberPassword")
            
        } else{
            
            NSUserDefaults.standardUserDefaults().removeObjectForKey("rememberEmail")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("rememberPassword")
            sender.tag = 0
            sender.selected = false
            
        }
        
    }
    override func viewWillAppear(animated: Bool) {
        calloutView.removeFromSuperview()
        calloutView.setTranslatesAutoresizingMaskIntoConstraints(true)
        calloutView.frame = CGRect(x: 0.0, y: calloutViewYAxis, width: view.frame.size.width, height: 0)
        appDelegate.window?.addSubview(calloutView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        calloutView.removeFromSuperview()
        calloutView.frame = CGRect(x: 0.0, y: -17.0, width: view.frame.size.width, height: 0)
        self.view.addSubview(calloutView)
    }

    @IBAction func loginButtonClicked(sender: UIButton) {
        
        if rememberMeButton.selected == true{
            
            NSUserDefaults.standardUserDefaults().setValue(emailTextField.text, forKey: "rememberEmail")
            NSUserDefaults.standardUserDefaults().setValue(passwordTextField.text, forKey: "rememberPassword")
            
        }
        
        if validateFields() {
            sendLoginRequest()
        }
//        performSegueWithIdentifier("modalSeguetoTab", sender: self)
    }
    
    @IBAction func backButtonClicked(sender: UIButton) {
        if let textField = selectedTextField {
            selectedTextField.resignFirstResponder()
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func forgotPasswordButtonClicked(sender: UIButton) {
        resetEmailTextField.text = ""
        if calloutView.frame.size.height == 0 {
            UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.calloutView.frame = CGRect(x: 0.0, y: self.calloutViewYAxis, width: self.calloutView.frame.size.width, height: 95.0)
                }, completion: nil)
        } else {
            UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.calloutView.frame = CGRect(x: 0.0, y: self.calloutViewYAxis, width: self.calloutView.frame.size.width, height: 0)
                }, completion: nil)
        }

    }
    
    @IBAction func resetButtonClicked(sender: UIButton) {
        if resetEmailTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
            showDismissiveAlertMesssage("Enter your email address")
        } else {
            if Globals.isValidEmail(resetEmailTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) {
                UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.calloutView.frame = CGRect(x: 0.0, y: self.calloutViewYAxis, width: self.calloutView.frame.size.width, height: 0)
                }, completion: nil)
                sendResetPasswordRequest(resetEmailTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
            } else {
                showDismissiveAlertMesssage("Enter a valid email address")
            }
        }
    }
    
    func validateFields() -> Bool {
        if emailTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
            showDismissiveAlertMesssage("Enter your email address")
            return false
        } else {
            if !Globals.isValidEmail(emailTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) {
                showDismissiveAlertMesssage("Enter a valid email address")
                return false
            }
        }
        if passwordTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
            showDismissiveAlertMesssage("Enter your password")
            return false
        }
        return true
    }
    
    func sendLoginRequest() {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(emailTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), forKey: "email")
        requestDictionary.setObject(passwordTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), forKey: "password")
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "user/login", requestType: HttpMethod.post), delegate: self, tag: Connection.login)
    }
    
    func sendResetPasswordRequest(email: String) {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(email, forKey: "email")
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "user/forgotPassword", requestType: HttpMethod.post), delegate: self, tag: Connection.resetPassword)
    }
    
    func connection(connection: CustomURLConnection, didReceiveResponse: NSURLResponse) {
        connection.receiveData.length = 0
    }
    
    func connection(connection: CustomURLConnection, didReceiveData data: NSData) {
        connection.receiveData.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: CustomURLConnection) {
        let response = NSString(data: connection.receiveData, encoding: NSUTF8StringEncoding)
        print(response)
        var error: NSError?
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(connection.receiveData, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
            if let status = jsonResult["status"] as? Int {
                if status == ResponseStatus.success {
                    if connection.connectionTag == Connection.resetPassword {
                        resetEmailTextField.text = ""
                        if let message = jsonResult["message"] as? String {
                            showDismissiveAlertMesssage(message)
                        } else {
                            showDismissiveAlertMesssage("We've sent you an email to reset your password")
                        }
                    } else {
                        if let token = jsonResult["token"] as? String {
                            NSUserDefaults.standardUserDefaults().setObject(token, forKey: "API_TOKEN")
                            performSegueWithIdentifier("modalSeguetoTab", sender: self)
                        }
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

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        selectedTextField = textField
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        rememberMeButton.selected = false
//        return true;
//    }

    
}
