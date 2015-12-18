//
//  BookingSessionViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 26/10/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class BookingSessionViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var bookingTableView: UITableView!
    @IBOutlet weak var monthPicker: SRMonthPicker!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    var user: User!
    @IBOutlet weak var datePicker: DIDatepicker!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var sportsCarousel: iCarousel!
    @IBOutlet weak var expertLevelLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var noAvailLabel: UILabel!
    var selectedIndexArray = NSMutableArray()
    var searchResultId : String?
    var profileID: String?
    let availSessionTime = NSMutableDictionary()
    var activeText: UITextField!
    var bookingDictionary: NSMutableDictionary?
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendRequestToGetBookingSessions()
        sportsCarousel.type = .Custom
        let nib  = UINib(nibName: "BookingTableViewCell", bundle: nil)
        bookingTableView.registerNib(nib, forCellReuseIdentifier: "bookCell")
        
        monthPicker.superview!.setTranslatesAutoresizingMaskIntoConstraints(true)
        monthPicker.superview!.frame = CGRect(x: 0.0, y: view.frame.size.height, width: view.frame.size.width, height: monthPicker.frame.size.height)
        
        datePicker.addTarget(self, action: "dateValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        datePicker.fillDatesFromDate(NSDate(), toDate: Globals.endOfMonth())
        datePicker.selectedDateBottomLineColor = UIColor(red: 0, green: 150/255, blue: 136/255, alpha: 1.0)
        
        let dateFormatter        = NSDateFormatter()
        dateFormatter.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MMM yyyy"
        monthButton.setTitle(dateFormatter.stringFromDate(NSDate()).uppercaseString, forState: .Normal)
        dateFormatter.dateFormat = "YYYY"
        monthPicker.minimumYear  = dateFormatter.stringFromDate(NSDate()).toInt()!
        monthPicker.maximumYear  = monthPicker.minimumYear+25
        monthPicker.font         = UIFont(name: "Open-Sans", size: 17.0)
        monthPicker.fontColor    = UIColor(red: 0, green: 120/255, blue: 109/255, alpha: 1.0)
        monthPicker.monthPickerDelegate = self
        
        nameLabel.text = user.name
        if let id = searchResultId {
            tableViewTopConstraint.constant = -65
            view.layoutIfNeeded()
        }
        if count(user.bio) > BIOTEXT_LENGTH {
            bioLabel.userInteractionEnabled = true
            Globals.attributedBioText((user.bio as NSString).substringToIndex(BIOTEXT_LENGTH-1), lengthExceed: true, bioLabel: bioLabel, titleColor: AppColor.yellowTextColor, bioColor: UIColor.whiteColor())
        } else {
            bioLabel.userInteractionEnabled = false
            Globals.attributedBioText((user.bio as NSString).substringToIndex((user.bio as NSString).length), lengthExceed: false, bioLabel: bioLabel, titleColor: AppColor.yellowTextColor, bioColor: UIColor.whiteColor())
        }
       
        favoriteButton.selected = user.isFavorite.boolValue
        profileImageView.image = UIImage(named: "default_image")
        profileImageView.contentMode = UIViewContentMode.ScaleAspectFit
        CustomURLConnection.downloadAndSetImage(user.imageURL, imageView: profileImageView, activityIndicatorView: indicatorView)
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //MARK: KEYBOARD HANDLING
    
    func keyboardWillShow(note: NSNotification) {
        println(view.frame.height)
        println(bookingTableView.frame.height)
        if let keyboardSize = (note.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            var frame = bookingTableView.frame
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(animateInterval)
            frame.size.height -= keyboardSize.height
            bookingTableView.frame = frame
            if let textField = activeText {
                let rect = bookingTableView.convertRect(textField.bounds, fromView: textField)
                bookingTableView.scrollRectToVisible(rect, animated: false)
            }
            UIView.commitAnimations()
        }
    }
    
    func keyboardWillHide(note: NSNotification) {
        if let keyboardSize = (note.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            var frame = bookingTableView.frame
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(animateInterval)
            frame.size.height = frame.size.height+keyboardSize.height > view.frame.size.height ? view.frame.size.height : frame.size.height+keyboardSize.height
            bookingTableView.frame = frame
            bookingTableView.contentOffset = CGPoint(x: 0.0, y: 0.0)
            UIView.commitAnimations()
        }
    }

    func dateValueChanged(collectionView: UICollectionView) {
        noAvailLabel.hidden = true
        bookingTableView.reloadData()
    }
    
    func hidePickerView() {
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.monthPicker.superview!.frame = CGRect(origin: CGPoint(x: 0.0, y: self.view.frame.size.height), size: self.monthPicker.superview!.frame.size)
            return
        })
    }
    
    func clearSessionBooking() {
        if let date = datePicker.selectedDate {
            if let timeArray = availSessionTime.objectForKey(Globals.convertDate(datePicker.selectedDate)) as? NSArray {
                for time in timeArray {
                    time.setObject("", forKey: "location")
                }
                bookingTableView.reloadData()
            }
        }
        selectedIndexArray.removeAllObjects()
        sportsCarousel.reloadData()
    }
    
   //MARK: Unfavourite API
    
    func sendRequestToGetBookingSessions() {
        if !Globals.isInternetConnected() {
            return
        }
        
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(user.profileID, forKey: "user_id")
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "sessions/userBookingSessions", requestType: HttpMethod.post), delegate: self, tag: Connection.sessionsList)
    }
    
    func sendRequestToManageFavorite(favorite: Int) {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(favorite, forKey: "favorite")
        requestDictionary.setObject(user.profileID, forKey: "trainer_id")
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "favourite/manage", requestType: HttpMethod.post), delegate: self, tag: Connection.unfavourite)
    }
    
    @IBAction func pickerCancelClicked(sender: UIButton) {
        hidePickerView()
    }
    
    @IBAction func pickerDoneClicked(sender: UIButton) {
        let components   = NSDateComponents()
        components.month = monthPicker.selectedMonth
        components.year  = monthPicker.selectedYear
        let selectedDate = NSCalendar.currentCalendar().dateFromComponents(components)
        let formatter    = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "MMM yyyy"
        monthButton.setTitle(formatter.stringFromDate(selectedDate!).uppercaseString, forState: .Normal)
        hidePickerView()
        let currentDate      = formatter.stringFromDate(NSDate())
        if currentDate == formatter.stringFromDate(selectedDate!) {
            datePicker.fillDatesFromDate(NSDate(), toDate: Globals.endOfMonth())
            return
        }
        formatter.dateFormat = "MMM"
        let month            = formatter.stringFromDate(selectedDate!)
        formatter.dateFormat = "yyyy"
        let year             = formatter.stringFromDate(selectedDate!)
        datePicker.filDatesWithMonth(month, year: year)
    }
    
    @IBAction func favoriteButtonClicked(sender: UIButton) {
        sender.selected = !sender.selected
        sendRequestToManageFavorite(Int(sender.selected))
    }
    
    @IBAction func cancelViewTapped(sender: UITapGestureRecognizer) {
        clearSessionBooking()
    }
    
    @IBAction func monthButtonClicked(sender: UIButton) {
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.monthPicker.superview!.frame = CGRect(origin: CGPoint(x: 0.0, y: self.view.frame.size.height - self.monthPicker.superview!.frame.size.height), size: self.monthPicker.superview!.frame.size)
            return
        })
    }
    
    @IBAction func backButtonClicked(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
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
                if connection.connectionTag == Connection.unfavourite {
                    if status == ResponseStatus.success {
                        user.isFavorite = favoriteButton.selected
                        NSNotificationCenter.defaultCenter().postNotificationName(PushNotification.favNotif, object: nil, userInfo: ["user" : user])
                    } else if status == ResponseStatus.error {
                        if let message = jsonResult["message"] as? String {
                            showDismissiveAlertMesssage(message.capitalizedString)
                        } else {
                            showDismissiveAlertMesssage(Message.Error)
                        }
                        favoriteButton.selected = !favoriteButton.selected
                    } else {
                        dismissOnSessionExpire()
                    }
                }else  if connection.connectionTag == Connection.bookingRequest {
                    if status == ResponseStatus.success {
                        showDismissiveAlertMesssage("Session booked successfully")
                        clearSessionBooking()
                    } else if status == ResponseStatus.error {
                        if let message = jsonResult["message"] as? String {
                            showDismissiveAlertMesssage(message.capitalizedString)
                        } else {
                            showDismissiveAlertMesssage(Message.Error)
                        }
                    } else {
                        dismissOnSessionExpire()
                    }
                } else if connection.connectionTag == Connection.sessionsList {
                    if let data = jsonResult["data"] as? NSArray {
                        var datesArray  = NSSet(array:data.valueForKey("date") as! [String])
                        for date in datesArray {
                            var filteredArray = data.filteredArrayUsingPredicate(NSPredicate(format: "date = %@", argumentArray: [date])) as NSArray
                            availSessionTime.setObject(NSMutableArray(array:filteredArray), forKey: date as! String)
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

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bookingAction(sender:UIButton) {
        let requestDictionary = NSMutableDictionary()
        if  selectedIndexArray.count > 0 {
//            let filteredArray = (user.sports.allObjects as NSArray).filteredArrayUsingPredicate(NSPredicate(format: "sportsID = %d", argumentArray: [selectedIndexArray[0]]))
//            if filteredArray.count > 0 {
//                let level = (filteredArray[0] as! UserSports).expertLevel
//                if (level != SportsLevel.beginner) && (appDelegate.user!.walletBalance.toInt() < appDelegate.configDictionary[level] as? Int) {
//                    showDismissiveAlertMesssage("Insufficient balance to book this session")
//                    return
//                }
//            }
            requestDictionary.setObject(selectedIndexArray[0], forKey: "sports_id")
        } else {
            showDismissiveAlertMesssage("Please select a sport!")
            return
        }
        
        var timeArray       = availSessionTime.objectForKey(Globals.convertDate(datePicker.selectedDate)) as! NSArray
        if Globals.convertDate(NSDate()) == Globals.convertDate(datePicker.selectedDate) {
            let time  = Globals.convertTime(NSDate())
            timeArray = timeArray.filteredArrayUsingPredicate(NSPredicate(format: "time_starts > %@", argumentArray: [time]))
        }
        let time        = timeArray.objectAtIndex(sender.tag) as! NSDictionary
        let starttime   = Globals.convertTimeTo24Hours(time["time_starts"] as! String)
        let endtime     = Globals.convertTimeTo24Hours(time["time_ends"] as! String)
        let date        = time["date"] as! String
        
        requestDictionary.setObject(user.profileID, forKey: "trainer_id")
        requestDictionary.setObject(starttime, forKey: "start_time")
        requestDictionary.setObject(endtime, forKey: "end_time")
        requestDictionary.setObject(date, forKey: "session_date")
        if let place = time["location"] as? String {
            if place == "" {
                UIAlertView(title: "Please Enter your location", message: "", delegate: self, cancelButtonTitle: "OK").show()
                return
            } else {
                requestDictionary.setObject(place, forKey: "location")
            }
        } else {
            UIAlertView(title: "Please Enter your location", message: "", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        bookingDictionary = requestDictionary
        
        let popController               = storyboard?.instantiateViewControllerWithIdentifier("CustomPopupViewController") as! CustomPopupViewController
        self.definesPresentationContext = true
        popController.sessionDictionary = bookingDictionary
        popController.delegate          = self
        popController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        popController.viewTag           = ViewTag.bookView
        presentViewController(popController, animated: true, completion: nil)
    }
}

extension BookingSessionViewController: iCarouselDataSource {
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return user.sports.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        var contentView: UIView
        var titleLabel: UILabel
        var sportsImageView: UIImageView
        var indicatorView: UIActivityIndicatorView
        var tickImageView: UIImageView!
        if view == nil {
            contentView                         = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 78.0, height: carousel.frame.size.height)))
            sportsImageView                     = UIImageView(frame: CGRect(origin: CGPoint(x: 10.0, y: 0.0), size: CGSize(width: carousel.frame.size.height-20.0, height: carousel.frame.size.height-20.0)))
            sportsImageView.contentMode         = .ScaleAspectFit
            sportsImageView.tag                 = 1
            sportsImageView.layer.cornerRadius  = sportsImageView.frame.size.height/2.0
            contentView.addSubview(sportsImageView)
            titleLabel           = UILabel(frame: CGRect(x: 0.0, y: sportsImageView.frame.size.height+2.0, width: contentView.frame.size.width, height: 20.0))
            titleLabel.center    = CGPoint(x: sportsImageView.center.x, y: titleLabel.center.y)
            titleLabel.font      = UIFont(name: "OpenSans", size: 13.0)
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.textColor = UIColor.blackColor()
            titleLabel.textAlignment = NSTextAlignment.Center
            titleLabel.tag       = 2
            contentView.addSubview(titleLabel)
            indicatorView           = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            indicatorView.center    = sportsImageView.center
            indicatorView.hidesWhenStopped  = true
            indicatorView.tag       = 3
            indicatorView.startAnimating()
            contentView.addSubview(indicatorView)
            
            tickImageView           = UIImageView(image: UIImage(named: "tick"))
            tickImageView.frame     = CGRect(origin: CGPoint(x: 12.0, y: 0.0), size: tickImageView.image!.size)
            tickImageView.tag       = 4
            tickImageView.hidden    = true
            contentView.addSubview(tickImageView)
            
        } else {
            contentView     = view!
            sportsImageView = contentView.viewWithTag(1) as! UIImageView
            titleLabel      = contentView.viewWithTag(2) as! UILabel
            indicatorView   = contentView.viewWithTag(3) as! UIActivityIndicatorView
            tickImageView   = contentView.viewWithTag(4) as! UIImageView
        }
        let sports          = user.sports.allObjects[index] as! UserSports
        sportsImageView.image = UIImage(named: "default_image")
        sportsImageView.contentMode = UIViewContentMode.ScaleAspectFit
        CustomURLConnection.downloadAndSetImage(sports.logo, imageView: sportsImageView, activityIndicatorView: indicatorView)

        if index == carousel.currentItemIndex {
            titleLabel.text = sports.sportsName.uppercaseString
            expertLevelLabel.superview?.superview?.hidden = false
            if sports.expertLevel ==  "" {
                expertLevelLabel.superview?.superview?.hidden = true
            } else {
                expertLevelLabel.text = sports.expertLevel
            }
        } else {
            titleLabel.text = sports.sportsName
        }
        if selectedIndexArray.containsObject((user.sports.allObjects[index] as! UserSports).sportsID) {
            tickImageView.hidden = false
        } else {
            tickImageView.hidden = true
        }
        return contentView
    }
}

extension BookingSessionViewController: iCarouselDelegate {
    func carousel(carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        let centerItemZoom: CGFloat     = 1.5
        let centerItemSpacing: CGFloat  = 1.3
        var offset      = offset
        var transform   = transform
        let spacing     = self.carousel(carousel, valueForOption: iCarouselOption.Spacing, withDefault: 1.0)
        let absClampedOffset = min(1.0, fabs(offset))
        let clampedOffset = min(1.0, max(-1.0, offset))
        let scaleFactor = 1.0 + absClampedOffset * (1.0/centerItemZoom - 1.0)
        offset    = (scaleFactor * offset + scaleFactor * (centerItemSpacing - 1.0) * clampedOffset) * carousel.itemWidth * spacing
        transform = CATransform3DTranslate(transform, offset, 0.0, -absClampedOffset)
        transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1.0)
        return transform
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        carousel.reloadData()
    }
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        
        if selectedIndexArray.containsObject((user.sports.allObjects[index] as! UserSports).sportsID) {
            selectedIndexArray.removeObject((user.sports.allObjects[index] as! UserSports).sportsID)
        } else {
            selectedIndexArray.removeAllObjects()
            selectedIndexArray.addObject((user.sports.allObjects[index] as! UserSports).sportsID)
        }
        carousel.reloadData()
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .Spacing
        {
            return value * 1.4
        }
        return value
    }
}

