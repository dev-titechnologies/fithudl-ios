//
//  MyProfileViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 28/09/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class AvailableTimeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
}

class MyProfileViewController: UIViewController {
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var expertButton: UIButton!
    @IBOutlet weak var moderateButton: UIButton!
    @IBOutlet weak var beginnerButton: UIButton!
    @IBOutlet weak var sportsCarousel: iCarousel!
    @IBOutlet weak var reviewCollectionView: UICollectionView!
    @IBOutlet weak var reviewNextButton: UIButton!
    @IBOutlet weak var reviewBackButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var badgesCollectionView: UICollectionView!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var sessionCountLabel: UILabel!
    @IBOutlet weak var starView: StarRateView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var badgeNextButton: UIButton!
    @IBOutlet weak var badgePrevButton: UIButton!
    @IBOutlet weak var availableTimeCollectionView: UICollectionView!
    @IBOutlet weak var reviewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var reviewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeCollectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var availableTimeView: UIView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var morebgView: UIView!
    @IBOutlet weak var noBadgeLabel: UILabel!
    @IBOutlet weak var noreviewLabel: UILabel!
    @IBOutlet weak var notimeLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var completedTitleLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var bookView: UIView!
    @IBOutlet weak var calloutView: UIView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var expertLevelLabel: UILabel!
    @IBOutlet weak var NotificationView: UIView!
    @IBOutlet weak var notificationBackgroundView: UIView!
    @IBOutlet weak var notificationBgtrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var notificationArrowTrailingConstraint: NSLayoutConstraint!
    var searchResultId:String?
    var profileID: String?
    let calloutViewYAxis:CGFloat = 52.0
    let profileUser = User()
    var notificationListArray =  Array<NSDictionary>()
    
    @IBOutlet weak var notifIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var packagesButton: UIButton!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var carouselBackgroundView: NSLayoutConstraint!
    @IBOutlet weak var notificationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var nib = UINib(nibName: "UserReviewCollectionViewCell", bundle: nil)
        reviewCollectionView.registerNib(nib, forCellWithReuseIdentifier: "reviewCell")
        
        nib = UINib(nibName: "BadgesCollectionViewCell", bundle: nil)
        badgesCollectionView.registerNib(nib, forCellWithReuseIdentifier: "badgeCell")
        
        let notificationNib  = UINib(nibName: "NotificationCell", bundle: nil)
        notificationTableView.registerNib(notificationNib, forCellReuseIdentifier: "Cell")
        
        badgePrevButton.enabled  = false
        badgeNextButton.enabled  = true
        
        reviewCollectionView.contentOffset = CGPointZero
        reviewBackButton.enabled = false
        reviewNextButton.enabled = true
        
        sportsCarousel.type = iCarouselType.Custom
        navigationController?.setStatusBarColor()
        
//        if let id = searchResultId {
//        scrollViewBottomConstraint.constant = -65
//        carouselBackgroundView.constant     = 226.0
//        view.layoutIfNeeded()
//        }
        if IS_IPHONE6PLUS {
            profileViewHeightConstraint.constant = 260.0
            reviewTopConstraint.constant         = 30.0
            reviewBottomConstraint.constant      = 30.0
            view.layoutIfNeeded()
        }
    
        if let id = profileID {
            favoriteButton.hidden      = false
            completedTitleLabel.hidden = true
            hoursLabel.hidden          = true
            editButton.hidden          = true
            beginnerButton.superview?.hidden    = true
            expertLevelLabel.superview?.hidden  = false
            notificationButton.hidden  = true
            settingsButton.setImage(UIImage(named: "back_button"), forState: UIControlState.Normal)
        }
        beginnerButton.selected = false
        moderateButton.selected = false
        expertButton.selected   = false
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        availableTimeCollectionView.reloadData()
        morebgView.hidden   = false
        moreButton.hidden   = false
        notimeLabel.hidden  = true
        availableTimeCollectionView.hidden = false
        noBadgeLabel.hidden         = true
        badgesCollectionView.hidden = false
        noreviewLabel.hidden        = true
        reviewCollectionView.hidden = false
        badgeNextButton.hidden      = true
        badgePrevButton.hidden      = true
        buttonView.hidden           = true
        
