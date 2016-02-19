//
//  PackageViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 11/11/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit
import StoreKit

class PackageViewController: UIViewController,IAPHelperClassDelegate {

    @IBOutlet weak var goldNameLabel: UILabel!
    @IBOutlet weak var goldDollarLabel: UILabel!
    @IBOutlet weak var goldDiscountLabel: UILabel!
    
    @IBOutlet weak var silverNameLabel: UILabel!
    @IBOutlet weak var silverDollarLabel: UILabel!
    @IBOutlet weak var silverDiscountLabel: UILabel!
    
    @IBOutlet weak var bronzeNameLabel: UILabel!
    @IBOutlet weak var bronzeDollarLabel: UILabel!
    @IBOutlet weak var bronzeDiscountLabel: UILabel!
    
    @IBOutlet weak var enterAmountBgView: UIView!
    var packageListArray = Array<Packages>()
    
    @IBOutlet weak var goldButton: UIButton!
    
    @IBOutlet weak var purchaseButton: UIButton!
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var silverButton: UIButton!
    
    @IBOutlet weak var bronzeButton: UIButton!
    
    var amount : NSInteger = 0
    
    var productIndex : NSInteger = 0;
    
    var packageClickFlag : Bool = false
    
    var activeField : UITextField!
    
    var products = [SKProduct]()
    
