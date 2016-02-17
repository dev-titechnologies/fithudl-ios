//
//  PromoCodeViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 21/01/16.
//  Copyright (c) 2016 Ti Technologies. All rights reserved.
//

import UIKit
import MessageUI

protocol PromoSignupDelegate {
    func signupWithPromo(promoCode: String?)
}


class PromoCodeViewController: UIViewController {

    @IBOutlet weak var promoCodeLabel: UILabel!
    @IBOutlet weak var entryView: UIView!
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var codeEntryView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var promoNoButton: UIButton!
    @IBOutlet weak var promoYesButton: UIButton!
    @IBOutlet weak var promoTextField: UITextField!
    @IBOutlet weak var okButton: UIButton!
    
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var contentChangeView: UIView!
    var signupDelegate:PromoSignupDelegate?
    var viewTag: Int = 0
    var shareSubject = ""
    var shareContent = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewTag == ViewTag.promoDisplayView {
            displayView.hidden = false
            sendRequestToGetPromoCode()
            setButtonBorder(shareButton)
        } else if viewTag == ViewTag.promoEntryView {
            entryView.hidden   = false
            confirmView.hidden = false
            codeEntryView.hidden = true
            setButtonBorder(promoNoButton)
            setButtonBorder(promoYesButton)
            setButtonBorder(proceedButton)
            setButtonBorder(cancelButton)
            promoTextField.superview?.layer.borderWidth = 1
            promoTextField.superview?.layer.borderColor = AppColor.promoGreenColor.CGColor
        } else if viewTag == ViewTag.contentChange {
            contentChangeView.hidden = false
            agreeButton.selected = true
            setButtonBorder(okButton)
        }
        // Do any additional setup after loading the view.
    }
    
    func setButtonBorder(button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.borderColor = AppColor.promoGreenColor.CGColor
    }
    
    func setAttributedPromoCode(code: String) {
        var promoTitle = NSMutableAttributedString(string: "Promotion Code:", attributes: [NSFontAttributeName: UIFont(name: "OpenSans", size: 17.0)!, NSForegroundColorAttributeName: AppColor.promoGrayColor])
        promoTitle.appendAttributedString(NSAttributedString(string: " \(code)", attributes: [NSFontAttributeName: UIFont(name: "OpenSans", size: 17.0)!, NSForegroundColorAttributeName: AppColor.promoGreenColor]))
        promoCodeLabel.attributedText = promoTitle
    }

    @IBAction func yesButtonClicked(sender: UIButton) {
        confirmView.hidden   = true
        codeEntryView.hidden = false
    }
    
    @IBAction func closeButtonClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareButtonClicked(sender: UIButton) {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setSubject(shareSubject)
        mailComposer.setMessageBody(shareContent, isHTML: true)
        presentViewController(mailComposer, animated: true, completion: nil)
    }
    
    @IBAction func noButtonClicked(sender: UIButton) {
        signupDelegate?.signupWithPromo(nil)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func proceedButtonClicked(sender: UIButton) {
        if promoTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" {
            signupDelegate?.signupWithPromo(promoTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            UIAlertView(title: alertTitle, message: "Please enter promo code", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    @IBAction func cancelButtonClicked(sender: UIButton) {
        confirmView.hidden   = false
        codeEntryView.hidden = true
    }
    
    @IBAction func mobilePrivacyClicked(sender: UIButton) {
        let navController = storyboard?.instantiateViewControllerWithIdentifier("WebNavigationController") as! UINavigationController
        let webController = navController.topViewController as! WebViewController
        webController.viewTag = ViewTag.mobilePrivacy
        presentViewController(navController, animated: true, completion: nil)
    }
    
    @IBAction func agreeButtonClicked(sender: UIButton) {
        agreeButton.selected = !agreeButton.selected
    }
    
    @IBAction func agreementClicked(sender: UIButton) {
        let navController = storyboard?.instantiateViewControllerWithIdentifier("WebNavigationController") as! UINavigationController
        let webController = navController.topViewController as! WebViewController
        webController.viewTag = ViewTag.agreement
        presentViewController(navController, animated: true, completion: nil)
    }
    
    @IBAction func okButtonClicked(sender: UIButton) {
        sendContractAgreementRequest()
    }
    
    func sendRequestToGetPromoCode() {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        CustomURLConnection(request: CustomURLConnection.createRequest(NSMutableDictionary(), methodName: "user/getPromoCode", requestType: HttpMethod.post), delegate: self, tag: Connection.promoCodeRequest)
    }
    
    func sendContractAgreementRequest() {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(agreeButton.selected == true ? 1 : 0, forKey: "checked")
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "user/checkContentChange", requestType: HttpMethod.post), delegate: self, tag: Connection.contentChangeRequest)
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
            println("HTML \(jsonResult)")
            if let status = jsonResult["status"] as? Int {
                if status == ResponseStatus.success {
                    if connection.connectionTag == Connection.promoCodeRequest {
                        if let data = jsonResult["data"] as? NSDictionary {
                            let code = data["code"] as! String
                            setAttributedPromoCode(code)
                            shareSubject = data["SUBJECT"] as! String
                            shareContent = data["CONTENT"] as! String
                            
                            shareContent = shareContent.stringByReplacingOccurrencesOfString("Display Name", withString: appDelegate.user!.name)
                             shareContent = shareContent.stringByReplacingOccurrencesOfString("invite code", withString: code)
                            
                            
                        }
                    } else {
                        appDelegate.user?.termsStatus = agreeButton.selected == true ? 1 : 0
                        dismissViewControllerAnimated(true, completion: nil)
                    }
                } else if status == ResponseStatus.error {
                    if let message = jsonResult["message"] as? String {
                        showDismissiveAlertMesssage(message)
                    } else {
                        showDismissiveAlertMesssage(ErrorMessage.invalid)
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

extension PromoCodeViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        if error != nil {
        
        } else {
            controller.dismissViewControllerAnimated(true, completion: nil)
            if result.value == MFMailComposeResultSent.value {
                UIAlertView(title: alertTitle, message: "Invite code shared successfully", delegate: nil, cancelButtonTitle: "OK").show()
                self.dismissViewControllerAnimated(true, completion: nil)
            } else if result.value == MFMailComposeResultFailed.value {
                UIAlertView(title: alertTitle, message: "Failed to send the message", delegate: nil, cancelButtonTitle: "OK").show()
            }
        }
    }
}