        calloutView.removeFromSuperview()
        calloutView.setTranslatesAutoresizingMaskIntoConstraints(true)
        calloutView.frame = CGRect(x: 0.0, y: calloutViewYAxis, width: calloutView.frame.size.width, height: 0)
        appDelegate.window?.addSubview(calloutView)
        
        
        notificationBackgroundView.removeFromSuperview()
        notificationBackgroundView.setTranslatesAutoresizingMaskIntoConstraints(true)
        notificationBackgroundView.frame = CGRect(x: 18.0, y: calloutViewYAxis, width: notificationBackgroundView.frame.size.width, height: 0)
        appDelegate.window?.addSubview(notificationBackgroundView)
        notificationBackgroundView.backgroundColor = UIColor.clearColor()
        notificationBackgroundView.hidden=true
        notificationTableView.layer.borderWidth = 0.5
        notificationTableView.layer.borderColor = UIColor.lightGrayColor().CGColor
        sendRequestForProfile()
        appDelegate.sendRequestToGetConfig()
    }
    
    override func viewWillDisappear(animated: Bool) {
        calloutView.removeFromSuperview()
        calloutView.frame = CGRect(x: 0.0, y: -17.0, width: calloutView.frame.size.width, height: 0)
        self.view.addSubview(calloutView)
       
        notificationBackgroundView.removeFromSuperview()
        notificationBackgroundView.frame = CGRect(x: 18.0, y: -17.0, width: notificationBackgroundView.frame.size.width, height: 0)
        self.view.addSubview(notificationBackgroundView)
    }
    
    override func viewDidLayoutSubviews() {
        if IS_IPHONE4S || IS_IPHONE5 {
            contentScrollView.contentSize = CGSize(width: contentScrollView.frame.size.width, height: 560.0)
        } else {
            contentScrollView.contentSize = CGSize(width: contentScrollView.frame.size.width, height: contentScrollView.frame.size.height)
        }
    }
    
    @IBAction func moreButtonClicked(sender: UIButton) {
        moreButton.selected = !moreButton.selected
        if moreButton.selected == true {
            timeCollectionViewWidthConstraint.constant = availableTimeView.frame.size.width
            availableTimeCollectionView.scrollEnabled  = true
        } else {
            timeCollectionViewWidthConstraint.constant = 190
            availableTimeCollectionView.contentOffset  = CGPoint(x: 0.0, y: 0.0)
            availableTimeCollectionView.scrollEnabled  = false
        }
        view.layoutIfNeeded()
    }
    
    @IBAction func badgePrevButtonClicked(sender: UIButton) {
        badgeNextButton.enabled = true
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.badgesCollectionView.contentOffset.x = self.badgesCollectionView.contentOffset.x-self.badgesCollectionView.frame.size.width
            }, completion: nil)
        if badgesCollectionView.contentOffset.x == 0.0 {
            badgePrevButton.enabled = false
        }
    }
    
    @IBAction func badgeNextButtonClicked(sender: UIButton) {
        badgePrevButton.enabled = true
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.badgesCollectionView.contentOffset.x = self.badgesCollectionView.contentOffset.x+self.badgesCollectionView.frame.size.width
            }, completion: nil)
        if badgesCollectionView.contentOffset.x > badgesCollectionView.contentSize.width-badgesCollectionView.frame.size.width {
            badgeNextButton.enabled = false
        }
    }
    
    @IBAction func favoriteButtonClicked(sender: UIButton) {
        sender.selected = !sender.selected
        sendRequestToManageFavorite(Int(sender.selected))
    }
    
    @IBAction func editButtonClicked(sender: UIButton) {
        performSegueWithIdentifier("segueToEditProfile", sender: self)
    }
    
    @IBAction func beginnerButtonClicked(sender: UIButton) {
        Globals.selectButton([beginnerButton, moderateButton, expertButton], selectButton: beginnerButton)
        beginnerButton.selected == true ? setExpertiseLevel(SportsLevel.beginner) : setExpertiseLevel("")
    }
    
    @IBAction func moderateButtonClicked(sender: UIButton) {
        Globals.selectButton([beginnerButton, moderateButton, expertButton], selectButton: moderateButton)
        moderateButton.selected == true ? setExpertiseLevel(SportsLevel.moderate) : setExpertiseLevel("")
    }
    
    @IBAction func expertButtonClicked(sender: UIButton) {
        Globals.selectButton([beginnerButton, moderateButton, expertButton], selectButton: expertButton)
        expertButton.selected == true ? setExpertiseLevel(SportsLevel.expert) : setExpertiseLevel("")
    }
    
    @IBAction func logoutButtonClicked(sender: UIButton) {
        UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.calloutView.frame = CGRect(x: 0.0, y: self.calloutViewYAxis, width: self.calloutView.frame.size.width, height: 0)
            }, completion: nil)
        let alertController = UIAlertController(title: "", message: "Do you wish to logout?", preferredStyle: UIAlertControllerStyle.Alert)
        let noAction        = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(noAction)
        let yesAction       = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (yesAction) -> Void in
            CustomURLConnection(request: CustomURLConnection.createRequest(NSMutableDictionary(), methodName: "user/logout", requestType: HttpMethod.post), delegate: self, tag: Connection.logout)
        }
        alertController.addAction(yesAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func packagesButtonClicked(sender: AnyObject) {
        performSegueWithIdentifier("segueToPackages", sender: self)
    }
    
    @IBAction func reviewBackButtonClicked(sender: UIButton) {
        reviewNextButton.enabled = true
        let currentIndexPath:Int = Int(reviewCollectionView.contentOffset.x/reviewCollectionView.frame.size.width)
        reviewCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: currentIndexPath-1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
        if currentIndexPath-1 == 0 {
            reviewBackButton.enabled = false
        }
    }
    
    @IBAction func reviewNextButtonClicked(sender: UIButton) {
        reviewBackButton.enabled = true
        let currentIndexPath:Int = Int(reviewCollectionView.contentOffset.x/reviewCollectionView.frame.size.width)
        reviewCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: currentIndexPath+1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
        if currentIndexPath+1 == reviewCollectionView.numberOfItemsInSection(0)-1 {
            reviewNextButton.enabled = false
        }
    }
    
    @IBAction func settingsButtonClicked(sender: UIButton) {
        if let id = profileID {
            navigationController?.popViewControllerAnimated(true)
            return
        }
        if calloutView.frame.size.height == 0 {
            if notificationBackgroundView.hidden == false {
                notificationButton.tag = 0
                UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.notificationBackgroundView.hidden  = true
                    }, completion: nil)
            }
            UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.calloutView.frame = CGRect(x: 0.0, y: self.calloutViewYAxis, width: self.calloutView.frame.size.width, height: 152.0)
                }, completion: nil)
        } else {
            UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.calloutView.frame = CGRect(x: 0.0, y: self.calloutViewYAxis, width: self.calloutView.frame.size.width, height: 0)
                }, completion: nil)
        }
    }
    
    @IBAction func notificationsButtonClicked(sender: UIButton) {
        if sender.tag == 0 {
            if calloutView.frame.size.height != 0 {
                UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.calloutView.frame = CGRect(x: 0.0, y: self.calloutViewYAxis, width: self.calloutView.frame.size.width, height: 0)
                    }, completion: nil)
            }
            sender.tag = 1
            notificationBackgroundView.hidden   = false
            UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.notificationBackgroundView.frame = CGRect(x: 18.0, y: 53, width: self.notificationBackgroundView.frame.size.width, height: 411.0)
                self.notificationTableView.reloadData()
            }, completion: nil)
            self.sendRequestForNotificationList()
        } else {
            sender.tag = 0
            UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.notificationBackgroundView.hidden  = true
            }, completion: nil)
        }
        
        if IS_IPHONE4S || IS_IPHONE5 {
            notificationArrowTrailingConstraint.constant = 16.0
            notificationBgtrailingConstraint.constant    = 2.0
            view.layoutIfNeeded()
        } else {
            notificationArrowTrailingConstraint.constant = -38.0
            notificationBgtrailingConstraint.constant    = -50.0
            view.layoutIfNeeded()
        }
    }
    
    @IBAction func bioLabelTapped(sender: UITapGestureRecognizer) {
        showBioView(appDelegate.user.bio!)
    }
    
    @IBAction func bookSessionTapped(sender: UITapGestureRecognizer) {
        if profileUser.availableTimeArray.count > 0 {
            performSegueWithIdentifier("pushToBookingSession", sender: self)
        } else {
            showDismissiveAlertMesssage("\(profileUser.name) have no available time")
        }
    }
    
    func populateProfileContents(user: User) {
        nameLabel.text = user.name
        favoriteButton.selected = user.isFavorite
        packagesButton.enabled = Bool(appDelegate.user.isVerified)
        if let id = profileID {
            if Bool(appDelegate.user.isVerified) == true {
                bookView.hidden = false
            } else {
                bookView.hidden = true
            }
        }
        userImageView.image = UIImage(named: "default_image")
        userImageView.contentMode = UIViewContentMode.ScaleAspectFit
        if let image = user.profileImage {
            userImageView.contentMode = UIViewContentMode.ScaleAspectFill
            userImageView.image = image
            indicatorView.stopAnimating()
            user.profileImage = nil
        } else if let url = user.imageURL {
            CustomURLConnection.downloadAndSetImage(url, imageView: userImageView, activityIndicatorView: indicatorView)
        } else {
            CustomURLConnection.downloadAndSetImage("", imageView: userImageView, activityIndicatorView: indicatorView)
        }
        
        if let bioText = user.bio {
            if count(bioText) > BIOTEXT_LENGTH {
                bioLabel.userInteractionEnabled = true
                Globals.attributedBioText((bioText as NSString).substringToIndex(BIOTEXT_LENGTH-1), lengthExceed: true, bioLabel: bioLabel)
            } else {
                bioLabel.userInteractionEnabled = false
                Globals.attributedBioText((bioText as NSString).substringToIndex((bioText as NSString).length), lengthExceed: false, bioLabel: bioLabel)
            }
        }
        if user.sportsArray.count == 0 {
            beginnerButton.superview?.superview?.hidden = true
        }
        sportsCarousel.currentItemIndex = 0
        sportsCarousel.reloadData()
        
        if let hours = user.totalHours {
            let components = hours.componentsSeparatedByString(":")
            let hour = components[0].toInt()!
            if hour < 2 {
                hoursLabel.textColor = AppColor.boxBorderColor
            } else if (hour>=2 && hour<5) {
                hoursLabel.textColor = AppColor.yellowTextColor
            } else if (hour>=5 && hour<10) {
                hoursLabel.textColor = AppColor.statusBarColor
            } else {
                hoursLabel.font = UIFont(name: "OpenSans-Bold", size: 16.0)
                hoursLabel.textColor = AppColor.badgeSilverColor
            }
            completedTitleLabel.textColor = hoursLabel.textColor
            hoursLabel.text = "\(hours) hours"
            
        } else {
            hoursLabel.text = "0 hours"
        }
        
        if let count = user.usageCount {
            sessionCountLabel.text = "\(count)"
        } else {
            sessionCountLabel.text = "0"
        }
        
        if let rate = user.rating {
            rateLabel.text  = rate
            starView.rating = (rate as NSString).floatValue
        } else {
            rateLabel.text  = "0"
            starView.rating = 0.0
        }
        
        let filteredArray = user.availableTimeArray.filteredArrayUsingPredicate(NSPredicate(format: "date = %@", argumentArray: [Globals.convertDate(NSDate())]))
        
        if filteredArray.count <= 3 {
            morebgView.hidden = true
            moreButton.hidden = true
        }
        if user.badgesArray.count <= 3 {
            badgeNextButton.hidden = true
            badgePrevButton.hidden = true
        } else {
            badgeNextButton.hidden = false
            badgePrevButton.hidden = false
        }
        if user.userReviewsArray.count <= 1 {
            buttonView.hidden = true
        } else {
            buttonView.hidden = false
        }
        
        if filteredArray.count == 0 {
            notimeLabel.hidden = false
            availableTimeCollectionView.hidden = true
        } else {
            availableTimeCollectionView.reloadData()
        }
        
        if user.badgesArray.count == 0 {
            noBadgeLabel.hidden = false
            badgesCollectionView.hidden = true
        } else {
            badgesCollectionView.reloadData()
        }
        
        if user.userReviewsArray.count == 0 {
            noreviewLabel.hidden = false
            reviewCollectionView.hidden = true
        } else {
            reviewCollectionView.reloadData()
        }
    }
    
    func showBioView(bioText: String) {
        let custompopController = storyboard?.instantiateViewControllerWithIdentifier("CustomPopupViewController") as! CustomPopupViewController
        custompopController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        custompopController.viewTag = ViewTag.bioText
        custompopController.bioText = bioText
        presentViewController(custompopController, animated: true, completion: nil)
    }
    
    
    //MARK: - NoticationList API
    func sendRequestForNotificationList() {
        if !Globals.isInternetConnected() {
            return
        }
        notifIndicatorView.startAnimating()
        let requestDictionary = NSMutableDictionary()
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "sessions/notification", requestType: HttpMethod.post), delegate: self, tag: Connection.notificationRequest)
    }
    
    //MARK: - Profile API
    
    func sendRequestForProfile() {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        if let id = profileID {
            requestDictionary.setObject(id.toInt()!, forKey: "user_id")
        }
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "profile/profile", requestType: HttpMethod.post), delegate: self, tag: Connection.userProfile)
    }
    
    func sendRequestForUpdateSportsLevel(sports: NSDictionary, type: String) {
        if !Globals.isInternetConnected() {
            return
        }
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(sports["sports_id"]!, forKey: "sports_id")
        requestDictionary.setObject(sports["expert_level"]!, forKey: "expert_level")
        requestDictionary.setObject(type, forKey: "type")
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "user/modifyUserSports", requestType: HttpMethod.post), delegate: self, tag: Connection.updateSports)
    }
    
    func sendRequestForUpdateNotifReadStatus(requestID: Int) {
        if !Globals.isInternetConnected() {
            return
        }
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(requestID, forKey: "request_id")
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "sessions/notificationRead", requestType: HttpMethod.post), delegate: self, tag: Connection.notifReadStatus)
    }
    
    func sendRequestToManageFavorite(favorite: Int) {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(favorite, forKey: "favorite")
        if let id = profileID {
            requestDictionary.setObject(id.toInt()!, forKey: "trainer_id")
        }
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "favourite/manage", requestType: HttpMethod.post), delegate: self, tag: Connection.unfavourite)
    }
    
    func parseProfileResponse(responseDictionary: NSDictionary) {
        
        println("Response Dictionary\(responseDictionary)")
        if let id = profileID {
            profileUser.profileID  = responseDictionary["profile_id"] as! Int
            profileUser.name       = responseDictionary["profile_name"] as! String
            profileUser.email      = responseDictionary["email"] as! String
            profileUser.isVerified = responseDictionary["user_verified"] as! Int
            profileUser.walletBalance = responseDictionary["wallet_balance"] as? String
            if let imageUrl = responseDictionary["profile_image"] as? String {
                profileUser.imageURL = imageUrl
            } else {
                profileUser.imageURL = ""
            }
            
            if let bio = responseDictionary["profile_desc"] as? String {
                profileUser.bio = bio
            }
            if let session = responseDictionary["Training_session"] as? NSArray {
                profileUser.availableTimeArray.removeAllObjects()
                profileUser.availableTimeArray.addObjectsFromArray(session as! [NSDictionary])
            }
            if let usageCount = responseDictionary["usage_count"] as? Int {
                profileUser.usageCount = usageCount
            }
            if let rate = responseDictionary["rating"] as? String {
                profileUser.rating = rate
            }
            if let badges = responseDictionary["Badges"] as? NSArray {
                profileUser.badgesArray.removeAllObjects()
                if profileUser.usageCount > 0 {
                    profileUser.badgesArray.addObjectsFromArray(badges as! [NSDictionary])
                }
            }
            if let comments = responseDictionary["User_comments"] as? NSArray {
                profileUser.userReviewsArray.removeAllObjects()
                profileUser.userReviewsArray.addObjectsFromArray(comments as! [NSDictionary])
            }
            
            if let hours = responseDictionary["weekly_hours"] as? String {
                profileUser.totalHours = hours
            }
            
            if let sportsArray = responseDictionary["Sports_list"] as? NSArray {
                profileUser.sportsArray.removeAllObjects()
                for sports in sportsArray {
                    let sport = NSMutableDictionary()
                    sport.setObject(sports["sports_id"] as! Int, forKey: "sports_id")
                    sport.setObject(sports["sport_name"] as! String, forKey: "sport_name")
                    let filteredArray = appDelegate.sportsArray.filteredArrayUsingPredicate(NSPredicate(format: "id = %d", argumentArray: [sports["sports_id"] as! Int]))
                    if filteredArray.count > 0 {
                        let mysport = filteredArray[0] as! NSDictionary
                        if let logo = mysport["logo"] as? String {
                            sport.setObject(logo, forKey: "logo")
                        } else {
                            sport.setObject("", forKey: "logo")
                        }
                    } else {
                        sport.setObject("", forKey: "logo")
                    }
                    sport.setObject(sports["expert_level"] as! String, forKey: "expert_level")
                    profileUser.sportsArray.addObject(sport)
                }
            }
            profileUser.isFavorite = responseDictionary["favourite"] as! Bool
        } else {
            appDelegate.user.profileID  = responseDictionary["profile_id"] as! Int
            appDelegate.user.name       = responseDictionary["profile_name"] as! String
            appDelegate.user.email      = responseDictionary["email"] as! String
            appDelegate.user.isVerified = responseDictionary["user_verified"] as! Int
            appDelegate.user.walletBalance = responseDictionary["wallet_balance"] as? String
            if let imageUrl = responseDictionary["profile_image"] as? String {
                appDelegate.user.imageURL = imageUrl
            } else {
                appDelegate.user.imageURL = ""
            }
            
            if let bio = responseDictionary["profile_desc"] as? String {
                appDelegate.user.bio = bio
                if bio == "" {
                    showBioView(bio)
                }
            } else {
                showBioView("")
            }
            if let session = responseDictionary["Training_session"] as? NSArray {
                appDelegate.user.availableTimeArray.removeAllObjects()
                appDelegate.user.availableTimeArray.addObjectsFromArray(session as! [NSDictionary])
            }
            if let usageCount = responseDictionary["usage_count"] as? Int {
                appDelegate.user.usageCount = usageCount
            }
            if let rate = responseDictionary["rating"] as? String {
                appDelegate.user.rating = rate
            }
            if let badges = responseDictionary["Badges"] as? NSArray {
                appDelegate.user.badgesArray.removeAllObjects()
                if appDelegate.user.usageCount > 0 {
                    appDelegate.user.badgesArray.addObjectsFromArray(badges as! [NSDictionary])
                }
            }
            if let comments = responseDictionary["User_comments"] as? NSArray {
                appDelegate.user.userReviewsArray.removeAllObjects()
                appDelegate.user.userReviewsArray.addObjectsFromArray(comments as! [NSDictionary])
            }
            
            if let hours = responseDictionary["weekly_hours"] as? String {
                appDelegate.user.totalHours = hours
            }
            
            if let sportsArray = responseDictionary["Sports_list"] as? NSArray {
                appDelegate.user.sportsArray.removeAllObjects()
                for sports in sportsArray {
                    let sport = NSMutableDictionary()
                    sport.setObject(sports["sports_id"] as! Int, forKey: "sports_id")
                    sport.setObject(sports["sport_name"] as! String, forKey: "sport_name")
                    let filteredArray = appDelegate.sportsArray.filteredArrayUsingPredicate(NSPredicate(format: "id = %d", argumentArray: [sports["sports_id"] as! Int]))
                    if filteredArray.count > 0 {
                        let mysport = filteredArray[0] as! NSDictionary
                        if let logo = mysport["logo"] as? String {
                            sport.setObject(logo, forKey: "logo")
                        } else {
                            sport.setObject("", forKey: "logo")
                        }
                    } else {
                        sport.setObject("", forKey: "logo")
                    }
                    sport.setObject(sports["expert_level"] as! String, forKey: "expert_level")
                    appDelegate.user.sportsArray.addObject(sport)
                }
                for sports in appDelegate.sportsArray {
                    if sportsArray.valueForKey("sports_id")!.containsObject(sports["id"] as! Int) {
                    } else {
                        let sport = NSMutableDictionary()
                        sport.setObject(sports["id"] as! Int, forKey: "sports_id")
                        sport.setObject(sports["title"] as! String, forKey: "sport_name")
                        if let logo = sports["logo"] as? String {
                            sport.setObject(logo, forKey: "logo")
                        } else {
                            sport.setObject("", forKey: "logo")
                        }
                        sport.setObject("", forKey: "expert_level")
                        appDelegate.user.sportsArray.addObject(sport)
                    }
                }
           }
        }
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
                if connection.connectionTag == Connection.userProfile {
                    if status == ResponseStatus.success {
                        parseProfileResponse(jsonResult)
                    } else if status == ResponseStatus.error {
                        if let message = jsonResult["message"] as? String {
                            showDismissiveAlertMesssage(message)
                        } else {
                            showDismissiveAlertMesssage(Message.Error)
                        }
                    } else {
                        showLoadingView(false)
                        dismissOnSessionExpire()
                        return
                    }
                    if let id = profileID {
                        populateProfileContents(profileUser)
                    } else {
                        populateProfileContents(appDelegate.user)
                    }
                } else if connection.connectionTag == Connection.logout {
                    if status == ResponseStatus.error {
                        if let message = jsonResult["message"] as? String {
                            showDismissiveAlertMesssage(message)
                        } else {
                            showDismissiveAlertMesssage(Message.Error)
                        }
                    } else {
                        Globals.clearSession()
                        (self.presentingViewController as! UINavigationController).popToRootViewControllerAnimated(true)
                        dismissViewControllerAnimated(true, completion: nil)
                    }
                } else if connection.connectionTag == Connection.updateSports {
                    if status == ResponseStatus.sessionOut {
                        dismissOnSessionExpire()
                    }
                } else if connection.connectionTag == Connection.unfavourite {
                    if status == ResponseStatus.success {
                        profileUser.isFavorite = favoriteButton.selected
                        NSNotificationCenter.defaultCenter().postNotificationName(PushNotification.favNotif, object: nil, userInfo: ["user" : profileUser])
                    } else if status == ResponseStatus.error {
                        if let message = jsonResult["message"] as? String {
                            showDismissiveAlertMesssage(message)
                        } else {
                            showDismissiveAlertMesssage(Message.Error)
                        }
                        favoriteButton.selected = !favoriteButton.selected
                    } else {
                        dismissOnSessionExpire()
                    }
                }  else if connection.connectionTag == Connection.notificationRequest {
                    if status == ResponseStatus.success {
                        if let notifications = jsonResult["data"] as? NSArray {
                            self.notificationListArray = notifications as! Array
                            notificationTableView.reloadData()
                        }
                    } else if status == ResponseStatus.error {
                        if let message = jsonResult["message"] as? String {
                            showDismissiveAlertMesssage(message)
                        } else {
                            showDismissiveAlertMesssage(Message.Error)
                        }
                        favoriteButton.selected = !favoriteButton.selected
                    } else {
                        dismissOnSessionExpire()
                    }
                    notifIndicatorView.stopAnimating()
                } else if connection.connectionTag == Connection.notifReadStatus {
                    if status == ResponseStatus.success {
                        
                    }
                }
            }
        }
        showLoadingView(false)
    }
    
    func connection(connection: CustomURLConnection, didFailWithError error: NSError) {
        showDismissiveAlertMesssage(error.localizedDescription)
        if let id = profileID {
            populateProfileContents(profileUser)
        } else {
            populateProfileContents(appDelegate.user)
        }
        showLoadingView(false)
    }
    
    func setExpertiseLevel(level: String) {
        let sports  = appDelegate.user.sportsArray[sportsCarousel.currentItemIndex] as? NSMutableDictionary
        var type    = ""
        if count(sports!["expert_level"] as! String) == 0 && count(level) > 0 {
            type = SportsLevel.typeAdd
        } else if count(sports!["expert_level"] as! String) > 0 && count(level) > 0 {
            type = SportsLevel.typeUpdate
        } else if count(sports!["expert_level"] as! String) > 0 && count(level) == 0 {
            type = SportsLevel.typeDelete
        }
        sports!.setObject(level, forKey: "expert_level")
        sendRequestForUpdateSportsLevel(sports!, type: type)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "pushToBookingSession" {
            let bookViewController = segue.destinationViewController as! BookingSessionViewController
            bookViewController.user = profileUser
            if let id = searchResultId {
                bookViewController.searchResultId = searchResultId
            }
        }
    }
}