    var isKeyBoard : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        purchaseButton.layer.borderColor = AppColor.statusBarColor.CGColor
        purchaseButton.layer.borderWidth = 1.0
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "requestForSendingTransactionId:", name: "transactionCompleted", object: nil)
        enterAmountBgView.layer.borderColor = UIColor.lightGrayColor().CGColor
        enterAmountBgView.layer.borderWidth = 1.0
        enterAmountBgView.layer.cornerRadius = 2.0
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchased:", name: IAPHelperProductPurchasedNotification, object: nil)
        
        var touch = UITapGestureRecognizer(target:self, action:"scrollviewTouchAction")
        self.view.addGestureRecognizer(touch)
    }
    
    func scrollviewTouchAction() {
        
        if isKeyBoard {
          amountTextField.resignFirstResponder()
        }
        
    }

    
    
    //MARK: TextField operations
    
    
    func keyboardWasShown(notification: NSNotification)
    {
        isKeyBoard = true
        //Need to calculate keyboard exact size due to Apple suggestions
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.view.frame.origin.y -= keyboardSize!.height
        
    }
    
    func keyboardWillBeHidden(notification: NSNotification)
    {
        isKeyBoard = false
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.view.frame.origin.y += keyboardSize!.height
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField!)
    {
        if self.packageClickFlag {
            self.packageClickFlag = false
            goldButton.selected    = false
            bronzeButton.selected  = false
            silverButton.selected  = false
        }
        activeField = textField
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
       
        if self.packageClickFlag {
            self.packageClickFlag = false
            goldButton.selected    = false
            bronzeButton.selected  = false
            silverButton.selected  = false
        }
        if textField == amountTextField {
            let validCharSet    = NSCharacterSet(charactersInString: "1234567890")
            let nameText        = NSCharacterSet(charactersInString: textField.text.stringByAppendingString(string))
            let stringIsValid   = validCharSet.isSupersetOfSet(nameText)
            return stringIsValid
        }
        return true;

    }
    func textFieldDidEndEditing(textField: UITextField!)
    {
        activeField = nil
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    //MARK: InAppPurchase Product Request
  
    @IBAction func helpButtonAction(sender: AnyObject) {
        
    }
    
    func reload() {
        
        println("In Reload")
        products = []
        RageProducts.store.requestProductsWithCompletionHandler { success, products in
            if success {
                self.products = products
                println("In app products \(self.products)")
            }
            else {
                
                println("IAP FAILUre")
            }
        }
    }

    func finishedLoading() {
         showLoadingView(false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishedLoading", name: "LoadingCompleted", object: nil)
       self.reload()
       
        sendRequestToGetPackageList()
        
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "LoadingCompleted", object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
        
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
         dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func purchseButtonClicked(sender: AnyObject) {
        if self.packageClickFlag {
            
            showLoadingView(true)
            println("Products \(products)")
            let product = products[self.productIndex]
            RageProducts.store.purchaseProduct(product)
            
        } else if !amountTextField.text.isEmpty {
            
            
            var num = amountTextField.text.toInt()
            if num != nil {
                
                println("Valid String")
                
                if amountTextField.text.toInt() <= 10 {
                    amountTextField.text = ""
                    UIAlertView(title: alertTitle, message: "Amount Should be Greater than 10", delegate: self, cancelButtonTitle: "OK").show()
                    return
                } else {
                   
                    if isKeyBoard {
                        amountTextField.resignFirstResponder()
                    }
                    amount = num!
                    self.performSegueWithIdentifier("cardDetails", sender: self)

                   
                }
                
            } else{
                amountTextField.text = ""
                UIAlertView(title: alertTitle, message: "Enter A Valid Amount", delegate: self, cancelButtonTitle: "OK").show()
                return
            }
            
            
            
        }else {
            
            UIAlertView(title: "Either Select A package OR Enter A Recharge Amount", message: "", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "cardDetails" {
            let cardDetailController = segue.destinationViewController as! CardDetailsViewController
            cardDetailController.rechargeAmount = amount
        }
    }
    
    @IBAction func goldPackageSelectButtonClicked(sender: UIButton) {
        
        sender.selected       = true
        silverButton.selected = false
        bronzeButton.selected = false
        self.productIndex     = 0
        self.packageClickFlag = true
        amountTextField.text = ""
    }
    
    @IBAction func silverPackageSelectButtonClicked(sender: UIButton) {
        
        sender.selected         = true
        goldButton.selected     = false
        bronzeButton.selected   = false
        self.productIndex       = 1
        self.packageClickFlag   = true
        amountTextField.text = ""
    }
    
    
    @IBAction func bronzeSelectButtonClicked(sender: UIButton) {
        sender.selected         = true
        goldButton.selected     = false
        silverButton.selected   = false
        self.productIndex       = 2
        self.packageClickFlag   = true
        amountTextField.text = ""
    }
    
    //MARK: PackageList API 
    
    func parsePackageList() {
        var pack                = packageListArray[0] as Packages
        goldNameLabel.text      = pack.name
        goldDollarLabel.text    = "\(pack.displayPrice)" + "$"
        goldDiscountLabel.text  = "get a " + pack.discount + " discount"
        
        pack                     = packageListArray[1] as Packages
        silverNameLabel.text     = pack.name
        silverDollarLabel.text   = "\(pack.displayPrice)" + "$"
        silverDiscountLabel.text = "get a " + pack.discount + " discount"

        pack                     = packageListArray[2] as Packages
        bronzeNameLabel.text     = pack.name
        bronzeDollarLabel.text   = "\(pack.displayPrice)" + "$"
        bronzeDiscountLabel.text = "get a " + pack.discount + " discount"
    }
    
    func requestForSendingTransactionId(string: NSString) {
        
        println("GOT TRANSACTion ID : \(string)")
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        if let transaction_id = NSUserDefaults.standardUserDefaults().stringForKey("transaction_id") {
            println(transaction_id)
            requestDictionary.setObject(transaction_id, forKey: "transaction_id")
        }
       
        let pack1   = packageListArray[0] as Packages
        let pack2   = packageListArray[1] as Packages
        let pack3   = packageListArray[2] as Packages
        
        if goldButton.selected {
            println("gold button clicked")
            requestDictionary.setObject(pack1.displayPrice, forKey: "amount")
            requestDictionary.setObject(pack1.discount, forKey: "discount")
            requestDictionary.setObject(pack1.id, forKey: "package_id")
            requestDictionary.setObject(pack1.name, forKey: "package_name")
        } else if silverButton.selected {
            println("silver button clicked")
            requestDictionary.setObject(pack2.displayPrice, forKey: "amount")
            requestDictionary.setObject(pack2.discount, forKey: "discount")
            requestDictionary.setObject(pack2.id, forKey: "package_id")
            requestDictionary.setObject(pack2.name, forKey: "package_name")
        } else if bronzeButton.selected {
            println("bronze button clicked")
            
            requestDictionary.setObject(pack3.displayPrice, forKey: "amount")
            requestDictionary.setObject(pack3.discount, forKey: "discount")
            requestDictionary.setObject(pack3.id, forKey: "package_id")
            requestDictionary.setObject(pack3.name, forKey: "package_name")
        }
        requestDictionary.setObject("InAppPurchase", forKey: "transaction_method")

        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "sessions/transaction", requestType: HttpMethod.post),delegate: self,tag: Connection.transactionRequest)

    }
    
    func sendRequestToGetPackageList() {
        let requestDictionary = NSMutableDictionary()
        if !Globals.checkNetworkConnectivity() {
            if let packageList = Packages.fetchPackages() {
                packageListArray = packageList as! Array<Packages>
                parsePackageList()
            } else {
                showDismissiveAlertMesssage(Message.Offline)
            }
            return
        }
        showLoadingView(true)
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "packages/list", requestType: HttpMethod.post),delegate: self,tag: Connection.packagesListRequest)
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
                if connection.connectionTag == Connection.packagesListRequest {
                    if status == ResponseStatus.success {
                        if let packages = jsonResult["data"] as? NSArray {
                            Packages.deletePackages()
                            packageListArray.removeAll(keepCapacity: true)
                            for package in packages {
                                let pack = Packages.savePackage(Globals.checkIntNull(package["id"] as? Int), displayPrice: Globals.checkStringNull(package["display_price"] as? String), format: Globals.checkStringNull(package["currency_format"] as? String), cost: Globals.checkIntNull(package["cost"] as? Int), discount: Globals.checkStringNull(package["discount"] as? String), name: Globals.checkStringNull(package["name"] as? String))
                                packageListArray.append(pack)
                            }
                            appDelegate.saveContext()
                            parsePackageList()
                        } else {
                            
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
                } else if connection.connectionTag == Connection.transactionRequest {
                    if status == ResponseStatus.success {
                       UIAlertView(title: alertTitle, message: "Package purchase successful", delegate: nil, cancelButtonTitle: "OK").show()
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