extension BookingSessionViewController: SRMonthPickerDelegate {
    
    func monthPickerWillChangeDate(monthPicker: SRMonthPicker!) {
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitMonth, fromDate: NSDate())
        if monthPicker.selectedYear == monthPicker.minimumYear && monthPicker.selectedMonth < components.month {
            showDismissiveAlertMesssage("You have selected a past month. Please select a future date!")
        }
    }
    
    func monthPickerDidChangeDate(monthPicker: SRMonthPicker!) {
        
    }
}

extension BookingSessionViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let datePicker = datePicker.selectedDate {
            if var timeArray = availSessionTime.objectForKey(Globals.convertDate(datePicker)) as? NSArray {
                if Globals.convertDate(NSDate()) == Globals.convertDate(datePicker) {
                    let time = Globals.convertTime(NSDate())
                    timeArray = timeArray.filteredArrayUsingPredicate(NSPredicate(format: "time_starts > %@", argumentArray: [time]))
                }
                noAvailLabel.hidden = timeArray.count > 0 ? true : false
                return timeArray.count
            } else {
                noAvailLabel.hidden = false
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell        = tableView.dequeueReusableCellWithIdentifier("bookCell") as! BookingTableViewCell
        var timeArray   = availSessionTime.objectForKey(Globals.convertDate(datePicker.selectedDate)) as! NSArray
        if Globals.convertDate(NSDate()) == Globals.convertDate(datePicker.selectedDate) {
            let time    = Globals.convertTime(NSDate())
            timeArray   = timeArray.filteredArrayUsingPredicate(NSPredicate(format: "time_starts > %@", argumentArray: [time]))
        }
        let time        = timeArray.objectAtIndex(indexPath.row) as! NSDictionary
        let starttime   = Globals.convertTimeTo12Hours(time["time_starts"] as! String)
        let endtime     = Globals.convertTimeTo12Hours(time["time_ends"] as! String)
        
        if let place = time["location"] as? String {
            cell.locationTextField.text = place
        } else {
            cell.locationTextField.text = ""
        }
        cell.disabledView.hidden = time["status"]!.boolValue
        cell.locationTextField.userInteractionEnabled  = cell.disabledView.hidden
        cell.timeLabel.text = "\(starttime) to \(endtime)"
        cell.timeLabel.font = UIFont(name: "OpenSans", size: 12.0)
        cell.locationTextField.delegate = self
        cell.bookButton.tag = indexPath.row
        cell.bookButton.addTarget(self, action: "bookingAction:", forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
}

extension BookingSessionViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! BookingTableViewCell
        cell.locationTextField.becomeFirstResponder()
    }
}