extension MyProfileViewController: iCarouselDataSource {
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
       return profileID == nil ? appDelegate.user.sportsArray.count : profileUser.sportsArray.count
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
            titleLabel.textColor = UIColor.whiteColor()
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
        let source          = profileID == nil ? appDelegate.user.sportsArray : profileUser.sportsArray
        let sports          = source[index] as! NSDictionary
        sportsImageView.image = UIImage(named: "default_image")
        sportsImageView.contentMode = UIViewContentMode.ScaleAspectFit
        if let logo = sports["logo"] as? String {
            CustomURLConnection.downloadAndSetImage(logo, imageView: sportsImageView, activityIndicatorView: indicatorView)
        } else {
            CustomURLConnection.downloadAndSetImage("", imageView: sportsImageView, activityIndicatorView: indicatorView)
        }
        if index == carousel.currentItemIndex {
            titleLabel.text = sports["sport_name"]!.uppercaseString as String
            if profileID == nil {
                if sports["expert_level"] as? String == SportsLevel.beginner {
                    beginnerButton.selected = true
                } else if sports["expert_level"] as? String == SportsLevel.moderate {
                    moderateButton.selected = true
                } else if sports["expert_level"] as? String == SportsLevel.expert {
                    expertButton.selected = true
                }
            } else {
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
            }
        } else {
            titleLabel.text = sports["sport_name"] as? String
        }
        return contentView
    }
}

