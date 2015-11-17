//
//  BookingRequestViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 11/11/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class BookingRequestViewController: UIViewController {
    @IBOutlet weak var requestAlertViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    var bookingRequestStatus : NSInteger=0
    
    var notificationDictionary = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        acceptButton.layer.borderColor = AppColor.statusBarColor.CGColor
        acceptButton.layer.borderWidth = 1.0
        
        rejectButton.layer.borderColor = AppColor.statusBarColor.CGColor
        rejectButton.layer.borderWidth = 1.0
        
        cancelButton.layer.borderColor = AppColor.statusBarColor.CGColor
        cancelButton.layer.borderWidth = 1.0
        
        var heading : String    = (notificationDictionary.objectForKey("sports_name") as? String)!
        headingLabel.text       = "Request for " + heading
        var date : String       = (notificationDictionary.objectForKey("alloted_date") as? String)!
        var startTime : String  = Globals.convertTimeTo12Hours((notificationDictionary.objectForKey("start_time") as? String)!)
        var endTime : String    = Globals.convertTimeTo12Hours((notificationDictionary.objectForKey("end_time") as? String)!)
        timeLabel.text          = date + " at " + startTime + " to " + endTime
        locationLabel.text      = notificationDictionary.objectForKey("location") as? String
        nameLabel.text          = notificationDictionary.objectForKey("user_name") as? String

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func acceptButtonClicked(sender: AnyObject) {
        bookingRequestStatus = 1
        sendRequestToUpdateBooking()
    }

    @IBAction func rejectButtonClicked(sender: AnyObject) {
        bookingRequestStatus = 2
        sendRequestToUpdateBooking()
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //MARK: Booking Request API Call
    
    func sendRequestToUpdateBooking() {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(bookingRequestStatus, forKey: "session_status")
        requestDictionary.setObject(notificationDictionary.objectForKey("request_id") as! Int, forKey: "booking_id")

        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "sessions/updateBookingStatus", requestType: HttpMethod.post),delegate: self,tag: Connection.bookingAcceptRequest)
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
                if connection.connectionTag == Connection.bookingAcceptRequest {
                    if status == ResponseStatus.success {
                        self.dismissViewControllerAnimated(true, completion: nil)
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
                } else {
                    
                }
            }
        }
        showLoadingView(false)
    }
    
    func connection(connection: CustomURLConnection, didFailWithError error: NSError) {
        showDismissiveAlertMesssage(error.localizedDescription)
        showLoadingView(false)
    }
}
