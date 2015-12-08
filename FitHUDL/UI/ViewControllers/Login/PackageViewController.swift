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
    
    var packageListArray = Array<NSDictionary>()
    
    @IBOutlet weak var goldButton: UIButton!
    
    @IBOutlet weak var purchaseButton: UIButton!
    
    @IBOutlet weak var silverButton: UIButton!
    
    @IBOutlet weak var bronzeButton: UIButton!
    
    var productIndex : NSInteger = 0;
    
    var packageClickFlag : Bool = false
    
    var products = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        purchaseButton.layer.borderColor = AppColor.statusBarColor.CGColor
        purchaseButton.layer.borderWidth = 1.0
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishedLoading", name: "LoadingCompleted", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "requestForSendingTransactionId:", name: "transactionCompleted", object: nil)
        self.reload()
        
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchased:", name: IAPHelperProductPurchasedNotification, object: nil)
    }
    
    //MARK: InAppPurchase Product Request
    
    func reload() {
        
        showLoadingView(true)
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
          self.sendRequestToGetPackageList()
        
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
            
        } else {
            
            UIAlertView(title: "Please Select A package", message: "", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
    }
    
    @IBAction func goldPackageSelectButtonClicked(sender: UIButton) {
        
        sender.selected=true
        silverButton.selected=false
        bronzeButton.selected=false
        self.productIndex = 0
        self.packageClickFlag = true
        
    }
    
    @IBAction func silverPackageSelectButtonClicked(sender: UIButton) {
       
        sender.selected = true
        goldButton.selected=false
        bronzeButton.selected=false
        self.productIndex = 1
        self.packageClickFlag = true
        
        
    }
    
    
    @IBAction func bronzeSelectButtonClicked(sender: UIButton) {
        
        sender.selected = true
        goldButton.selected=false
        silverButton.selected=false
        self.productIndex = 2
        self.packageClickFlag = true

    }
    
    //MARK: PackageList API 
    
    func parsePackageList() {
        
        goldNameLabel.text      = packageListArray[0].objectForKey("name") as? String
        var cost                = packageListArray[0].objectForKey("display_price") as? String
        goldDollarLabel.text    = "\(cost!)" + "$"
        goldDiscountLabel.text  = "get a " + (packageListArray[0].objectForKey("discount") as? String)! + " discount"
        
        silverNameLabel.text     = packageListArray[1].objectForKey("name") as? String
        cost                     = packageListArray[1].objectForKey("display_price") as? String
        silverDollarLabel.text   = "\(cost!)" + "$"
        silverDiscountLabel.text = "get a " + (packageListArray[1].objectForKey("discount") as? String)! + " discount"

        bronzeNameLabel.text     = packageListArray[2].objectForKey("name") as? String
        cost                     = packageListArray[2].objectForKey("display_price") as? String
        bronzeDollarLabel.text   = "\(cost!)" + "$"
        bronzeDiscountLabel.text = "get a " + (packageListArray[2].objectForKey("discount") as? String)! + " discount"

    }
    
    func requestForSendingTransactionId(string: NSString) {
        
        println("GOT TRANSACTion ID : \(string)")
        
        let requestDictionary = NSMutableDictionary()
        
        if let transaction_id = NSUserDefaults.standardUserDefaults().stringForKey("transaction_id") {
            
            println(transaction_id)
            
            requestDictionary.setObject(transaction_id, forKey: "transaction_id")
        }
       
        if goldButton.selected {
            
            println("gold button clicked")
           requestDictionary.setObject((packageListArray[0].objectForKey("display_price") as? String)!, forKey: "amount")
            requestDictionary.setObject((packageListArray[0].objectForKey("discount") as? String)!, forKey: "discount")
            requestDictionary.setObject((packageListArray[0].objectForKey("id") as? Int)!, forKey: "package_id")
            requestDictionary.setObject((packageListArray[0].objectForKey("name") as? String)!, forKey: "package_name")
         
        } else if silverButton.selected {
            println("silver button clicked")
          requestDictionary.setObject((packageListArray[1].objectForKey("display_price") as? String)!, forKey: "amount")
            requestDictionary.setObject((packageListArray[1].objectForKey("discount") as? String)!, forKey: "discount")
            requestDictionary.setObject((packageListArray[1].objectForKey("id") as? Int)!, forKey: "package_id")
            requestDictionary.setObject((packageListArray[1].objectForKey("name") as? String)!, forKey: "package_name")
            
        } else if bronzeButton.selected {
            
            println("bronze button clicked")
            requestDictionary.setObject((packageListArray[2].objectForKey("display_price") as? String)!, forKey: "amount")
            requestDictionary.setObject((packageListArray[2].objectForKey("discount") as? String)!, forKey: "discount")
            requestDictionary.setObject((packageListArray[2].objectForKey("id") as? Int)!, forKey: "package_id")
            requestDictionary.setObject((packageListArray[2].objectForKey("name") as? String)!, forKey: "package_name")
            
        }

        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "sessions/transaction", requestType: HttpMethod.post),delegate: self,tag: Connection.transactionRequest)

    }
    
    func sendRequestToGetPackageList() {
        let requestDictionary = NSMutableDictionary()
        if !Globals.isInternetConnected() {
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
                            packageListArray = packages as! Array
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
                        
                       UIAlertView(title: "FITHUDL", message: "Package purchase successful", delegate: self, cancelButtonTitle: "OK").show()
                        
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
                }            }
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
