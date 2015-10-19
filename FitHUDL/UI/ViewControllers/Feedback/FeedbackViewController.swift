//
//  FeedbackViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 28/09/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {
    
    @IBOutlet weak var contentviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rateCollectionView: UICollectionView!
    @IBOutlet weak var suggestions_textfield: UITextView!
    @IBOutlet weak var submit_button: UIButton!
    var rating_category_array = Array<NSDictionary>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var nib = UINib(nibName: "RateFeedbackCell", bundle: nil)
        rateCollectionView.registerNib(nib, forCellWithReuseIdentifier: "FeedbacKCell")
        navigationController?.setStatusBarColor()
        submit_button.layer.cornerRadius=10.0
        submit_button.layer.borderWidth=1.0
        submit_button.layer.borderColor=AppColor.statusBarColor.CGColor
        
        if IS_IPHONE6 || IS_IPHONE6PLUS {
            contentviewHeightConstraint.constant = 560
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Submit_Feedback(sender: AnyObject) {
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        sendRequestToGetRateCategory()
    }
    
    
    //MARK: - RatingCategory API
    
    func sendRequestToGetRateCategory() {
        let requestDictionary = NSMutableDictionary()
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "feedback/feedbackRatingCatg", requestType: HttpMethod.post),delegate: self,tag: Connection.ratecategory)
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
                if connection.connectionTag == Connection.ratecategory {
                    if status == ResponseStatus.success {
                        if let favourites = jsonResult["data"] as? NSArray {
                            rating_category_array = favourites as! Array
                            println(rating_category_array)
                            rateCollectionView.reloadData()
                        }
                        else {
                        }
                        
                    }
                    else
                        if status == ResponseStatus.error {
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
                    
                    if status == ResponseStatus.success {
                        
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

extension FeedbackViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FeedbacKCell", forIndexPath: indexPath) as! RateFeedbackCell
        if indexPath.row >= rating_category_array.count
        {
            cell.backgroundColor=UIColor.whiteColor()
            cell.alpha=0.5;
            cell.rateView.hidden=true
            cell.arrowShape.hidden=true
        }
        else {
            cell.RateCategory_name?.text=self.rating_category_array[indexPath.row].objectForKey("name") as? String
            cell.backgroundColor=UIColor.whiteColor()
            cell.rateView.layer.cornerRadius=10.0
            cell.rateView.hidden=false
            cell.arrowShape.hidden=false
            
        }
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width/3, height: 90);
        
    }
}
