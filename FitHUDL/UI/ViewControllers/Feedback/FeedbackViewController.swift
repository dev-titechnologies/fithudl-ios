//
//  FeedbackViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 28/09/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController,FeedbackRateDelegate,UITextViewDelegate {
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet var cellRateView: RateView?
    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var contentviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rateCollectionView: UICollectionView!
    @IBOutlet weak var suggestions_textfield: UITextView!
    @IBOutlet weak var submit_button: UIButton!
    var indexNumber : Int = 0
    var rating_category_array = Array<NSDictionary>()
    var postRatingArray = Array<NSDictionary>()
    var postRateDict = [String:AnyObject]()
    var postRateEditDict = [String:AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nib = UINib(nibName: "RateFeedbackCell", bundle: nil)
        rateCollectionView.registerNib(nib, forCellWithReuseIdentifier: "FeedbacKCell")
        navigationController?.setStatusBarColor()
        submit_button.layer.cornerRadius=10.0
        submit_button.layer.borderWidth=1.0
        submit_button.layer.borderColor=AppColor.statusBarColor.CGColor
        
        if IS_IPHONE6 || IS_IPHONE6PLUS {
            contentviewHeightConstraint.constant = 555
        }
        var touch = UITapGestureRecognizer(target:self, action:"scrollviewTouchAction")
        contentScrollView.addGestureRecognizer(touch)
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        sendRequestToGetRateCategory()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - keyboardWillHide
    
    func scrollviewTouchAction() {
        suggestions_textfield.resignFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                self.contentScrollView.contentOffset = CGPoint(x: self.contentScrollView.frame.origin.x, y: self.suggestionLabel.frame.origin.y-20.0)
            }
        }
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
        
        self.contentScrollView.contentOffset = CGPoint(x: self.contentScrollView.frame.origin.x, y: self.contentScrollView.frame.origin.y)
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
         var rating_categoryTemp_array = Array<NSDictionary>()
        let response = NSString(data: connection.receiveData, encoding: NSUTF8StringEncoding)
        var error : NSError?
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(connection.receiveData, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
            if let status = jsonResult["status"] as? Int {
                if connection.connectionTag == Connection.ratecategory {
                    if status == ResponseStatus.success {
                        if let favourites = jsonResult["data"] as? NSArray {
                            
                            rating_categoryTemp_array = favourites as! Array
                            rating_category_array = Array<NSDictionary>()
                            postRatingArray = Array<NSDictionary>()
                            for var i = 0; i < rating_categoryTemp_array.count; i++ {
                                
                                let Catagorystatus = rating_categoryTemp_array[i].objectForKey("status") as? Int
                                
                                if Catagorystatus == 1
                                {
                                    rating_category_array.append(rating_categoryTemp_array[i])
                                    postRateDict["id"]=rating_categoryTemp_array[i].objectForKey("id")
                                    postRateDict["rating_count"]=rating_categoryTemp_array[i].objectForKey("rating_count")
                                    postRatingArray.append(postRateDict)

                                }
                                
                            }
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
                        suggestions_textfield.resignFirstResponder()
                        suggestions_textfield.text=""
                        
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
    
    
    func rateData(data: Int) {
        
        postRateEditDict = [String:AnyObject]()
        postRateEditDict=self.postRatingArray[indexNumber] as! [String : AnyObject]
        postRateEditDict["rating_count"] = data
        postRatingArray.removeAtIndex(indexNumber)
        postRatingArray.insert(postRateEditDict, atIndex:indexNumber)
    }
    
    func FeedRate(sender:UIButton) {
        indexNumber=sender.tag
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        let cell = rateCollectionView.cellForItemAtIndexPath(indexPath) as! RateFeedbackCell!
        cell.rateView.feedRate(sender)
    }
    
    @IBAction func sendFeedback(sender: AnyObject) {
        
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(suggestions_textfield.text, forKey: "feedback")
        requestDictionary.setObject(postRatingArray, forKey: "rating")
        
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "feedback/add", requestType: HttpMethod.post),delegate: self,tag: Connection.submitfeedback)
        
    }
}

//MARK: - TextViewDelegate

func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    return true
}
func textViewDidBeginEditing(textView: UITextView){
    
}
func textViewShouldEndEditing(textView: UITextView) -> Bool {
    return true
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
        cell.rateView?.delegate=self
        if indexPath.row >= rating_category_array.count
        {
            cell.backgroundColor=UIColor.whiteColor()
            cell.alpha=0.5;
            cell.rateView.hidden=true
            cell.arrowShape.hidden=true
            cell.RateCategory_name.hidden=true
        }
        else
        {
            cell.RateCategory_name.hidden=false
            cell.RateCategory_name?.text=self.rating_category_array[indexPath.row].objectForKey("name") as? String
            cell.backgroundColor=UIColor.whiteColor()
            cell.alpha=1.0;
            cell.rateView.layer.cornerRadius=10.0
            cell.rateView.hidden=false
            cell.arrowShape.hidden=false
            if let session_count = self.rating_category_array[indexPath.row].objectForKey("rating_count") as? Int {
                cell.rateView.showRateView(session_count)
            }
            
            cell.rateView.starOne.tag=indexPath.row
            cell.rateView.starTwo.tag=indexPath.row
            cell.rateView.starThree.tag=indexPath.row
            cell.rateView.starFour.tag=indexPath.row
            cell.rateView.starFive.tag=indexPath.row
            cell.rateView.starOne.addTarget(self, action: "FeedRate:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.rateView.starTwo.addTarget(self, action: "FeedRate:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.rateView.starThree.addTarget(self, action: "FeedRate:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.rateView.starFour.addTarget(self, action: "FeedRate:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.rateView.starFive.addTarget(self, action: "FeedRate:", forControlEvents: UIControlEvents.TouchUpInside)
            
        }
        return cell
    }
        func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    
            return CGSize(width: collectionView.frame.width/3, height: 90);
    
        }
}

