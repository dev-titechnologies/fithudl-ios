//
//  BookingSessionViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 26/10/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class BookingSessionViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib  = UINib(nibName: "BookingTableViewCell", bundle: nil)
        bookingTableView.registerNib(nib, forCellReuseIdentifier: "bookCell")
        
        monthPicker.superview!.setTranslatesAutoresizingMaskIntoConstraints(true)
        monthPicker.superview!.frame = CGRect(x: 0.0, y: view.frame.size.height, width: view.frame.size.width, height: monthPicker.frame.size.height)
        
        datePicker.addTarget(self, action: "dateValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        datePicker.fillDatesFromDate(NSDate(), toDate: Globals.endOfMonth())
        datePicker.selectedDateBottomLineColor = UIColor(red: 0, green: 150/255, blue: 136/255, alpha: 1.0)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY"
        monthPicker.minimumYear  = dateFormatter.stringFromDate(NSDate()).toInt()!
        monthPicker.maximumYear  = monthPicker.minimumYear+25
        monthPicker.font         = UIFont(name: "Open-Sans", size: 17.0)
        monthPicker.fontColor    = UIColor(red: 0, green: 120/255, blue: 109/255, alpha: 1.0)
        monthPicker.monthPickerDelegate = self
        
        nameLabel.text = appDelegate.user.name
        
        if let bioText = user.bio {
            if count(bioText) > BIOTEXT_LENGTH {
                bioLabel.userInteractionEnabled = true
                Globals.attributedBioText((bioText as NSString).substringToIndex(BIOTEXT_LENGTH-1), lengthExceed: true, bioLabel: bioLabel)
            } else {
                bioLabel.userInteractionEnabled = false
                Globals.attributedBioText((bioText as NSString).substringToIndex((bioText as NSString).length), lengthExceed: false, bioLabel: bioLabel)
            }
        }

        if let url = appDelegate.user.imageURL {
            CustomURLConnection.downloadAndSetImage(url, imageView: profileImageView, activityIndicatorView: indicatorView)
        } else {
        }
        
        // Do any additional setup after loading the view.
    }

    func dateValueChanged(collectionView: UICollectionView) {
        bookingTableView.reloadData()
    }
    
    @IBAction func pickerCancelClicked(sender: UIButton) {
        
    }
    
    @IBAction func pickerDoneClicked(sender: UIButton) {
        
    }
    
    @IBAction func favoriteButtonClicked(sender: UIButton) {
        
    }
    
    @IBAction func cancelViewTapped(sender: UITapGestureRecognizer) {
        
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

extension BookingSessionViewController: iCarouselDataSource {
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return user.sportsArray.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        var contentView: UIView
        var titleLabel: UILabel
        var sportsImageView: UIImageView
        var indicatorView: UIActivityIndicatorView
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
        } else {
            contentView     = view!
            sportsImageView = contentView.viewWithTag(1) as! UIImageView
            titleLabel      = contentView.viewWithTag(2) as! UILabel
            indicatorView   = contentView.viewWithTag(3) as! UIActivityIndicatorView
        }
        let sports          = user.sportsArray[index] as! NSDictionary
        if let logo = sports["logo"] as? String {
            CustomURLConnection.downloadAndSetImage(logo, imageView: sportsImageView, activityIndicatorView: indicatorView)
        } else {
            CustomURLConnection.downloadAndSetImage("", imageView: sportsImageView, activityIndicatorView: indicatorView)
        }
        if index == carousel.currentItemIndex {
            titleLabel.text = sports["sport_name"]!.uppercaseString as String
            expertLevelLabel.superview?.superview?.hidden = false
            if let level = sports["expert_level"] as? String {
                if level ==  "" {
                    expertLevelLabel.superview?.superview?.hidden = true
                } else {
                    expertLevelLabel.text = level
                }
            } else {
                expertLevelLabel.superview?.superview?.hidden = true
            }
        } else {
            titleLabel.text = sports["sport_name"] as? String
        }
        
        return contentView
    }
}

extension BookingSessionViewController: iCarouselDelegate {
    func carousel(carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        let centerItemZoom: CGFloat = 1.5
        let centerItemSpacing: CGFloat = 1.4
        
        var offset      = offset
        var transform   = transform
        
        let spacing     = self.carousel(carousel, valueForOption: iCarouselOption.Spacing, withDefault: 1.0)
        let absClampedOffset = min(1.0, fabs(offset))
        let clampedOffset = min(1.0, max(-1.0, offset))
        let scaleFactor = 1.0 + absClampedOffset * (1.0/centerItemZoom - 1.0)
        offset = (scaleFactor * offset + scaleFactor * (centerItemSpacing - 1.0) * clampedOffset) * carousel.itemWidth * spacing
        transform = CATransform3DTranslate(transform, offset, 0.0, -absClampedOffset)
        transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1.0)
        return transform
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        carousel.reloadData()
    }
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .Spacing {
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
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("bookCell") as! BookingTableViewCell
        return cell
    }
}

extension BookingSessionViewController: UITableViewDelegate {

}