extension BookingSessionViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        activeText = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        var timeArray   = NSArray()
        if let prevDate = datePicker.prevDate {
            if Globals.convertDate(datePicker.selectedDate) == Globals.convertDate(prevDate) {
                if let times = availSessionTime.objectForKey(Globals.convertDate(datePicker.selectedDate)) as? NSArray {
                    timeArray = times
                }
            } else {
                if let times = availSessionTime.objectForKey(Globals.convertDate(datePicker.prevDate)) as? NSArray {
                    timeArray = times
                }
            }
        } else {
            if let times = availSessionTime.objectForKey(Globals.convertDate(datePicker.selectedDate)) as? NSArray {
                timeArray = times
            }
        }

        if Globals.convertDate(NSDate()) == Globals.convertDate(datePicker.selectedDate) {
            let time    = Globals.convertTime(NSDate())
            timeArray   = timeArray.filteredArrayUsingPredicate(NSPredicate(format: "time_starts > %@", argumentArray: [time]))
        }
        let cell        = textField.superview?.superview as! BookingTableViewCell
        let indexPath   = bookingTableView.indexPathForCell(cell)
        if timeArray.count > 0 {
            let session     = timeArray.objectAtIndex(indexPath!.row) as! NSMutableDictionary
            session.setObject(textField.text, forKey: "location")
        }

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text        = textField.text+string
        println(Globals.convertDate(datePicker.selectedDate))
        var timeArray   = availSessionTime.objectForKey(Globals.convertDate(datePicker.selectedDate)) as! NSArray
        if Globals.convertDate(NSDate()) == Globals.convertDate(datePicker.selectedDate) {
            let time    = Globals.convertTime(NSDate())
            timeArray   = timeArray.filteredArrayUsingPredicate(NSPredicate(format: "time_starts > %@", argumentArray: [time]))
        }
        let cell        = textField.superview?.superview as! BookingTableViewCell
        let indexPath   = bookingTableView.indexPathForCell(cell)
        let session     = timeArray.objectAtIndex(indexPath!.row) as! NSMutableDictionary
        session.setObject(text, forKey: "location")
        println(text)
        println(session)
        return true
    }
    
}

extension BookingSessionViewController: ConfirmBookDelegate {
    func confirmSessionBook() {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        CustomURLConnection(request: CustomURLConnection.createRequest(bookingDictionary!, methodName: "sessions/request", requestType: HttpMethod.post),delegate: self,tag: Connection.bookingRequest)
    }
}