extension MyProfileViewController: iCarouselDelegate {
    func carousel(carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        let centerItemZoom: CGFloat = 1.5
        let centerItemSpacing: CGFloat = 1.3
        
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
        beginnerButton.selected = false
        moderateButton.selected = false
        expertButton.selected   = false
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

extension MyProfileViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.isEqual(reviewCollectionView) {
            return profileID == nil ? appDelegate.user.userReviewsArray.count : profileUser.userReviewsArray.count
        } else if collectionView.isEqual(badgesCollectionView) {
            return profileID == nil ? appDelegate.user.badgesArray.count : profileUser.badgesArray.count
        }
        let source = profileID == nil ? appDelegate.user.availableTimeArray : profileUser.availableTimeArray
        let filteredArray = source.filteredArrayUsingPredicate(NSPredicate(format: "date = %@", argumentArray: [Globals.convertDate(NSDate())]))
        return filteredArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView.isEqual(reviewCollectionView) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("reviewCell", forIndexPath: indexPath) as! UserReviewCollectionViewCell
            let source = profileID == nil ? appDelegate.user.userReviewsArray : profileUser.userReviewsArray
            let review = source[indexPath.row] as! NSDictionary
            if let rating = review["user_rating"] as? Float {
                cell.reviewView.starView.rating = rating
            } else {
                cell.reviewView.starView.rating = 0.0
            }
            cell.reviewView.reviewTextView.scrollRangeToVisible(NSMakeRange(0, 0))
            cell.reviewView.reviewTextView.text = review["user_review"] as! String
            cell.reviewView.nameLabel.text      = review["profile_name"] as? String
            cell.reviewView.userImageView.backgroundColor = AppColor.statusBarColor
            cell.reviewView.userImageView.image = UIImage(named: "default_image")
            cell.reviewView.userImageView.contentMode = UIViewContentMode.ScaleAspectFit
            if let userImage = review["image_url"] as? String {
                CustomURLConnection.downloadAndSetImage(userImage, imageView: cell.reviewView.userImageView, activityIndicatorView: cell.reviewView.indicatorView)
            } else {
                CustomURLConnection.downloadAndSetImage("", imageView: cell.reviewView.userImageView, activityIndicatorView: cell.reviewView.indicatorView)
            }
            return cell
        } else if collectionView.isEqual(badgesCollectionView){
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("badgeCell", forIndexPath: indexPath) as! BadgesCollectionViewCell
            let source = profileID == nil ? appDelegate.user.badgesArray : profileUser.badgesArray
            let badge = source[indexPath.row] as! NSDictionary
            cell.titleLabel.hidden = (badge["name"] as? String) == "no badge" ? true : false
            cell.titleLabel.text = (badge["name"] as? String)!.uppercaseString
            cell.badgeImageView.image = UIImage(named: "default_image")
            cell.badgeImageView.contentMode = UIViewContentMode.ScaleAspectFit
            if let badgeImage = badge["image_url"] as? String {
                CustomURLConnection.downloadAndSetImage(badgeImage, imageView: cell.badgeImageView, activityIndicatorView: cell.indicatorView)
            } else {
                CustomURLConnection.downloadAndSetImage("", imageView: cell.badgeImageView, activityIndicatorView: cell.indicatorView)
            }
            if let count = badge["session_count"] as? Int {
                cell.countLabel.text = "\(count)"
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("timeCell", forIndexPath: indexPath) as! AvailableTimeCollectionViewCell
            let source = profileID == nil ? appDelegate.user.availableTimeArray : profileUser.availableTimeArray
            let filteredArray = source.filteredArrayUsingPredicate(NSPredicate(format: "date = %@", argumentArray: [Globals.convertDate(NSDate())]))
            let time = filteredArray[indexPath.row] as! NSDictionary
            cell.timeLabel.text = Globals.convertTimeTo12Hours((time["time_starts"] as? String)!)
            return cell
        }
    }
}

