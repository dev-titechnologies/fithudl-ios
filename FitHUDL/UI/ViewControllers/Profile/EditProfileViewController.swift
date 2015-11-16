//
//  EditProfileViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 14/10/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var monthPick: SRMonthPicker!
    @IBOutlet weak var timeCollectionView: UICollectionView!
    @IBOutlet weak var datePicker: DIDatepicker!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var contentViewHeightConstriant: NSLayoutConstraint!
    @IBOutlet weak var timesetViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var starttimeView: UIView!
    @IBOutlet weak var endtimeView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var timesetView: UIView!
    @IBOutlet weak var photoButton: UIButton!
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    let hourField   = 97
    let minuteField = 98
    let timeField   = 99
    var tappedView: UIView?     = nil
    var initialStart: NSDate?   = nil
    var initialEnd: NSDate?     = nil
    let availSessionTime = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setStatusBarColor()
        let colorAttributes     = [NSForegroundColorAttributeName: UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)]
        var placeHolderString   = NSAttributedString(string: nameTextField.placeholder!, attributes: colorAttributes)
        nameTextField.attributedPlaceholder = placeHolderString
        
        if IS_IPHONE6PLUS {
            contentViewHeightConstriant.constant = view.frame.size.height-64.0
            view.layoutIfNeeded()
        }
        nameTextField.superview?.layer.borderColor = AppColor.boxBorderColor.CGColor
        
        monthPick.superview!.setTranslatesAutoresizingMaskIntoConstraints(true)
        monthPick.superview!.frame = CGRect(x: 0.0, y: view.frame.size.height, width: view.frame.size.width, height: monthPick.frame.size.height)
        
        datePicker.addTarget(self, action: "dateValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        datePicker.fillDatesFromDate(NSDate(), toDate: Globals.endOfMonth())
        datePicker.selectedDateBottomLineColor = UIColor(red: 0, green: 150/255, blue: 136/255, alpha: 1.0)

        timePicker.minimumDate = NSDate()
        
        let dateFormatter        = NSDateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        monthButton.setTitle(dateFormatter.stringFromDate(NSDate()).uppercaseString, forState: .Normal)
        dateFormatter.dateFormat = "YYYY"
        monthPick.minimumYear    = dateFormatter.stringFromDate(NSDate()).toInt()!
        monthPick.maximumYear    = monthPick.minimumYear+25
        monthPick.font           = UIFont(name: "Open-Sans", size: 17.0)
        monthPick.fontColor      = UIColor(red: 0, green: 120/255, blue: 109/255, alpha: 1.0)
        monthPick.monthPickerDelegate = self
        
        nameTextField.text = appDelegate.user.name
        if let bio = appDelegate.user.bio {
            bioTextView.text = bio
            placeholderLabel.hidden = true
        }
        
        var datesArray  = NSSet(array: appDelegate.user.availableTimeArray.valueForKey("date") as! [String])
        for date in datesArray {
            let filteredArray = appDelegate.user.availableTimeArray.filteredArrayUsingPredicate(NSPredicate(format: "date = %@", argumentArray: [date])) as NSArray
            availSessionTime.setObject(NSMutableArray(array:filteredArray), forKey: date as! String)
        }
        if let url = appDelegate.user.imageURL {
            CustomURLConnection.downloadAndSetImage(url, imageView: photoImageView, activityIndicatorView: indicatorView)
//            photoButton.hidden = true
        } else {
//            photoButton.hidden = false
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        if IS_IPHONE4S || IS_IPHONE5 {
            contentScrollView.contentSize = CGSize(width: contentScrollView.frame.size.width, height: 603.0)
        } else {
            contentScrollView.contentSize = CGSize(width: contentScrollView.frame.size.width, height: contentScrollView.frame.size.height)
        }
    }
    

    
    func setTimePickerValues() {
        let dateString       = Globals.convertDate(datePicker.selectedDate)
        let currentDate      = Globals.convertDate(NSDate())
        let formatter        = NSDateFormatter()
        formatter.dateFormat = "hh:mm a"
        if dateString == currentDate {
            if tappedView == starttimeView {
                timePicker.minimumDate = changeTimeValue(NSDate()).dateByAddingTimeInterval(1800)
            } else {
                timePicker.minimumDate = changeTimeValue(NSDate()).dateByAddingTimeInterval(3600)
            }
        } else {
            formatter.dateFormat = "hh:mm a"
            timePicker.minimumDate = formatter.dateFromString("12:00 AM")
        }
    }
    
    func setTimeValues() {
        let dateString       = Globals.convertDate(datePicker.selectedDate)
        let currentDate      = Globals.convertDate(NSDate())
        let formatter        = NSDateFormatter()
        formatter.dateFormat = "hh:mm a"
        if dateString == currentDate {
            if let start = initialStart {
                
            } else {
                let changedTime = changeTimeValue(NSDate())
                var timeString = formatter.stringFromDate(changedTime.dateByAddingTimeInterval(1800))
                initialStart   = formatter.dateFromString(timeString)
            }
            if let end = initialEnd {
            
            } else {
                let changedTime = changeTimeValue(NSDate())
                var timeString  = formatter.stringFromDate(changedTime.dateByAddingTimeInterval(3600))
                initialEnd      = formatter.dateFromString(timeString)
            }
            var components = formatter.stringFromDate(initialStart!).componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " :"))
            (starttimeView.viewWithTag(hourField) as! UITextField).text = components[0]
            (starttimeView.viewWithTag(minuteField) as! UITextField).text = components[1]
            (starttimeView.viewWithTag(timeField) as! UITextField).text = components[2]

            components     = formatter.stringFromDate(initialEnd!).componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " :"))
            (endtimeView.viewWithTag(hourField) as! UITextField).text = components[0]
            (endtimeView.viewWithTag(minuteField) as! UITextField).text = components[1]
            (endtimeView.viewWithTag(timeField) as! UITextField).text = components[2]
        } else {
            (starttimeView.viewWithTag(hourField) as! UITextField).text = "12"
            (starttimeView.viewWithTag(minuteField) as! UITextField).text = "00"
            (starttimeView.viewWithTag(timeField) as! UITextField).text = "AM"
            (endtimeView.viewWithTag(hourField) as! UITextField).text = "12"
            (endtimeView.viewWithTag(minuteField) as! UITextField).text = "30"
            (endtimeView.viewWithTag(timeField) as! UITextField).text = "AM"
        }
    }
    
    func changeTimeValue(date: NSDate) -> NSDate {
        let time = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute, fromDate: date)
        var value: Int = 0
        let minutes: NSInteger = time.minute
        var newDate:NSDate = NSDate()
        
        if minutes > 0 && minutes < 30 {
            value = 30-minutes
            let timeInterval = date.timeIntervalSinceReferenceDate + NSTimeInterval((60 * value) + minutes)
            newDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        } else if minutes > 30 && minutes < 60 {
            value = 60 - minutes
            let timeInterval = date.timeIntervalSinceReferenceDate + NSTimeInterval(60 * value)
            newDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        }
        return newDate
    }
    
    func splitTimeToIntervals(startTime: String, endTime: String) {
        let timeFormat = NSDateFormatter()
        timeFormat.dateFormat = "hh:mm a"
        var timeArray: NSMutableArray!
        if let array = availSessionTime.objectForKey(Globals.convertDate(datePicker.selectedDate)) as? NSMutableArray {
            timeArray = array
        } else {
            timeArray = NSMutableArray()
        }
        var fromTime = timeFormat.dateFromString(startTime)
        var toTime   = timeFormat.dateFromString(endTime)
        timeFormat.dateFormat = "hh.mm a"
        fromTime     = timeFormat.dateFromString(timeFormat.stringFromDate(fromTime!))
        toTime       = timeFormat.dateFromString(timeFormat.stringFromDate(toTime!))
        var timeAfterInterval = fromTime?.dateByAddingTimeInterval(1800)
        println(fromTime)
        println(timeAfterInterval)
        println(timeFormat.stringFromDate(timeAfterInterval!))
        println(timeFormat.stringFromDate(toTime!))
        while timeAfterInterval!.dateByAddingTimeInterval(1800).compare(toTime!) == NSComparisonResult.OrderedAscending || timeAfterInterval!.dateByAddingTimeInterval(1800).compare(toTime!) == NSComparisonResult.OrderedSame || timeAfterInterval!.compare(toTime!) == NSComparisonResult.OrderedSame {
            let time = NSMutableDictionary()
            time.setObject(timeFormat.stringFromDate(fromTime!), forKey: "time_starts")
            time.setObject(timeFormat.stringFromDate(timeAfterInterval!), forKey: "time_ends")
            time.setObject(Globals.convertDate(datePicker.selectedDate), forKey: "date")
            if !timeArray.containsObject(time) {
                timeArray.addObject(time)
            }
            fromTime          = timeAfterInterval?.dateByAddingTimeInterval(1800)
            timeAfterInterval = fromTime?.dateByAddingTimeInterval(1800)
            println(fromTime)
            println(timeAfterInterval)
            println(timeFormat.stringFromDate(timeAfterInterval!))
            println(timeFormat.stringFromDate(toTime!))
            continue
        }
        availSessionTime.setObject(timeArray, forKey: Globals.convertDate(datePicker.selectedDate))
    }
    
    func dateValueChanged(collectionView: UICollectionView) {
        timeCollectionView.reloadData()
    }

    @IBAction func backButtonClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func dismissTimeView(sender: UIButton) {
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.timesetViewTopConstraint.constant = 0.0
            self.view.layoutIfNeeded()
            }) { (completed) -> Void in
                self.timesetView.hidden = true
        }
    }
    
    @IBAction func photoButtonClicked(sender: UIButton) {
        let actionSheet = UIAlertController(title: "Upload Profile Picture", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let takePhotoButton = UIAlertAction(title: "Take a Photo", style: UIAlertActionStyle.Default) { (takePhoto) -> Void in
            self.showImagePicker(false)
        }
        let photoLibraryButton = UIAlertAction(title: "Choose from Gallery", style: UIAlertActionStyle.Default) { (choosePicture) -> Void in
            self.showImagePicker(true)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        actionSheet.addAction(takePhotoButton)
        actionSheet.addAction(photoLibraryButton)
        actionSheet.addAction(cancelButton)
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func addTimeButtonClicked(sender: UIButton) {
        if let date = datePicker.selectedDate {
            setTimePickerValues()
            setTimeValues()
            timesetView.hidden = false
            UIView.animateWithDuration(animateInterval, animations: { () -> Void in
                self.timesetViewTopConstraint.constant = -180.0
                self.view.layoutIfNeeded()
            })
        } else {
            showDismissiveAlertMesssage("Please select a date")
        }
    }
    
    @IBAction func doneButtonClicked(sender: UIButton) {
        sendRequestToEditProfile()
    }
    
    @IBAction func monthButtonClicked(sender: UIButton) {
        nameTextField.resignFirstResponder()
        bioTextView.resignFirstResponder()
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            if IS_IPHONE4S {
                self.contentScrollView.contentOffset = CGPoint(x: self.contentScrollView.frame.origin.x, y: self.monthButton.superview!.frame.origin.y-50.0)
            }
            self.monthPick.superview!.frame = CGRect(origin: CGPoint(x: 0.0, y: self.view.frame.size.height - self.monthPick.superview!.frame.size.height), size: self.monthPick.superview!.frame.size)
            return
        })
    }
    
    @IBAction func timerCancelButtonClicked(sender: UIButton) {
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.timesetViewTopConstraint.constant = -180.0
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func timerDoneButtonClicked(sender: UIButton) {
        var formatter        = NSDateFormatter()
        formatter.dateFormat = "hh:mm a"
        var timeString       = formatter.stringFromDate(timePicker.date)
        if tappedView == starttimeView {
            initialStart = timePicker.date
        } else if tappedView == endtimeView {
            initialEnd   = timePicker.date
        }
        var components       = timeString.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " :"))
        if tappedView == starttimeView {
            (starttimeView.viewWithTag(hourField) as! UITextField).text = components[0]
            (starttimeView.viewWithTag(minuteField) as! UITextField).text = components[1]
            (starttimeView.viewWithTag(timeField) as! UITextField).text = components[2]
        } else if tappedView == endtimeView {
            (endtimeView.viewWithTag(hourField) as! UITextField).text = components[0]
            (endtimeView.viewWithTag(minuteField) as! UITextField).text = components[1]
            (endtimeView.viewWithTag(timeField) as! UITextField).text = components[2]
        }
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.timesetViewTopConstraint.constant = -180.0
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func pickerDoneClicked(sender: UIButton) {
        let components   = NSDateComponents()
        components.month = monthPick.selectedMonth
        components.year  = monthPick.selectedYear
        let selectedDate = NSCalendar.currentCalendar().dateFromComponents(components)
        let formatter    = NSDateFormatter()
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
    
    @IBAction func pickerCancelClicked(sender: UIButton) {
        hidePickerView()
    }
    
    @IBAction func starttimeTapped(sender: UITapGestureRecognizer) {
        tappedView = sender.view
        setTimePickerValues()
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.timesetViewTopConstraint.constant = -350.0
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func endtimeTapped(sender: UITapGestureRecognizer) {
        tappedView = sender.view
        setTimePickerValues()
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.timesetViewTopConstraint.constant = -350.0
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func photoImageViewTapped(sender: UITapGestureRecognizer) {
        photoButtonClicked(photoButton)
    }
    
    @IBAction func setButtonClicked(sender: UIButton) {
        if validateTimeRange() {
            let startTime = "\((starttimeView.viewWithTag(hourField) as! UITextField).text) \((starttimeView.viewWithTag(minuteField) as! UITextField).text) \((starttimeView.viewWithTag(timeField) as! UITextField).text)"
            let endTime = "\((endtimeView.viewWithTag(hourField) as! UITextField).text) \((endtimeView.viewWithTag(minuteField) as! UITextField).text) \((endtimeView.viewWithTag(timeField) as! UITextField).text)"
            splitTimeToIntervals(startTime, endTime: endTime)
            timeCollectionView.reloadData()
        }
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.timesetViewTopConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        }) { (completed) -> Void in
            self.timesetView.hidden = true
        }
    }
    
    func validateTimeRange() -> Bool {
        if (starttimeView.viewWithTag(hourField) as! UITextField).text == "" {
            showDismissiveAlertMesssage("Please select start time")
            return false
        }
        if (endtimeView.viewWithTag(hourField) as! UITextField).text == "" {
            showDismissiveAlertMesssage("Please select end time")
            return false
        }
        return true
    }
    
    func hidePickerView() {
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.monthPick.superview!.frame = CGRect(origin: CGPoint(x: 0.0, y: self.view.frame.size.height), size: self.monthPick.superview!.frame.size)
            return
        })
    }
    
    func timeDeleteButtonClicked(deleteButton : UIButton) {
        let cell = deleteButton.superview?.superview as! AvailableTimeCollectionViewCell
        let indexPath = timeCollectionView.indexPathForCell(cell)
        let timeArray = availSessionTime.objectForKey(Globals.convertDate(datePicker.selectedDate)) as! NSMutableArray
        timeArray.removeObjectAtIndex(indexPath!.item)
        timeCollectionView.reloadData()
    }
    
    func showImagePicker(isGallery: Bool) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            imagePicker.delegate = self
            if isGallery {
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            } else {
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            }
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
//    func generateBoundaryString() -> String {
//        return "Boundary-\(NSUUID().UUIDString)"
//    }
//    
//    func sendRequestToEditProfile() {
//        if !Globals.isInternetConnected() {
//            return
//        }
//        showLoadingView(true)
//        let requestURL = SERVER_URL.stringByAppendingString("user/editProfile")
//        let request    = NSMutableURLRequest(URL: NSURL(string: requestURL)!)
//        request.HTTPMethod = HttpMethod.post
//        
//        let requestDictionary = NSMutableDictionary()
//        requestDictionary.setObject(nameTextField.text, forKey: "name")
//        requestDictionary.setObject(bioTextView.text, forKey: "bio")
//        let timeArray = NSMutableArray()
//        for value in availSessionTime.allValues {
//            timeArray.addObjectsFromArray(value as! [AnyObject])
//        }
//        requestDictionary.setObject(timeArray, forKey: "session")
//        if let deviceToken = appDelegate.deviceToken {
//            requestDictionary.setObject(deviceToken, forKey:"device_id")
//        } else {
//            requestDictionary.setObject("xyz", forKey: "device_id")
//        }
//        if let apiToken = NSUserDefaults.standardUserDefaults().objectForKey("API_TOKEN") as? String {
//            requestDictionary.setObject(apiToken, forKey: "token")
//        }
//        
//        let boundary = generateBoundaryString()
//        
//        request.setValue("multipart/form-date; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        request.HTTPBody = createBodyWithParameters(requestDictionary, boundary: boundary, imageData: UIImageJPEGRepresentation(photoImageView.image, 0.5))
//        CustomURLConnection(request: request, delegate: self, tag: Connection.userProfile)
//    }
//    
//    func createBodyWithParameters(parameters: NSDictionary, boundary: String, imageData: NSData) -> NSData {
//        var body = NSMutableData()
//        for (key, value) in parameters {
//            body.appendString("--\(boundary)\r\n")
//            body.appendString("Content-Disposition: form-data; name=\(key)\r\n\r\n")
//            body.appendString("\(value)\r\n")
//        }
//        let mimetype = "image/jpg"
//        body.appendString("--\(boundary)\r\n")
//        body.appendString("Content-Disposition: form-data; name=\"file\"\r\n")
//        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
//        body.appendData(imageData)
//        body.appendString("\r\n--\(boundary)--\r\n")
//        return body
//    }
    
    func sendRequestToEditProfile() {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(nameTextField.text, forKey: "name")
        requestDictionary.setObject(bioTextView.text, forKey: "bio")
        let timeArray = NSMutableArray()
        for value in availSessionTime.allValues {
            for time in (value as! [NSMutableDictionary]) {
                time.setObject(Globals.convertTimeTo24Hours(time.objectForKey("time_starts") as! String), forKey: "time_starts")
                time.setObject(Globals.convertTimeTo24Hours(time.objectForKey("time_ends") as! String), forKey: "time_ends")
            }
            timeArray.addObjectsFromArray(value as! [NSDictionary])
        }
        requestDictionary.setObject(timeArray, forKey: "session")
        if let image = photoImageView.image {
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            let imageString = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
            requestDictionary.setObject(imageString, forKey: "file")
        }
        
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "user/editProfile", requestType: HttpMethod.post), delegate: self, tag: Connection.userProfile)
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
                    dismissViewControllerAnimated(true, completion: nil)
                } else if status == ResponseStatus.error {
                    if let message = jsonResult["message"] as? String {
                        showDismissiveAlertMesssage(message)
                    } else {
                        showDismissiveAlertMesssage(Message.Error)
                    }
                } else {
                    dismissViewControllerAnimated(false, completion: nil)
                    self.presentingViewController?.dismissOnSessionExpire()
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

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let selectedImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        photoImageView.image = selectedImage
        photoButton.hidden = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        hidePickerView()
        if IS_IPHONE4S {
            UIView.animateWithDuration(animateInterval, animations: { () -> Void in
                self.contentScrollView.contentOffset = CGPoint(x: self.contentScrollView.frame.origin.x, y: self.nameTextField.superview!.frame.origin.y)
                return
            })
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.contentScrollView.contentOffset = CGPointZero
            return
        })
        return true
    }
}

