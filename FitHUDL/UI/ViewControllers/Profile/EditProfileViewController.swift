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
    @IBOutlet weak var nameLabel: UILabel!
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
    @IBOutlet weak var interestTextView: UITextView!
    @IBOutlet weak var moreTimeButton: UIButton!
    var bioOnly     = false
    var photoSelected = false
    let hourField   = 97
    let minuteField = 98
    let timeField   = 99
    var tappedView: UIView?     = nil
    var initialStart: NSDate?   = nil
    var initialEnd: NSDate?     = nil
    let availSessionTime = NSMutableDictionary()
    
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeViewHeightConstraint: NSLayoutConstraint!
    
    let duration = appDelegate.configDictionary[TimeOut.sessionDuration]!.integerValue * secondsValue
    let interval = appDelegate.configDictionary[TimeOut.sessionInterval]!.integerValue * secondsValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bioTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        bioTextView.layer.borderWidth = 1.0
        
        interestTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        interestTextView.layer.borderWidth = 1.0
        
        moreTimeButton.hidden = true
        
        navigationController?.setStatusBarColor()
        
        if IS_IPHONE6PLUS {
            contentViewHeightConstriant.constant = view.frame.size.height-64.0
            view.layoutIfNeeded()
        }
        monthPick.superview!.setTranslatesAutoresizingMaskIntoConstraints(true)
        monthPick.superview!.frame = CGRect(x: 0.0, y: view.frame.size.height, width: view.frame.size.width, height: monthPick.frame.size.height)
        bioTextView.superview?.layer.borderColor = UIColor.clearColor().CGColor
        
        nameLabel.text   = appDelegate.user!.name
        bioTextView.text = appDelegate.user!.bio
        interestTextView.text = appDelegate.user!.interests
        CustomURLConnection.downloadAndSetImage(appDelegate.user!.imageURL, imageView: photoImageView, activityIndicatorView: indicatorView)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        datePicker.addTarget(self, action: "dateValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        datePicker.fillDatesFromDate(NSDate(), toDate: Globals.endOfMonth())
        datePicker.selectedDateBottomLineColor = UIColor(red: 0, green: 150/255, blue: 136/255, alpha: 1.0)
        
        timePicker.minimumDate   = NSDate()
        
        let dateFormatter        = NSDateFormatter()
        dateFormatter.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MMM yyyy"
        monthButton.setTitle(dateFormatter.stringFromDate(NSDate()).uppercaseString, forState: .Normal)
        dateFormatter.dateFormat = "YYYY"
        monthPick.minimumYear    = dateFormatter.stringFromDate(NSDate()).toInt()!
        monthPick.maximumYear    = monthPick.minimumYear+25
        monthPick.font           = UIFont(name: "Open-Sans", size: 17.0)
        monthPick.fontColor      = UIColor(red: 0, green: 120/255, blue: 109/255, alpha: 1.0)
        monthPick.monthPickerDelegate = self
        
        var datesArray  = appDelegate.user?.availableTime.valueForKey("date") as! NSSet
        for date in datesArray {
            var filteredArray = NSMutableArray(array: appDelegate.user!.availableTime.allObjects).filteredArrayUsingPredicate(NSPredicate(format: "date = %@", argumentArray: [date]))
            availSessionTime.setObject(NSMutableArray(array:filteredArray), forKey: date as! String
            )
        }
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
        formatter.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "hh:mm a"

        if dateString == currentDate {
            if tappedView == starttimeView {
                timePicker.minimumDate = changeTimeValue(NSDate())
            } else {
                timePicker.minimumDate = changeTimeValue(NSDate()).dateByAddingTimeInterval(NSTimeInterval(duration))
            }
        } else {
            formatter.dateFormat    = "hh:mm a"
            timePicker.minimumDate  = formatter.dateFromString("12:00 AM")
        }
    }
    
    func setTimeValues() {
        let dateString       = Globals.convertDate(datePicker.selectedDate)
        let currentDate      = Globals.convertDate(NSDate())
        let formatter        = NSDateFormatter()
        formatter.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "hh:mm a"
        if dateString == currentDate {
            if let start = initialStart {
                
            } else {
                let changedTime = changeTimeValue(NSDate())
                var timeString = formatter.stringFromDate(changedTime)
                initialStart   = formatter.dateFromString(timeString)
            }
            if let end = initialEnd {
            
            } else {
                let changedTime = changeTimeValue(NSDate())
                var timeString  = formatter.stringFromDate(changedTime.dateByAddingTimeInterval(NSTimeInterval(duration)))
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
//        let time = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute, fromDate: date)
//        var value: Int = 0
//        let minutes: NSInteger = time.minute
//        var newDate:NSDate = NSDate()
//        
//        if minutes >= 0 && minutes <= 30 {
//            value = 30-minutes
//            let timeInterval = date.timeIntervalSinceReferenceDate + NSTimeInterval((60 * value) + minutes)
//            newDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
//        } else if minutes > 30 && minutes <= 60 {
//            value = 60 - minutes
//            let timeInterval = date.timeIntervalSinceReferenceDate + NSTimeInterval(60 * value)
//            newDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
//        }
//        return newDate
        
        let calendar = NSCalendar.currentCalendar()
//        let comps    = calendar.components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour, fromDate: date)
//        println(comps)
//        comps.hour   = comps.hour+1
//        println(comps)
//        println(calendar.dateFromComponents(comps)!)
//        return calendar.dateFromComponents(comps)!
        var minuteComponent = calendar.components(NSCalendarUnit.CalendarUnitMinute, fromDate: date)
        println(minuteComponent)
        let components      = NSDateComponents()
        components.minute   = 60-minuteComponent.minute
        println(components)
        println(calendar.dateByAddingComponents(components, toDate: date, options: nil)!)
        return calendar.dateByAddingComponents(components, toDate: date, options: nil)!
        
    }
    
    func splitTimeToIntervals(startTime: String, endTime: String) {
        let timeFormat = NSDateFormatter()
        timeFormat.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
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
        
        var timeAfterInterval = fromTime?.dateByAddingTimeInterval(NSTimeInterval(duration))

        while timeAfterInterval!.dateByAddingTimeInterval(NSTimeInterval(duration)).compare(toTime!) == NSComparisonResult.OrderedAscending || timeAfterInterval!.dateByAddingTimeInterval(NSTimeInterval(duration)).compare(toTime!) == NSComparisonResult.OrderedSame || timeAfterInterval!.compare(toTime!) == NSComparisonResult.OrderedSame {
            let time        = UserTime.saveUserTimeList(Globals.convertDate(datePicker.selectedDate), startTime: Globals.convertTimeTo24Hours(timeFormat.stringFromDate(fromTime!)), endTime: Globals.convertTimeTo24Hours(timeFormat.stringFromDate(timeAfterInterval!)), user: appDelegate.user!)
            if !timeArray.valueForKey("timeStarts")!.containsObject(time.timeStarts) {
                timeArray.addObject(time)
            }
            fromTime          = timeAfterInterval?.dateByAddingTimeInterval(NSTimeInterval(duration))
            timeAfterInterval = fromTime?.dateByAddingTimeInterval(NSTimeInterval(duration))
            continue
        }
        availSessionTime.setObject(timeArray, forKey: Globals.convertDate(datePicker.selectedDate))
    }
    
    func dateValueChanged(collectionView: UICollectionView) {
        if let datePicker = datePicker.selectedDate {
            if let timeArray = availSessionTime.objectForKey(Globals.convertDate(datePicker)) as? NSArray {
                if timeArray.count > 6 {
                    moreTimeButton.hidden = false
                } else {
                    moreTimeButton.hidden = true
                }
            } else {
                moreTimeButton.hidden = true
            }
            timeViewHeightConstraint.constant    = 90.0
            if IS_IPHONE4S || IS_IPHONE5 {
                contentViewHeightConstriant.constant = 603.0
            } else {
                contentViewHeightConstriant.constant = contentScrollView.frame.size.height
            }
            view.layoutIfNeeded()
            contentScrollView.contentSize   = CGSize(width: contentScrollView.frame.size.width, height: contentViewHeightConstriant.constant)
        } else {
            moreTimeButton.hidden = true
        }
        timeCollectionView.reloadData()
    }

    func highlightTappedView() {
        let view1 = tappedView?.viewWithTag(10)
        let view2 = tappedView?.viewWithTag(11)
        let view3 = tappedView?.viewWithTag(12)
        view1?.backgroundColor = AppColor.statusBarColor
        view2?.backgroundColor = AppColor.statusBarColor
        view3?.backgroundColor = AppColor.statusBarColor
    }
    
    func unhighlightTappedView(tappedView: UIView) {
        let view1 = tappedView.viewWithTag(10)
        let view2 = tappedView.viewWithTag(11)
        let view3 = tappedView.viewWithTag(12)
        view1?.backgroundColor = AppColor.boxBorderColor
        view2?.backgroundColor = AppColor.boxBorderColor
        view3?.backgroundColor = AppColor.boxBorderColor
    }
    
    func scaleAndRotateImage(originalImage: UIImage) -> UIImage {
        let maxResolution: CGFloat  = 270
        let imageRef: CGImageRef    = originalImage.CGImage
        let width: CGFloat          = CGFloat(CGImageGetWidth(imageRef))
        let height: CGFloat         = CGFloat(CGImageGetHeight(imageRef))
        var transform               = CGAffineTransformIdentity
        var bounds                  = CGRect(origin: CGPointZero, size: CGSize(width: width, height: height))
        if (width > maxResolution) || (height > maxResolution) {
            let ratio = width/height
            if ratio > 1 {
                bounds.size.width  = maxResolution
                bounds.size.height = bounds.size.width/ratio
            } else {
                bounds.size.height = maxResolution
                bounds.size.width  = bounds.size.height*ratio
            }
        }
        let scaleRatio              = bounds.size.width/width
        let imageSize               = CGSize(width: CGFloat(CGImageGetWidth(imageRef)), height: CGFloat(CGImageGetHeight(imageRef)))
        var boundHeight: CGFloat    = 0
        let orient: UIImageOrientation = originalImage.imageOrientation
        switch orient {
        case UIImageOrientation.Up:
            transform = CGAffineTransformIdentity
        case UIImageOrientation.UpMirrored:
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0)
            transform = CGAffineTransformScale(transform, -1.0, 1.0)
        case UIImageOrientation.Down:
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height)
            transform = CGAffineTransformScale(transform, 1.0, -1.0)
        case UIImageOrientation.DownMirrored:
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height)
            transform = CGAffineTransformScale(transform, 1.0, -1.0)
        case UIImageOrientation.Left:
            boundHeight         = bounds.size.height
            bounds.size.height  = bounds.size.width
            bounds.size.width   = boundHeight
            transform           = CGAffineTransformMakeTranslation(0.0, imageSize.width)
            transform           = CGAffineTransformRotate(transform, CGFloat(3.0 * M_PI / 2.0))
        case UIImageOrientation.LeftMirrored:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width)
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, CGFloat(3.0 * M_PI / 2.0))
        case UIImageOrientation.Right:
            boundHeight         = bounds.size.height
            bounds.size.height  = bounds.size.width
            bounds.size.width   = boundHeight
            transform           = CGAffineTransformMakeTranslation(imageSize.height, 0.0)
            transform           = CGAffineTransformRotate(transform,CGFloat(M_PI / 2.0))
        case UIImageOrientation.RightMirrored:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeScale(-1.0, 1.0)
            transform = CGAffineTransformRotate(transform,CGFloat(M_PI / 2.0))
        default:
            break
        }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        let context = UIGraphicsGetCurrentContext()
        if orient == UIImageOrientation.Right || orient == UIImageOrientation.Left {
            CGContextScaleCTM(context, -scaleRatio, scaleRatio)
            CGContextTranslateCTM(context, -height, 0)
        } else {
            CGContextScaleCTM(context, scaleRatio, -scaleRatio)
            CGContextTranslateCTM(context, 0, -height)
        }
        CGContextConcatCTM(context, transform)
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRect(origin: CGPointZero, size: CGSize(width: width, height: height)), imageRef)
        let imageCopy: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageCopy
    }
    
    @IBAction func backButtonClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func dismissTimeView(sender: UIButton) {
        doneButton.enabled = true
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
    
    @IBAction func moreTimeButtonClicked(sender: UIButton) {
        timeViewHeightConstraint.constant    = timeCollectionView.contentSize.height
        contentViewHeightConstriant.constant += (timeViewHeightConstraint.constant-90.0)
        view.layoutIfNeeded()
        println(timeViewHeightConstraint.constant)
        println(contentViewHeightConstriant.constant)
        contentScrollView.contentSize        = CGSize(width: contentScrollView.frame.size.width, height: contentViewHeightConstriant.constant)
        println(contentScrollView.contentSize)
        moreTimeButton.hidden = true
        println(timeCollectionView.contentSize)
    }
    
    @IBAction func addTimeButtonClicked(sender: UIButton) {
        if let date = datePicker.selectedDate {
            doneButton.enabled = false
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
        if validateBio() {
            bioOnly = false
            sendRequestToEditProfile()
        }
    }
    
    @IBAction func monthButtonClicked(sender: UIButton) {
        bioTextView.resignFirstResponder()
        interestTextView.resignFirstResponder()
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
        formatter.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
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
        formatter.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
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
        unhighlightTappedView(endtimeView)
        highlightTappedView()
        setTimePickerValues()
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.timesetViewTopConstraint.constant = -350.0
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func endtimeTapped(sender: UITapGestureRecognizer) {
        tappedView = sender.view
        setTimePickerValues()
        unhighlightTappedView(starttimeView)
        highlightTappedView()
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.timesetViewTopConstraint.constant = -350.0
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func photoImageViewTapped(sender: UITapGestureRecognizer) {
        photoButtonClicked(photoButton)
    }
    
    @IBAction func setButtonClicked(sender: UIButton) {
        doneButton.enabled = true
        if let view = tappedView {
            unhighlightTappedView(view)
        }
        if validateTimeRange() {
            let startTime = "\((starttimeView.viewWithTag(hourField) as! UITextField).text):\((starttimeView.viewWithTag(minuteField) as! UITextField).text) \((starttimeView.viewWithTag(timeField) as! UITextField).text)"
            let endTime = "\((endtimeView.viewWithTag(hourField) as! UITextField).text):\((endtimeView.viewWithTag(minuteField) as! UITextField).text) \((endtimeView.viewWithTag(timeField) as! UITextField).text)"
            splitTimeToIntervals(startTime, endTime: endTime)
            timeCollectionView.reloadData()
        }
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.timesetViewTopConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        }) { (completed) -> Void in
            self.timesetView.hidden = true
        }
        if let datePicker = datePicker.selectedDate {
            if let timeArray = availSessionTime.objectForKey(Globals.convertDate(datePicker)) as? NSArray {
                if timeArray.count > 6 {
                    moreTimeButton.hidden = false
                } else {
                    moreTimeButton.hidden = true
                }
            } else {
                moreTimeButton.hidden = true
            }
        } else {
            moreTimeButton.hidden = true
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
    
    func validateBio() -> Bool {
        if bioTextView.text == "" {
            showDismissiveAlertMesssage("Please enter your profile description")
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
        let cell        = deleteButton.superview?.superview as! AvailableTimeCollectionViewCell
        let indexPath   = timeCollectionView.indexPathForCell(cell)
        var timeArray   = availSessionTime.objectForKey(Globals.convertDate(datePicker.selectedDate)) as! NSArray
        timeArray       = timeArray.sortedArrayUsingComparator({ (obj1, obj2) -> NSComparisonResult in
            let dateFormatter        = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let date1 = dateFormatter.dateFromString((obj1 as! UserTime).timeStarts as String)
            let date2 = dateFormatter.dateFromString((obj2 as! UserTime).timeStarts as String)
            return date1!.compare(date2!)
        })
        let mutableArray = NSMutableArray(array: timeArray)
        mutableArray.removeObjectAtIndex(indexPath!.item)
        timeArray = mutableArray
        availSessionTime.setObject(timeArray, forKey: Globals.convertDate(datePicker.selectedDate))
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
        
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(bioTextView.text, forKey: "bio")
        if !bioOnly {
            showLoadingView(true)
            requestDictionary.setValue(interestTextView.text, forKey: "other_interests")
            let timeArray = NSMutableArray()
            for value in availSessionTime.allValues {
                for time in (value as! [UserTime]) {
                    let setTime = NSMutableDictionary()
                    setTime.setObject(time.date, forKey: "date")
                    setTime.setObject(Globals.convertTimeTo24Hours(time.timeStarts), forKey: "time_starts")
                    setTime.setObject(Globals.convertTimeTo24Hours(time.timeEnds), forKey: "time_ends")
                    timeArray.addObject(setTime)
                }
            }
            requestDictionary.setObject(timeArray, forKey: "session")
            if photoSelected == true {
                if let image = photoImageView.image {
                    let imageData = UIImageJPEGRepresentation(image, 0.5)
                    let imageString = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
                    requestDictionary.setObject(imageString, forKey: "file")
                }
            }
        }
        println("requestDictionary : \(requestDictionary)")
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
                    if !bioOnly {
                        if photoSelected == true && photoImageView.image != nil {
                            appDelegate.user!.profileImage = UIImagePNGRepresentation(photoImageView.image)
                            photoSelected = false
                        }
                        dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        appDelegate.user!.bio = bioTextView.text
                        bioOnly = false
                    }
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
        let selectedImage    = info["UIImagePickerControllerOriginalImage"] as! UIImage
        photoSelected        = true
        photoImageView.image = scaleAndRotateImage(selectedImage)
        photoButton.hidden   = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension EditProfileViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        println("IN textviewwww")
        textView.layer.borderColor = AppColor.boxBorderColor.CGColor
        textView.layer.borderWidth = 1.0
        hidePickerView()
        if IS_IPHONE4S {
            
            UIView.animateWithDuration(animateInterval, animations: { () -> Void in
                self.contentScrollView.contentOffset = CGPoint(x: self.contentScrollView.frame.origin.x, y: self.bioTextView.superview!.frame.origin.y)
                return
            })
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.layer.borderColor = UIColor.lightGrayColor().CGColor
            textView.layer.borderWidth = 1.0
            textView.resignFirstResponder()
            if validateBio() {
                bioOnly = true
                sendRequestToEditProfile()
            }
            UIView.animateWithDuration(animateInterval, animations: { () -> Void in
                self.contentScrollView.contentOffset = CGPointZero
                return
            })
            return false
        }
        if text == "" {
            return true
        }
        if textView == interestTextView {
            
            return count(textView.text) + (count(text) - range.length) <= BIOTEXT_LENGTH
        }
        else {
        return count(textView.text) + (count(text) - range.length) <= BIOLIMIT
        }
        
        
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
        var filteredArray   = availSessionTime.objectForKey(Globals.convertDate(datePicker.selectedDate)) as! NSArray
        filteredArray       = filteredArray.sortedArrayUsingComparator({ (obj1, obj2) -> NSComparisonResult in
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let date1 = dateFormatter.dateFromString((obj1 as! UserTime).timeStarts as String)
            let date2 = dateFormatter.dateFromString((obj2 as! UserTime).timeStarts as String)
            return date1!.compare(date2!)
        })

        let time            = filteredArray.objectAtIndex(indexPath.item) as! UserTime
        let starttime       = Globals.convertTimeTo12Hours(time.timeStarts)
        let endtime         = Globals.convertTimeTo12Hours(time.timeEnds)
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