extension MyProfileViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //To activate/deactivate time
//        if collectionView.isEqual(availableTimeCollectionView) {
//            let custompopController = storyboard?.instantiateViewControllerWithIdentifier("CustomPopupViewController") as! CustomPopupViewController
//            custompopController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
//            custompopController.viewTag = ViewTag.timeView
//            let source = profileID == nil ? appDelegate.user.availableTimeArray : profileUser.availableTimeArray
//            custompopController.timeDictionary = source[indexPath.row] as? NSDictionary
//            presentViewController(custompopController, animated: true, completion: nil)
//        }

    }
}

extension MyProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView.isEqual(reviewCollectionView) {
            return collectionView.frame.size
        } else if collectionView.isEqual(availableTimeCollectionView) {
            return CGSize(width: 60.0, height: 22.0)
        }
        return CGSize(width: 65.0, height: 75.0)
    }
}


extension MyProfileViewController : UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationListArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NotificationCell
        var imageUrl:String
        cell.roundLabel.layer.cornerRadius  = 10.0
        cell.roundLabel.layer.borderColor   = UIColor.clearColor().CGColor
        cell.roundLabel.clipsToBounds       = true
        cell.profilePic.layer.cornerRadius  = 25.0
        cell.profilePic.layer.borderColor   = UIColor.clearColor().CGColor
        cell.profilePic.clipsToBounds       = true
        let readStatus                      = notificationListArray[indexPath.row].objectForKey("read_status") as! Int
        if  readStatus == 0{
            cell.roundLabel.backgroundColor = AppColor.boxBorderColor
        } else {
            cell.roundLabel.backgroundColor = AppColor.notifReadColor
        }
        
        if notificationListArray[indexPath.row].objectForKey("type") as! String == TrainingStatus.requested {
            imageUrl = notificationListArray[indexPath.row].objectForKey("user_image") as! String
            cell.nameLabel.text = self.notificationListArray[indexPath.row].objectForKey("user_name") as? String
            cell.bodyLabel.text = "has requested for Sports"
        } else {
            imageUrl = notificationListArray[indexPath.row].objectForKey("trainer_image") as! String
            cell.nameLabel.text = self.notificationListArray[indexPath.row].objectForKey("trainer_name") as? String
            cell.bodyLabel.text = "has accepted your booking request"
        }
        cell.profilePic.image = UIImage(named: "default_image")
        cell.profilePic.contentMode = UIViewContentMode.ScaleAspectFit
        let imageurl = SERVER_URL.stringByAppendingString(imageUrl as String) as NSString
        if imageurl.length != 0 {
            if var imagesArray = Images.fetch(imageUrl as String) {
                let image      = imagesArray[0] as! Images
                let coverImage = UIImage(data: image.imageData)!
                cell.profilePic.contentMode = UIViewContentMode.ScaleAspectFill
                cell.profilePic.image = UIImage(data: image.imageData)!
                cell.indicatorView.stopAnimating()
            } else {
                if let imageURL = NSURL(string: imageurl as String){
                    let request  = NSURLRequest(URL: imageURL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: TimeOut.Image)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                        if let updatedCell = tableView.cellForRowAtIndexPath(indexPath) as? NotificationCell {
                            if error == nil {
                                let imageFromData:UIImage? = UIImage(data: data)
                                if let image  = imageFromData {
                                    updatedCell.profilePic.contentMode = UIViewContentMode.ScaleAspectFill
                                    updatedCell.profilePic.image = image
                                    Images.save(imageurl as String, imageData: data)
                                }
                            }
                            updatedCell.indicatorView.stopAnimating()
                        }
                        cell.indicatorView.stopAnimating()
                    }
                } else {
                    cell.indicatorView.stopAnimating()
                }
            }
        } else {
            cell.indicatorView.stopAnimating()
        }

        return cell
    }
}

extension MyProfileViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if notificationListArray[indexPath.row].objectForKey("read_status") as! Int == 0 {
            sendRequestForUpdateNotifReadStatus(notificationListArray[indexPath.row].objectForKey("request_id") as! Int)
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! NotificationCell
            cell.roundLabel.backgroundColor = AppColor.notifReadColor
        }
        if notificationListArray[indexPath.row].objectForKey("type") as! String == TrainingStatus.requested {
            let controller  = storyboard?.instantiateViewControllerWithIdentifier("BookingRequestViewController") as! BookingRequestViewController
            controller.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            controller.notificationDictionary = notificationListArray[indexPath.row] as! NSMutableDictionary
            presentViewController(controller, animated: true, completion: nil)
            notificationBackgroundView.hidden = true
        } //else {
//            let controller  = storyboard?.instantiateViewControllerWithIdentifier("SessionTimerViewController") as! SessionTimerViewController
//            controller.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
//            controller.sessionDictionary      = notificationListArray[indexPath.row] as NSDictionary
//            presentViewController(controller, animated: true, completion: nil)
//        }
        
    }
}
