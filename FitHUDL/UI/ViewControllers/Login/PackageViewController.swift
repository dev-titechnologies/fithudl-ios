//
//  PackageViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 11/11/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class PackageViewController: UIViewController {

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
    @IBOutlet weak var purchaseButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        purchaseButton.layer.borderColor = AppColor.statusBarColor.CGColor
        purchaseButton.layer.borderWidth = 1.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
          self.sendRequestToGetPackageList()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
        
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
         dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func purchseButtonClicked(sender: AnyObject) {
        
    }
    
    //MARK: PackageList API 
    
    func parsePackageListAPI() {
        
        goldNameLabel.text = packageListArray[0].objectForKey("name") as? String
        goldDollarLabel.text = (packageListArray[0].objectForKey("cost") as? String)! + "$"
        goldDiscountLabel.text = "get a " + (packageListArray[0].objectForKey("discount") as? String)! + " discount"
        
        silverNameLabel.text = packageListArray[1].objectForKey("name") as? String
        silverDollarLabel.text = (packageListArray[1].objectForKey("cost") as? String)! + "$"
        silverDiscountLabel.text = "get a " + (packageListArray[1].objectForKey("discount") as? String)! + " discount"

        bronzeNameLabel.text = packageListArray[2].objectForKey("name") as? String
        bronzeDollarLabel.text = (packageListArray[2].objectForKey("cost") as? String)! + "$"
        bronzeDiscountLabel.text = "get a " + (packageListArray[2].objectForKey("discount") as? String)! + " discount"

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
        return connection.receiveData.length=0
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
                            self.parsePackageListAPI()
                        }
                        else {
                            
                        }
                    }
                    else if status == ResponseStatus.error {
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
                else {
                    

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
