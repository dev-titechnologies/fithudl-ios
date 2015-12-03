//
//  ChangePasswordViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 02/12/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changePasswordButton.layer.borderWidth = 1.0
        changePasswordButton.layer.borderColor = AppColor.statusBarColor.CGColor
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func changePasswordClicked(sender: UIButton) {
        if validateFields() {
            sendRequestToChangePassword()
        }
    }
    
    func validateFields() -> Bool {
        if passwordTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
            showDismissiveAlertMesssage("Please enter your current password")
            return false
        }
        if newPasswordTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
            showDismissiveAlertMesssage("Please enter new password")
            return false
        }
        if confirmTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
            showDismissiveAlertMesssage("Please confirm your new password")
            return false
        } else if newPasswordTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != confirmTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) {
            showDismissiveAlertMesssage("Passwords mismatch.")
            return false
        }
        return true
    }
    
    func sendRequestToChangePassword() {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(passwordTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), forKey: "current_password")
        requestDictionary.setObject(newPasswordTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), forKey: "new_password")
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "user/changePassword", requestType: HttpMethod.post), delegate: self, tag: Connection.userProfile)
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
        var error: NSError?
        
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(connection.receiveData, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
            if let status = jsonResult["status"] as? Int {
                if status == ResponseStatus.success {
                    UIAlertView(title: alertTitle, message: "Password updated successfully", delegate: nil, cancelButtonTitle: "Ok").show()
                    dismissViewControllerAnimated(true, completion: nil)
                    
                } else if status == ResponseStatus.error {
                    if let message = jsonResult["message"] as? String {
                        showDismissiveAlertMesssage(message)
                    } else {
                        showDismissiveAlertMesssage(ErrorMessage.invalid)
                    }
                } else {
                    dismissOnSessionExpire()
                }
            }
        }
        showLoadingView(false)
    }
    
    func connection(connection: CustomURLConnection, didFailWithError error: NSError) {
        showDismissiveAlertMesssage(error.localizedDescription)
        showLoadingView(false)
    }

    @IBAction func backButtonClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
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

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
