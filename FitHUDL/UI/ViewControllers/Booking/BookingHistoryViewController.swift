//
//  BookingHistoryViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 23/11/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class BookingHistoryViewController: UIViewController {

    @IBOutlet weak var bookingSegmentControl: UISegmentedControl!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var noAvailLabel: UILabel!
    var myBookings = NSMutableArray()
    var bookings   = NSMutableArray()
    var cancelDictionary: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setStatusBarColor()
        let font        = UIFont(name: "OpenSans", size: 14.0)
        var attributes  = [NSForegroundColorAttributeName: AppColor.statusBarColor, NSFontAttributeName: font!]
        bookingSegmentControl.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        attributes      = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font!]
        bookingSegmentControl.setTitleTextAttributes(attributes, forState: UIControlState.Selected)
        
        let nib = UINib(nibName: "HistoryTableViewCell", bundle: nil)
        historyTableView.registerNib(nib, forCellReuseIdentifier: "historyCell")
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        sendRequestToGetSessions()
    }
    
    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        if bookingSegmentControl.selectedSegmentIndex == 0 {
            noAvailLabel.hidden = myBookings.count > 0 ? true : false
        } else {
            noAvailLabel.hidden = bookings.count > 0 ? true : false
        }
        historyTableView.reloadData()
    }
    
    func cancelBooking(sender: UIButton) {
        let alert       = UIAlertController(title: "Cancel Session", message: "Do you wish to cancel the booked session?", preferredStyle: UIAlertControllerStyle.Alert)
        let noAction    = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) { (noAction) -> Void in
            return
        }
        let yesAction   = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (yesAction) -> Void in
            let cell        = sender.superview?.superview as! HistoryTableViewCell
            let indexPath   = self.historyTableView.indexPathForCell(cell)
            let request     = self.bookingSegmentControl.selectedSegmentIndex == 0 ? (self.myBookings[indexPath!.row] as! NSDictionary) : (self.bookings[indexPath!.row] as! NSDictionary)
            self.sendRequestToCancelSession(request["request_id"] as! Int)
        }
        alert.addAction(noAction)
        alert.addAction(yesAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func userImageTapped(tapGesture: UITapGestureRecognizer) {
        let imageView = tapGesture.view as! UIImageView
        let cell      = imageView.superview?.superview as! HistoryTableViewCell
        let indexPath = historyTableView.indexPathForCell(cell)
        let profile   = bookingSegmentControl.selectedSegmentIndex == 0 ? myBookings[indexPath!.row] as! NSDictionary : bookings[indexPath!.row] as! NSDictionary
        let userProfile         = storyboard?.instantiateViewControllerWithIdentifier("MyProfileViewController") as! MyProfileViewController
        let id                  = bookingSegmentControl.selectedSegmentIndex == 0 ? profile["trainer_id"] as! Int : profile["user_id"] as! Int
        userProfile.profileID   = "\(id)"
        navigationController?.pushViewController(userProfile, animated: true)        
    }
    
    
    func sendRequestToCancelSession(requestID: Int) {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(requestID, forKey: "request_id")
        cancelDictionary = requestDictionary
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "sessions/sessionCancel", requestType: HttpMethod.post), delegate: self, tag: Connection.sessionCancel)
    }

    func sendRequestToGetSessions() {
        if !Globals.checkNetworkConnectivity() {
            if let bookingArray = Bookings.fetchBookings() {
                parseBookingHistory(bookingArray)
            }
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "sessions/getUserSessions", requestType: HttpMethod.post), delegate: self, tag: Connection.sessionsList)
    }
    
    func parseBookingHistory(dataArray: NSArray) {
        let formatter        = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let checkDate        = formatter.stringFromDate(NSDate())
        formatter.dateFormat = "HH:mm"
        let checkTime        = formatter.stringFromDate(NSDate())
        var filteredArray    = dataArray.filteredArrayUsingPredicate(NSPredicate(format: "user_id = %@", argumentArray: [appDelegate.user!.profileID]))
        myBookings.addObjectsFromArray(filteredArray as [AnyObject])
        filteredArray        = dataArray.filteredArrayUsingPredicate(NSPredicate(format: "trainer_id = %@", argumentArray: [appDelegate.user!.profileID]))
        bookings.addObjectsFromArray(filteredArray as [AnyObject])
        noAvailLabel.hidden = myBookings.count > 0 ? true : false
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
                    if connection.connectionTag == Connection.sessionCancel {
                        let source = bookingSegmentControl.selectedSegmentIndex == 0 ? myBookings : bookings
                        let predicate = NSPredicate(format: "request_id = %d", argumentArray: [cancelDictionary!["request_id"] as! Int])
                        let filteredArray = source.filteredArrayUsingPredicate(predicate)
                        if filteredArray.count>0 {
                            source.removeObjectAtIndex(source.indexOfObject(filteredArray[0]))
                        }
                    } else {
                        myBookings.removeAllObjects()
                        bookings.removeAllObjects()
                        let bookingsArray = NSMutableArray()
                        if let data = jsonResult["data"] as? NSArray {
                            for book in data {
                                let booking = Bookings.saveBooking(book["user_name"] as! String, userID: book["user_id"] as! Int, requestID: book["request_id"] as! Int, trainerID: book["trainer_id"] as! Int, spID: book["sports_id"] as! Int, spName: book["sports_name"] as! String, status: book["status"] as! String, loc: book["location"] as! String, bookID: book["booking_id"] as! Int, startTime: book["start_time"] as! String, endTime: book["end_time"] as! String, allotedDate: book["alloted_date"] as! String, userImage: book["user_profile_pic"] as! String, trainerName: book["trainer_name"] as! String, trainerImage: book["trainer_profile_pic"] as! String)
                                bookingsArray.addObject(booking)
                            }
                        }
                        parseBookingHistory(bookingsArray)
                    }
                    historyTableView.reloadData()
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
    
    func dateConversion(date: String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dates = formatter.dateFromString(date)
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.stringFromDate(dates!)
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

extension BookingHistoryViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookingSegmentControl.selectedSegmentIndex == 0 ? myBookings.count : bookings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell    = tableView.dequeueReusableCellWithIdentifier("historyCell") as! HistoryTableViewCell
        let source  = bookingSegmentControl.selectedSegmentIndex == 0 ? myBookings : bookings
        let history = source[indexPath.row] as! Bookings
        let imageURL = bookingSegmentControl.selectedSegmentIndex == 0 ? history.trainerImage : history.userImage
        cell.userImageView.image        = UIImage(named: "default_image")
        cell.userImageView.contentMode  = UIViewContentMode.ScaleAspectFit
        cell.indicatorView.startAnimating()
        let imageurl = SERVER_URL.stringByAppendingString(imageURL) as NSString
        if imageurl.length != 0 {
            if var imagesArray = Images.fetch(imageurl as String) {
                let image      = imagesArray[0] as! Images
                let coverImage = UIImage(data: image.imageData)!
                cell.userImageView.contentMode = UIViewContentMode.ScaleAspectFill
                cell.userImageView.image   =   UIImage(data: image.imageData)!
                cell.indicatorView.stopAnimating()
            } else {
                if let imageURL = NSURL(string: imageurl as String){
                    let request  = NSURLRequest(URL: imageURL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: TimeOut.Image)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                        if let updatedCell = tableView.cellForRowAtIndexPath(indexPath) as? HistoryTableViewCell {
                            if error == nil {
                                let imageFromData:UIImage? = UIImage(data: data)
                                if let image  = imageFromData {
                                    updatedCell.userImageView.contentMode = UIViewContentMode.ScaleAspectFill
                                    updatedCell.userImageView.image = image
                                    Images.save(imageurl as String, imageData: data)
                                }
                            }
                            updatedCell.indicatorView.stopAnimating()
                        }
                    }
                } else {
                    cell.indicatorView.stopAnimating()
                }
            }
        } else {
            cell.indicatorView.stopAnimating()
        }
        cell.sportLabel.text = history.sportsName+" session"
        cell.nameLabel.text  = bookingSegmentControl.selectedSegmentIndex == 0 ? history.trainerName : history.userName
        cell.placeLabel.text = history.location
        let date             = dateConversion(history.allotedDate)
        let startTime        = Globals.convertTimeTo12Hours(history.startTime)
        let endTime          = Globals.convertTimeTo12Hours(history.endTime)
        cell.timeLabel.text  = "On \(date) at \(startTime) to \(endTime)"
        cell.closeButton.addTarget(self, action: "cancelBooking:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userImageTapped:"))
        return cell
    }
}

extension BookingHistoryViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}