extension EditProfileViewController: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        hidePickerView()
        if IS_IPHONE4S {
            UIView.animateWithDuration(animateInterval, animations: { () -> Void in
                self.contentScrollView.contentOffset = CGPoint(x: self.contentScrollView.frame.origin.x, y: self.nameTextField.superview!.frame.origin.y)
                return
            })
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        if count(textView.text) == 0 {
            placeholderLabel.hidden = false
        } else {
            placeholderLabel.hidden = true
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            UIView.animateWithDuration(animateInterval, animations: { () -> Void in
                self.contentScrollView.contentOffset = CGPointZero
                return
            })
            if count(textView.text) == 0 {
                placeholderLabel.hidden = false
            }
            return false
        }
        return true
    }
}

extension EditProfileViewController: SRMonthPickerDelegate {
    func monthPickerWillChangeDate(monthPicker: SRMonthPicker!) {
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitMonth, fromDate: NSDate())
        if monthPicker.selectedYear == monthPicker.minimumYear && monthPicker.selectedMonth < components.month {
            showDismissiveAlertMesssage("You have selected a past month. Please select a future date!")
        }
    }
    
    func monthPickerDidChangeDate(monthPicker: SRMonthPicker!) {
        
    }
}

extension EditProfileViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let datePicker = datePicker.selectedDate {
            if let timeArray = availSessionTime.objectForKey(Globals.convertDate(datePicker)) as? NSArray {
                return timeArray.count
            }
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell            = collectionView.dequeueReusableCellWithReuseIdentifier("timeCell", forIndexPath: indexPath) as! AvailableTimeCollectionViewCell
        let time            = (availSessionTime.objectForKey(Globals.convertDate(datePicker.selectedDate)) as! NSArray).objectAtIndex(indexPath.item) as! NSDictionary
        let starttime       = Globals.convertTimeTo12Hours(time["time_starts"] as! String)
        let endtime         = Globals.convertTimeTo12Hours(time["time_ends"] as! String)
        cell.timeLabel.text = "\(starttime) to \(endtime)"
        cell.timeLabel.superview?.layer.borderColor = UIColor(red: 0, green: 142/255, blue: 130/255, alpha: 1.0).CGColor
        cell.deleteButton.addTarget(self, action: "timeDeleteButtonClicked:", forControlEvents: .TouchUpInside)
        return cell
    }
}

extension EditProfileViewController: UICollectionViewDelegate {

}

extension EditProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if IS_IPHONE6 || IS_IPHONE6PLUS {
            return CGSize(width: (collectionView.frame.size.width-30)/3, height: 40.0)
        }
        return CGSize(width: 98.0, height: 40.0)
    }
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}