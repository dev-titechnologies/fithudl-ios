//
//  MyProfileViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 28/09/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit
import CoreData

class AvailableTimeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
}

class MyProfileViewController: UIViewController, UIGestureRecognizerDelegate {

    var StripeFlag: NSString = ""
    var stripeVerifyString : NSString = ""
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
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var expertLevelLabel: UILabel!
    @IBOutlet weak var NotificationView: UIView!
    @IBOutlet weak var notificationBackgroundView: UIView!
    
    @IBOutlet weak var notificationBgtrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var notificationArrowTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var availBalanceLabel: UILabel!
   
    @IBOutlet weak var scrollContentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var notifIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var packagesButton: UIButton!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var carouselBackgroundHeight: NSLayoutConstraint!
    @IBOutlet weak var notificationTableView: UITableView!
    @IBOutlet weak var carouselBackgoundView: UIView!
    @IBOutlet weak var interestLabel: UILabel!
    var filterTimeArray = NSArray()
    var tempFilterTimeArray = NSArray()
    var searchResultId:String?
    var profileID: String?
    let calloutViewYAxis:CGFloat = 52.0
    var profileUser: User?
    var notificationListArray =  Array<Notification>()
    var profileImage: NSData? = nil
    var label : UILabel?
    var notificationCountLabel: UILabel!
    var timer = NSTimer()
    
    @IBAction func infoButtonAction(sender: AnyObject) {
        let controller  = storyboard?.instantiateViewControllerWithIdentifier("IntroViewController") as! IntroViewController
        controller.getredyButtonFlag = 1
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let custompopController = storyboard?.instantiateViewControllerWithIdentifier("OverlayViewController") as! OverlayViewController
//        custompopController.controllerFlag = 1
//        presentViewController(custompopController, animated: true, completion: nil)
        
        
        println("MY PROFILE")
        menuView.hidden = true
        var nib = UINib(nibName: "UserReviewCollectionViewCell", bundle: nil)
        reviewCollectionView.registerNib(nib, forCellWithReuseIdentifier: "reviewCell")
        
        nib = UINib(nibName: "MedalCollectionViewCell", bundle: nil)
        badgesCollectionView.registerNib(nib, forCellWithReuseIdentifier: "MedalCell")
        
        
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
        
        userImageView.layer.borderColor = UIColor(red: 0, green: 150/255, blue: 136/255, alpha: 1.0).CGColor
        userImageView.layer.borderWidth = 1.0
        
//        if let id = searchResultId {
//        scrollViewBottomConstraint.constant = -65
//        carouselBackgroundView.constant     = 226.0
//        view.layoutIfNeeded()
//        }
        
        
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: navigationBar.frame.width-28, y: 0, width: 20, height: 20)
            
            notificationCountLabel = UILabel(frame: firstFrame)
            notificationCountLabel.layer.cornerRadius = 10.0
            notificationCountLabel.layer.borderColor = UIColor.clearColor().CGColor
            notificationCountLabel.clipsToBounds = true
            notificationCountLabel.text = ""
            notificationCountLabel.textAlignment = NSTextAlignment.Center
            notificationCountLabel.textColor = UIColor.whiteColor()
            notificationCountLabel.backgroundColor = UIColor.redColor()
            notificationCountLabel.font = UIFont(name: "OpenSans", size: 9)
            self.notificationCountLabel.hidden = true
            navigationBar.addSubview(notificationCountLabel)
        }

        if IS_IPHONE6PLUS {
            
            profileViewHeightConstraint.constant = 260.0
            reviewTopConstraint.constant         = 30.0
            reviewBottomConstraint.constant      = 30.0
            view.layoutIfNeeded()
        }
    
        if let id = profileID {
            
<<<<<<< HEAD
            notificationCountLabel.hidden = true
=======
>>>>>>> 97574d3d8b8d17cf182d45352b06f5b4dc419d40
            favoriteButton.hidden      = false
            completedTitleLabel.hidden = true
            hoursLabel.hidden          = true
            editButton.hidden          = true
            beginnerButton.superview?.hidden    = true
            expertLevelLabel.superview?.hidden  = false
            notificationButton.hidden  = false
            notificationButton .setImage(UIImage(named:"spam.png"), forState: UIControlState.Normal)
            settingsButton.setImage(UIImage(named: "back_button"), forState: UIControlState.Normal)
        }
        
        beginnerButton.selected = false
        moderateButton.selected = false
        expertButton.selected   = false
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "viewTap:")
        tapGesture.delegate = self
        self.notificationBackgroundView.addGestureRecognizer(tapGesture)
        
        var tapGestureView = UITapGestureRecognizer(target: self, action: "viewTap:")
        tapGestureView.delegate = self
        self.view.addGestureRecognizer(tapGestureView)
        
        var tapGesturecarousel = UITapGestureRecognizer(target: self, action: "viewTap:")
        tapGesturecarousel.delegate = self
        self.carouselBackgoundView.addGestureRecognizer(tapGesturecarousel)
        
        self.sportsCarousel.userInteractionEnabled = true
        var tapGesturesportscarousel = UITapGestureRecognizer(target: self, action: "viewTap:")
        tapGesturesportscarousel.delegate = self
        tapGesturesportscarousel.cancelsTouchesInView = false
        self.sportsCarousel.addGestureRecognizer(tapGesturesportscarousel)
        
        
       label = UILabel(frame: CGRectMake(0, notificationTableView.frame.size.height/2-21, notificationTableView.frame.size.width, 21))
        //label.center = CGPointMake(160, 284)
        label!.textAlignment = NSTextAlignment.Center
        label!.text = "You have no notifications!"
        label!.textColor = UIColor.lightGrayColor()
        label!.backgroundColor = UIColor.clearColor()
        notificationTableView.addSubview(label!)
        label?.hidden = true
        
        
        
        
    }
    
     func viewTap(getstureRecognizer : UITapGestureRecognizer){
        if menuView.frame.origin.x == 0 {
            hideMenuView()
        }
        notificationButton.tag = 0
        UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.notificationBackgroundView.hidden  = true
        }, completion: nil)
        println("self.view touched")
    }
    
    override func viewWillAppear(animated: Bool) {
        println(self.presentedViewController)
        println(self.presentingViewController)
        if let presentedController = self.presentedViewController {
            if presentedController.isKindOfClass(PromoCodeViewController) {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "termsChanged", name: "TermsChange", object: nil)
                return
            }
        }
        appDelegate.sendRequestToGetConfig()
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
        menuView.setTranslatesAutoresizingMaskIntoConstraints(true)
        notificationButton.tag      = 0
        notificationBackgroundView.removeFromSuperview()
        notificationBackgroundView.setTranslatesAutoresizingMaskIntoConstraints(true)
        notificationBackgroundView.frame = CGRect(x: (view.frame.size.width-notificationBackgroundView.frame.size.width), y: calloutViewYAxis, width: notificationBackgroundView.frame.size.width, height: 0)
        appDelegate.window?.addSubview(notificationBackgroundView)
        notificationBackgroundView.backgroundColor = UIColor.clearColor()
        notificationBackgroundView.hidden       = true
        notificationTableView.layer.borderWidth = 0.5
        notificationTableView.layer.borderColor = UIColor.lightGrayColor().CGColor
       
        if let id = profileID {
            if let currentUser = appDelegate.user {
                if currentUser.sports.count > 0 {
                    var sportsList      = currentUser.sports.allObjects as! [UserSports]
                    currentUser.sports  = NSMutableSet(array: (sportsList as NSArray).sortedArrayUsingDescriptors([NSSortDescriptor(key: "expertLevel.length", ascending: false)]))
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "termsChanged", name: "TermsChange", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "StopTimer", name: "InvalidateTimer", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        
        let profileFlag = NSUserDefaults.standardUserDefaults().valueForKey("profileIntroFlag") as? String
        if profileFlag != "1"{
            NSUserDefaults.standardUserDefaults().setValue("1", forKey: "profileIntroFlag")
            let custompopController = storyboard?.instantiateViewControllerWithIdentifier("OverlayViewController") as! OverlayViewController
            custompopController.controllerFlag = 1
            presentViewController(custompopController, animated: true, completion: nil)
            
        } else {
            
            //navigationController?.navigationBar.hidden = false
        }

        
         self.sendRequestToGetNotificationCount()
         sendRequestForProfile()
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector:"sendRequestToGetNotificationCount", userInfo: nil, repeats: true)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        
         notificationCountLabel.hidden = true
        
    }
    
    func StopTimer(){
        
        println("INVAlidasteeeee")
        
        timer.invalidate()
    }
    
    func termsChanged() {
        if let currentUser = appDelegate.user {
            let terms = currentUser.termsStatus.integerValue
            if let change = appDelegate.configDictionary["GENERAL_CMS_AMENDMENT"] as? String {
                if terms == 0 && change.toInt()! == 1 {
                    showContentChangeView()
                }
            }
        }
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        println("touch view is \(touch.view)")
        println("touch superview is \(touch.view.superview)")
        if touch.view.superview is UITableViewCell {
            return false
        }
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let loadView = view.viewWithTag(999) {
            showLoadingView(false)
        }
        self.hideMenuView()
        notificationBackgroundView.removeFromSuperview()
        notificationBackgroundView.frame = CGRect(x: 0.0, y: -17.0, width: notificationBackgroundView.frame.size.width, height: 0)
        self.view.addSubview(notificationBackgroundView)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "TermsChange", object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        if IS_IPHONE4S || IS_IPHONE5 {
            contentScrollView.contentSize = CGSize(width: contentScrollView.frame.size.width, height: 560.0)
        } else {
            contentScrollView.contentSize = CGSize(width: contentScrollView.frame.size.width, height: contentScrollView.frame.size.height)
            scrollContentHeightConstraint.constant = view.frame.size.height
            carouselBackgroundHeight.constant      = carouselBackgroundHeight.constant+40.0
            view.layoutIfNeeded()
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
        
        if menuView.frame.origin.x == 0 {
            hideMenuView()
        }

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
        UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.menuView.frame = CGRect(x: -self.menuView.frame.size.width, y: 0.0, width: self.menuView.frame.size.width, height: self.menuView.frame.size.height)
            }, completion: nil)
        let alertController = UIAlertController(title: "", message: "Do you wish to logout?", preferredStyle: UIAlertControllerStyle.Alert)
        let noAction        = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(noAction)
        let yesAction       = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (yesAction) -> Void in
            self.showLoadingView(true)
            CustomURLConnection(request: CustomURLConnection.createRequest(NSMutableDictionary(), methodName: "user/logout", requestType: HttpMethod.post), delegate: self, tag: Connection.logout)
        }
        alertController.addAction(yesAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func packagesButtonClicked(sender: AnyObject) {
        hideMenuView()
        performSegueWithIdentifier("segueToPackages", sender: self)
    }
    
    @IBAction func promotionsButtonClicked(sender: UIButton) {
        hideMenuView()
        let promoViewController                    = storyboard?.instantiateViewControllerWithIdentifier("PromoCodeViewController") as! PromoCodeViewController
        promoViewController.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        promoViewController.viewTag                = ViewTag.promoDisplayView
        presentViewController(promoViewController, animated: true, completion: nil)
    }
    
    @IBAction func changePasswordClicked(sender: UIButton) {
        hideMenuView()
        let feedNavigationController = storyboard?.instantiateViewControllerWithIdentifier("ChangeNavigationController") as! UINavigationController
        presentViewController(feedNavigationController, animated: true, completion: nil)
    }
    
    @IBAction func feedbackButtonClicked(sender: UIButton) {
        hideMenuView()
        let feedNavigationController = storyboard?.instantiateViewControllerWithIdentifier("FeedbackNavigationController") as! UINavigationController
        presentViewController(feedNavigationController, animated: true, completion: nil)
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
        if menuView.frame.origin.x != 0 {
            menuView.hidden = false
            if notificationBackgroundView.hidden == false {
                notificationButton.tag = 0
                UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.notificationBackgroundView.hidden  = true
                    }, completion: nil)
            }
            UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                self.menuView.frame = CGRect(x: 0.0, y: 0.0, width: self.menuView.frame.size.width, height: self.menuView.frame.size.height)
                }, completion: nil)
        } else {
            UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                self.menuView.frame = CGRect(x: -self.menuView.frame.size.width, y: 0.0, width: self.menuView.frame.size.width, height: self.menuView.frame.size.height)
                }, completion: nil)
        }
    }
    
    @IBAction func notificationsButtonClicked(sender: UIButton) {
        
        if let id = profileID {
            
            let controller  = storyboard?.instantiateViewControllerWithIdentifier("ReportViewController") as! ReportViewController
            self.definesPresentationContext   = true
            controller.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            controller.ProfileIDOtherUser = profileID!
            presentViewController(controller, animated: true, completion: nil)
            
        } else {
            
            self.notificationTableView.contentOffset = CGPointZero
            if sender.tag == 0 {
<<<<<<< HEAD
                 let profileFlag = NSUserDefaults.standardUserDefaults().valueForKey("notifIntroFlag") as? String
                    if profileFlag != "1"{
                        NSUserDefaults.standardUserDefaults().setValue("1", forKey: "notifIntroFlag")
                        let custompopController = storyboard?.instantiateViewControllerWithIdentifier("OverlayViewController") as! OverlayViewController
                        custompopController.controllerFlag = 6
                        presentViewController(custompopController, animated: true, completion: nil)
                    } else {
                        
                        if menuView.frame.origin.x == 0 {
                            hideMenuView()
                        }
                        sender.tag = 1
                        notificationBackgroundView.hidden   = false
                        UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                            self.notificationBackgroundView.frame = CGRect(x: (self.view.frame.size.width-self.notificationBackgroundView.frame.size.width), y: self.calloutViewYAxis, width: self.notificationBackgroundView.frame.size.width, height: 700)
                            self.notificationTableView.reloadData()
                            }, completion: nil)
                        self.sendRequestForNotificationList()
                        
                }
                
=======
                if menuView.frame.origin.x == 0 {
                    hideMenuView()
                }
                sender.tag = 1
                notificationBackgroundView.hidden   = false
                UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.notificationBackgroundView.frame = CGRect(x: (self.view.frame.size.width-self.notificationBackgroundView.frame.size.width), y: self.calloutViewYAxis, width: self.notificationBackgroundView.frame.size.width, height: 700)
                    self.notificationTableView.reloadData()
                    }, completion: nil)
                self.sendRequestForNotificationList()
>>>>>>> 97574d3d8b8d17cf182d45352b06f5b4dc419d40
            } else {
                sender.tag = 0
                UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.notificationBackgroundView.hidden   = true
                    }, completion: nil)
            }
            
        }
        
    }
    
    @IBAction func bioLabelTapped(sender: UITapGestureRecognizer) {
        if let id = profileID {
            showBioView(profileUser!.bio)
        } else {
            showBioView(appDelegate.user!.bio)
        }
    }
    @IBAction func bookSessionTapped(sender: UITapGestureRecognizer) {
        if profileUser!.availableTime.count > 0 {
            performSegueWithIdentifier("pushToBookingSession", sender: self)
        } else {
            showDismissiveAlertMesssage("\(profileUser!.name) has no available time.")
        }
    }
    func populateProfileContents(user: User) {
        nameLabel.text = user.name
        favoriteButton.selected = user.isFavorite.boolValue
        packagesButton.enabled = Bool(appDelegate.user!.userVerified.boolValue)
        if let id = profileID {
            if appDelegate.user!.userVerified.boolValue == true {
                bookView.hidden = false
            } else {
                bookView.hidden = true
            }
        }
        userImageView.image = UIImage(named: "default_image")
        userImageView.contentMode = UIViewContentMode.ScaleAspectFit
        if user.profileImage.length != 0 {
            userImageView.contentMode = UIViewContentMode.ScaleAspectFill
            userImageView.image       = UIImage(data: user.profileImage)
            indicatorView.stopAnimating()
            user.profileImage = NSData()
        } else {
            CustomURLConnection.downloadAndSetImage(user.imageURL, imageView: userImageView, activityIndicatorView: indicatorView)
        }
        
        if count(user.bio) > BIOTEXT_LENGTH {
            bioLabel.userInteractionEnabled = true
            Globals.attributedBioText((user.bio as NSString).substringToIndex(BIOTEXT_LENGTH-1), lengthExceed: true, bioLabel: bioLabel, titleColor: AppColor.boxBorderColor, bioColor: AppColor.statusBarColor)
        } else {
            bioLabel.userInteractionEnabled = false
            Globals.attributedBioText((user.bio as NSString).substringToIndex((user.bio as NSString).length), lengthExceed: false, bioLabel: bioLabel, titleColor: AppColor.boxBorderColor, bioColor: AppColor.statusBarColor)
        }
       
        Globals.attributedInterestsText(user.interests, lengthExceed: false, interestLabel: interestLabel, titleColor: AppColor.boxBorderColor, interestColor: AppColor.statusBarColor)
        
        if user.sports.count == 0 {
            beginnerButton.superview?.superview?.hidden = true
        } else {
            beginnerButton.superview?.superview?.hidden = false
        }
        sportsCarousel.currentItemIndex = 0
        sportsCarousel.reloadData()
        
        let hours = user.totalHours
        let components = hours.componentsSeparatedByString(":")
        let hour = components[0].toInt()
        if hour < 2 {
            hoursLabel.textColor = AppColor.redCompletedThisWeek
        } else if (hour>=2 && hour<4) {
            hoursLabel.textColor = UIColor.yellowColor()
        } else if (hour>=4 && hour<6) {
            hoursLabel.textColor = AppColor.statusBarColor
        } else {
            hoursLabel.font = UIFont(name: "OpenSans-Bold", size: 16.0)
            hoursLabel.textColor = AppColor.goldCompletedThisWeek
        }
        completedTitleLabel.textColor = hoursLabel.textColor
        hoursLabel.text = "\(hours) hours"
        sessionCountLabel.text = "\(user.usageCount)"
        rateLabel.text  = "\(user.rating)"
        starView.rating = (user.rating as NSString).floatValue
        var filteredArrayTime = NSArray()
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
        dateFormatter.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
        let dateString = dateFormatter.stringFromDate(date) as String
        println("current date \(dateString)")
        var dateFromString : NSDate
        dateFromString = dateFormatter.dateFromString(dateString)!
        println("current datell \(dateFromString)")
        
        
        let dateFormatterDate = NSDateFormatter()
        dateFormatterDate.dateFormat = "YYYY-MM-dd"
        dateFormatterDate.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
        let dateOnlyString = dateFormatterDate.stringFromDate(date) as String
        println("cccurrent date \(dateOnlyString)")
        var dateOnlyFromString : NSDate
        dateOnlyFromString = dateFormatterDate.dateFromString(dateOnlyString)!
        println("ccccurrent datell \(dateOnlyFromString)")
        
        
        filteredArrayTime = (user.availableTime.allObjects as NSArray).filteredArrayUsingPredicate(NSPredicate(format: "date = %@", dateOnlyString))
        println("Filter Time \(filteredArrayTime)")
        if filteredArrayTime.count == 0 {
            
            println("NNNOT TODAY")
            filteredArrayTime = (user.availableTime.allObjects as NSArray).filteredArrayUsingPredicate(NSPredicate(format: "dateTime > %@", dateString))
            
        } else {
            println("YYYES TODAY")
            filteredArrayTime = filteredArrayTime.filteredArrayUsingPredicate(NSPredicate(format: "dateTime > %@", dateString))
            
            if filteredArrayTime.count == 0 {
                
                println("NNNOT TODAY")
                filteredArrayTime = (user.availableTime.allObjects as NSArray).filteredArrayUsingPredicate(NSPredicate(format: "dateTime > %@", dateString))
                
            }
        }

        
        
      //  println("ARDRA \(profileUser!.availableTime)")
        
        if filteredArrayTime.count <= 1 {
            morebgView.hidden = true
            moreButton.hidden = true
        }
        if user.badges.count <= 3 {
            badgeNextButton.hidden = true
            badgePrevButton.hidden = true
        } else {
            badgeNextButton.hidden = false
            badgePrevButton.hidden = false
        }
        if user.reviews.count <= 1 {
            buttonView.hidden = true
        } else {
            buttonView.hidden = false
        }
        
        if filteredArrayTime.count == 0 {
            notimeLabel.hidden = false
            availableTimeCollectionView.hidden = true
        } else {
            availableTimeCollectionView.reloadData()
        }
        
        if user.badges.count == 0 {
            noBadgeLabel.hidden = false
            badgesCollectionView.hidden = true
        } else {
            badgesCollectionView.reloadData()
        }
        
        if user.reviews.count == 0 {
            noreviewLabel.hidden = false
            reviewCollectionView.hidden = true
        } else {
            reviewCollectionView.reloadData()
        }
    }
    
    func showContentChangeView() {
        let promoViewController                    = storyboard?.instantiateViewControllerWithIdentifier("PromoCodeViewController") as! PromoCodeViewController
        self.definesPresentationContext            = true
        promoViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        promoViewController.viewTag                = ViewTag.contentChange
        presentViewController(promoViewController, animated: true, completion: nil)
    }
    
    func showBioView(bioText: String) {
        let custompopController = storyboard?.instantiateViewControllerWithIdentifier("CustomPopupViewController") as! CustomPopupViewController
        self.definesPresentationContext = true
        custompopController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        custompopController.viewTag = ViewTag.bioText
        custompopController.bioText = bioText
        presentViewController(custompopController, animated: true, completion: nil)
    }
    func showStripe(){
        
       // performSegueWithIdentifier("ProfiletoStripe", sender: self)
        
        let controller  = storyboard?.instantiateViewControllerWithIdentifier("CreateStripeViewController") as! CreateStripeViewController
         self.definesPresentationContext = true
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        presentViewController(navController, animated: true, completion: nil)
        
    }
    
    
    func hideMenuView() {
        UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.menuView.frame = CGRect(x: -self.menuView.frame.size.width, y: 0.0, width: self.menuView.frame.size.width, height: self.menuView.frame.size.height)
            }){ (finished) -> Void in
                self.menuView.hidden = true
        }
    }
    
    func showEmailVerifyAlert() {
        let alert = UIAlertController(title: alertTitle, message: "Verification email has been sent to your email. Please verify to proceed.\n Haven't received email yet?", preferredStyle: UIAlertControllerStyle.Alert)
        let resendAction = UIAlertAction(title: "Resend Email", style: UIAlertActionStyle.Default) { (resendAction) -> Void in
            self.sendRequestEmailResent()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(resendAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
//        
//        if stripeVerifyString == "" {
//            
//                            print(self.presentingViewController)
//                            let controller  = storyboard?.instantiateViewControllerWithIdentifier("CreateStripeViewController") as! CreateStripeViewController
//                            controller.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
//                            presentViewController(controller, animated: true, completion: nil)
//                        }
    }
    
    func updateBio() {
        let user = appDelegate.user!
        if count(user.bio) > BIOTEXT_LENGTH {
            bioLabel.userInteractionEnabled = true
            Globals.attributedBioText((user.bio as NSString).substringToIndex(BIOTEXT_LENGTH-1), lengthExceed: true, bioLabel: bioLabel, titleColor: AppColor.boxBorderColor, bioColor: AppColor.statusBarColor)
        } else {
            bioLabel.userInteractionEnabled = false
            Globals.attributedBioText((user.bio as NSString).substringToIndex((user.bio as NSString).length), lengthExceed: false, bioLabel: bioLabel, titleColor: AppColor.boxBorderColor, bioColor: AppColor.statusBarColor)
        }
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "bioUpdation", object: nil)
    }
    
    
    func sendRequestEmailResent() {
        if !Globals.isInternetConnected() {
            return
        }
        let requestDictionary = NSMutableDictionary()
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "user/resendEmailVerifyCode", requestType: HttpMethod.post), delegate: self, tag: Connection.resetPassword)
    }
    
    //MARK: - NotificationCount API
    
    func sendRequestToGetNotificationCount() {
       // println("sendRequestToGetNotificationCount")
        if !Globals.checkNetworkConnectivity() {
            return
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: SERVER_URL.stringByAppendingString("sessions/notificationCount"))!)
        request.HTTPMethod = HttpMethod.post
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var error: NSError? = nil
        let parameters = NSMutableDictionary()
        if let deviceToken = appDelegate.deviceToken {
            parameters.setObject(deviceToken, forKey:"device_id")
        } else {
            parameters.setObject("xyz", forKey: "device_id")
        }
        if let apiToken = NSUserDefaults.standardUserDefaults().objectForKey("API_TOKEN") as? String {
            parameters.setObject(apiToken, forKey: "token")
        }
       // println("PARAM\(parameters)")
        let jsonData        = NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
        request.HTTPBody = jsonData
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error == nil {
                if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
                    
                    //println("Notification Count Result\(jsonResult)")
                    if let status = jsonResult["status"] as? Int {
                        if status == ResponseStatus.success {
                            
                            if let resultArray = jsonResult["data"] as? NSArray {
                                
                               // println("Notification Count Resultuuu\(resultArray)")
                                
                                if let notificationCount = resultArray[0].objectForKey("notification_count") as? Int {
                                    
                                  //  println("Notification Count Resultgggggg\(notificationCount)")
                                    if notificationCount >= 1 {
                                        self.notificationCountLabel.hidden = false
                                        if let id = self.profileID {
                                            self.notificationCountLabel.hidden = true
                                        }
                                        if notificationCount>9{
                                          self.notificationCountLabel.text = "9+"
                                        } else {
                                         self.notificationCountLabel.text = "\(notificationCount)"
                                        }
                                    }else {
                                         self.notificationCountLabel.hidden = true
                                    }
                                }
                            }
                           
                        } else {
                            if let message = jsonResult["message"] as? String {
                            }
                        }
                    }
                }
            } else {
               // UIAlertView(title: alertTitle, message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
            }
        }
        
    }
    
    
    //MARK: - NoticationList API
    func sendRequestForNotificationList() {
        if !Globals.checkNetworkConnectivity() {
            if let notifArray = Notification.fetchNotifications() {
                notificationListArray = notifArray as! Array<Notification>
                notificationTableView.reloadData()
            } else {
                showDismissiveAlertMesssage(Message.Offline)
            }
            return
        }
        notifIndicatorView.startAnimating()
        let requestDictionary = NSMutableDictionary()
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "sessions/notification", requestType: HttpMethod.post), delegate: self, tag: Connection.notificationRequest)
    }
    
    //MARK: - Profile API
    
    func sendRequestForProfile() {
        
        println("PROFILE REQUEST")
        if !Globals.checkNetworkConnectivity() {
            if let id = profileID {
                if let user = User.fetchUser(NSPredicate(format: "profileID = %d", argumentArray: [id.toInt()!])) {
                    profileUser = user
                    populateProfileContents(profileUser!)
                } else {
                    showDismissiveAlertMesssage(Message.Offline)
                }
            } else {
                if let user = User.fetchUser(NSPredicate(format: "currentUser = %d", argumentArray: [1])) {
                    appDelegate.user = user
                    populateProfileContents(appDelegate.user!)
                } else {
                    showDismissiveAlertMesssage(Message.Offline)
                }
            }
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        if let id = profileID {
            requestDictionary.setObject(id.toInt()!, forKey: "user_id")
        }
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "profile/profile", requestType: HttpMethod.post), delegate: self, tag: Connection.userProfile)
    }
    
    func sendRequestForUpdateSportsLevel(sports: UserSports, type: String) {
        if !Globals.isInternetConnected() {
            return
        }
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(sports.sportsID, forKey: "sports_id")
        requestDictionary.setObject(sports.expertLevel, forKey: "expert_level")
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
            //Other user
            User.deleteUser(NSPredicate(format: "profileID = %d", argumentArray: [id.toInt()!]))
            profileUser            = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: appDelegate.managedObjectContext!) as? User
            profileUser!.currentUser = 0
            profileUser!.profileID  = Globals.checkIntNull(responseDictionary["profile_id"] as? Int)
            profileUser!.name       = Globals.checkStringNull(responseDictionary["profile_name"] as? String)
            profileUser!.email      = Globals.checkStringNull(responseDictionary["email"] as? String)
            profileUser!.userVerified = Globals.checkIntNull(responseDictionary["user_verified"] as? Int)
            profileUser!.walletBalance = Globals.checkStringNull(responseDictionary["wallet_balance"] as? String)
            profileUser!.interests     = Globals.checkStringNull(responseDictionary["other_interests"] as? String)
            profileUser!.bio           = Globals.checkStringNull(responseDictionary["profile_desc"] as? String)
            if let imageUrl = responseDictionary["profile_image"] as? String {
                profileUser!.imageURL = imageUrl
            } else {
                profileUser!.imageURL = ""
            }
            
            if let session = responseDictionary["Training_session"] as? NSArray {
               // appDelegate.user!.availableTime.removeAllObjects()
                for sess in session {
                    
                    
                    let dateFormatDate = NSDateFormatter()
                    dateFormatDate.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
                    dateFormatDate.dateFormat = "yyyy-MM-dd HH:mm"
                    
                    let dateFormatDate1 = NSDateFormatter()
                    dateFormatDate1.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
                    dateFormatDate1.dateFormat = "yyyy-MM-dd"
                    
                    
                    let dateFormatDate2 = NSDateFormatter()
                    dateFormatDate2.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
                    dateFormatDate2.dateFormat = "HH:mm"
                    
                    
                    let dateZone = sess["date"] as! String
                    let timeStarts = sess["time_starts"] as! String
                    let timeEnd = sess["time_ends"] as! String
                    let endDate = dateZone + " " + timeEnd
                    println("End Date \(endDate)")
                    let endDateDate = dateFormatDate.dateFromString(endDate)
                    
                    
                    let dateTime = sess["datetime"] as! String
                    let dateTimeDate = dateFormatDate.dateFromString(dateTime)
                    
                    let timeZone1 = NSTimeZone(name: "America/Chicago")
                    let localTimeZone = NSTimeZone.systemTimeZone()
                    let timeZone1Interval = timeZone1?.secondsFromGMTForDate(dateTimeDate!)
                    let deviceTimeZoneInterval = localTimeZone.secondsFromGMTForDate(dateTimeDate!)
                    let timeInterval =  Double(deviceTimeZoneInterval - timeZone1Interval!)
                    let originalDate = NSDate(timeInterval: timeInterval, sinceDate: dateTimeDate!)
                    let dateFormater : NSDateFormatter = NSDateFormatter()
                    dateFormater.dateFormat = "yyyy-MM-dd HH:mm"
                    NSLog("Converted date: \(dateFormater.stringFromDate(originalDate))")
                    
                    
                    let timeZone1IntervaEndDate = timeZone1?.secondsFromGMTForDate(endDateDate!)
                    let deviceTimeZoneIntervalEndDate = localTimeZone.secondsFromGMTForDate(endDateDate!)
                    let timeIntervalEndDate =  Double(deviceTimeZoneIntervalEndDate - timeZone1IntervaEndDate!)
                    let originalEndDate = NSDate(timeInterval: timeIntervalEndDate, sinceDate: endDateDate!)
                    
                    NSLog("Converted date: \(dateFormatDate.stringFromDate(originalEndDate))")
                    
                    println("dateTimezone \(dateTimeDate)")
                    
                    let time = UserTime.saveUserTimeList(dateFormatDate1.stringFromDate(originalDate) as String, startTime: (dateFormatDate2.stringFromDate(originalDate)) as String, endTime: (dateFormatDate2.stringFromDate(originalEndDate)) as String, user: profileUser!,dateTime: (dateFormater.stringFromDate(originalDate)) as String)
                    profileUser!.availableTime.addObject(time)
                    
                 }
            }
            
            
            if let usageCount = responseDictionary["usage_count"] as? Int {
                profileUser!.usageCount = "\(usageCount)"
            }
            if let rate = responseDictionary["rating"] as? String {
                profileUser!.rating = rate
            }
            if let badges = responseDictionary["Badges"] as? NSArray {
                profileUser!.badges.removeAllObjects()
                for badge in badges {
                    let badge = UserBadges.saveUserBadgesList(badge["count"] as! Int, sessionCount: badge["session_count"] as! Int, name: badge["name"] as! String, imageURL: badge["image_url"] as! String, user: profileUser!)
                    profileUser!.badges.addObject(badge)
                }
            }
            if let comments = responseDictionary["User_comments"] as? NSArray {
                profileUser!.reviews.removeAllObjects()
                for comment in comments {
                    let review = UserReview.saveUserReviewList(comment["profile_id"] as! Int, name: comment["profile_name"] as! String, imageURL: comment["profile_pic"] as! String, rate: comment["user_rating"] as! Int, review: comment["user_review"] as! String, user: profileUser!)
                    profileUser!.reviews.addObject(review)
                }
            }
            
            if let hours = responseDictionary["weekly_hours"] as? String {
                profileUser!.totalHours = hours
            }
          
            
            if let sportsArray = responseDictionary["Sports_list"] as? NSArray {
                profileUser!.sports.removeAllObjects()
                for sports in sportsArray {
                    let filteredArray = appDelegate.sportsArray.filteredArrayUsingPredicate(NSPredicate(format: "sportsId = %d", argumentArray: [sports["sports_id"] as! Int]))
                    if filteredArray.count > 0 {
                        let mysport = filteredArray[0] as! SportsList
                        let sport = UserSports.saveUserSportsList(sports["sports_id"] as! Int, sportsName: sports["sport_name"] as! String, level: sports["expert_level"] as! String, imageURL: mysport.logo, user: profileUser!)
                        profileUser!.sports.addObject(sport)
                    } else {
                        let sport = UserSports.saveUserSportsList(sports["sports_id"] as! Int, sportsName: sports["sport_name"] as! String, level: sports["expert_level"] as! String, imageURL: "", user: profileUser!)
                        profileUser!.sports.addObject(sport)
                    }
                }
            }
            profileUser!.isFavorite = responseDictionary["favourite"] as! Bool
        } else {
            //logged in User
            if responseDictionary["email_verify"] as! Int == 0 {
                stripeVerifyString = responseDictionary["stripe_recipient_id"] as! String
                showEmailVerifyAlert()
            }
            
            if let user = appDelegate.user {
                if user.profileImage.length != 0 {
                    profileImage = user.profileImage
                }
            }
            User.deleteUser(NSPredicate(format: "currentUser = %d", argumentArray: [1]))
            appDelegate.user                = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: appDelegate.managedObjectContext!) as? User
            appDelegate.user!.currentUser   = 1
            appDelegate.user!.profileID     = Globals.checkIntNull(responseDictionary["profile_id"] as? Int)
            appDelegate.user!.name          = Globals.checkStringNull(responseDictionary["profile_name"] as? String)
            appDelegate.user!.email         = Globals.checkStringNull(responseDictionary["email"] as? String)
            appDelegate.user!.userVerified  = Globals.checkIntNull(responseDictionary["user_verified"] as? Int)
            appDelegate.user!.walletBalance = Globals.checkStringNull(responseDictionary["wallet_balance"] as? String)
            if let image = profileImage {
                appDelegate.user!.profileImage = image
            }
            if let imageUrl = responseDictionary["profile_image"] as? String {
                appDelegate.user!.imageURL = imageUrl
            } else {
                appDelegate.user!.imageURL = ""
            }
            availBalanceLabel.text =  appDelegate.user!.walletBalance == "" ? "$0" : "$\(appDelegate.user!.walletBalance)"
           
            if let bio = responseDictionary["profile_desc"] as? String {
                if bio == "" || bio == "null"{
                    appDelegate.user!.bio = ""
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBio", name: "bioUpdation", object: nil)
                    showBioView(bio)
                } else {
                    appDelegate.user!.bio = bio
                }
            } else {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBio", name: "bioUpdation", object: nil)
                appDelegate.user!.bio = ""
                showBioView("")
            }
            if responseDictionary["stripe_recipient_id"] as! String == "" {
                
                self.showStripe()
                //NSNotificationCenter.defaultCenter().addObserver(self, selector: "showStripe", name: "stripe", object: nil)
            }
            if let otherInterests = responseDictionary["other_interests"] as? String {
                appDelegate.user!.interests = otherInterests
            } else {
                appDelegate.user!.interests = ""
            }
            
            println(appDelegate.configDictionary)
            //Mobile Privacy, Contract Content Change
            if let terms = responseDictionary["terms_agree_status"] as? Int {
                appDelegate.user!.termsStatus = terms
                if let change = appDelegate.configDictionary["GENERAL_CMS_AMENDMENT"] as? String {
                    if terms == 0 && change.toInt()! == 1 {
                        showContentChangeView()
                    }
                }
            }

            if let session = responseDictionary["Training_session"] as? NSArray {
                appDelegate.user!.availableTime.removeAllObjects()
                for sess in session {
                    
                    let dateFormatDate = NSDateFormatter()
                    dateFormatDate.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
                    dateFormatDate.dateFormat = "yyyy-MM-dd HH:mm"
                    
                    
                    let dateFormatDate1 = NSDateFormatter()
                    dateFormatDate1.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
                    dateFormatDate1.dateFormat = "yyyy-MM-dd"
                    
                    
                    let dateFormatDate2 = NSDateFormatter()
                    dateFormatDate2.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
                    dateFormatDate2.dateFormat = "HH:mm"
                    
                    
                    let dateZone = sess["date"] as! String
                    let timeStarts = sess["time_starts"] as! String
                    let timeEnd = sess["time_ends"] as! String
                    let endDate = dateZone + " " + timeEnd
                    println("End Date \(endDate)")
                    let endDateDate = dateFormatDate.dateFromString(endDate)
                    
                    
                    
                    let dateTime = sess["datetime"] as! String
                    let dateTimeDate = dateFormatDate.dateFromString(dateTime)
                    
                    
                    
                    
                    let timeZone1 = NSTimeZone(name: "America/Chicago")
                    let localTimeZone = NSTimeZone.systemTimeZone()
                    
                    let timeZone1Interval = timeZone1?.secondsFromGMTForDate(dateTimeDate!)
                    let deviceTimeZoneInterval = localTimeZone.secondsFromGMTForDate(dateTimeDate!)
                    let timeInterval =  Double(deviceTimeZoneInterval - timeZone1Interval!)
                    let originalDate = NSDate(timeInterval: timeInterval, sinceDate: dateTimeDate!)
                    let dateFormater : NSDateFormatter = NSDateFormatter()
                    dateFormater.dateFormat = "yyyy-MM-dd HH:mm"
                    NSLog("Converted date: \(dateFormater.stringFromDate(originalDate))")
                    
                    
                    let timeZone1IntervaEndDate = timeZone1?.secondsFromGMTForDate(endDateDate!)
                    let deviceTimeZoneIntervalEndDate = localTimeZone.secondsFromGMTForDate(endDateDate!)
                    let timeIntervalEndDate =  Double(deviceTimeZoneIntervalEndDate - timeZone1IntervaEndDate!)
                    let originalEndDate = NSDate(timeInterval: timeInterval, sinceDate: endDateDate!)
                   
                    NSLog("Converted date: \(dateFormatDate.stringFromDate(originalEndDate))")
                    
                    
                    println("dateTimezone \(dateTimeDate)")
                    
                    let time = UserTime.saveUserTimeList(dateFormatDate1.stringFromDate(originalDate) as String, startTime: (dateFormatDate2.stringFromDate(originalDate)) as String, endTime: (dateFormatDate2.stringFromDate(originalEndDate)) as String, user: appDelegate.user!,dateTime: (dateFormater.stringFromDate(originalDate)) as String)
                    appDelegate.user!.availableTime.addObject(time)
                }
            }
            if let usageCount = responseDictionary["usage_count"] as? Int {
                appDelegate.user!.usageCount = "\(usageCount)"
            }
            if let rate = responseDictionary["rating"] as? String {
                appDelegate.user!.rating = rate
            }
            if let badges = responseDictionary["Badges"] as? NSArray {
                appDelegate.user!.badges.removeAllObjects()
                for badge in badges {
                    let userBadge = UserBadges.saveUserBadgesList(badge["count"] as! Int, sessionCount: badge["session_count"] as! Int, name: badge["name"] as! String, imageURL: badge["image_url"] as! String, user: appDelegate.user!)
                    appDelegate.user!.badges.addObject(userBadge)
                }
            }
            if let comments = responseDictionary["User_comments"] as? NSArray {
                appDelegate.user!.reviews.removeAllObjects()
                for comment in comments {
                    let review = UserReview.saveUserReviewList(comment["profile_id"] as! Int, name: comment["profile_name"] as! String, imageURL: comment["profile_pic"] as! String, rate: comment["user_rating"] as! Int, review: comment["user_review"] as! String, user: appDelegate.user!)
                    appDelegate.user!.reviews.addObject(review)
                }
            }
            
            if let hours = responseDictionary["weekly_hours"] as? String {
                appDelegate.user!.totalHours = hours
            }
            
            if let sportsArray = responseDictionary["Sports_list"] as? NSArray {
                appDelegate.user!.sports.removeAllObjects()
                println(appDelegate.sportsArray)
                for sports in sportsArray {
                    let filteredArray = appDelegate.sportsArray.filteredArrayUsingPredicate(NSPredicate(format: "sportsId = %d", argumentArray: [sports["sports_id"] as! Int]))
                    if filteredArray.count > 0 {
                        let mysport = filteredArray[0] as! SportsList
                        let userSport = UserSports.saveUserSportsList(sports["sports_id"] as! Int, sportsName: sports["sport_name"] as! String, level: sports["expert_level"] as! String, imageURL: mysport.logo, user: appDelegate.user!)
                        appDelegate.user!.sports.addObject(userSport)
                    } 
                }
                for sport in appDelegate.sportsArray {
                    if sportsArray.valueForKey("sports_id")!.containsObject((sport as! SportsList).sportsId.integerValue) {
                    } else {
                        let userSport = UserSports.saveUserSportsList((sport as! SportsList).sportsId.integerValue, sportsName: (sport as! SportsList).sportsName, level: "", imageURL: (sport as! SportsList).logo, user: appDelegate.user!)
                        appDelegate.user!.sports.addObject(userSport)
                    }
                }
                println (appDelegate.user!.sports)
                var sportsList = appDelegate.user?.sports.allObjects as! [UserSports]
                appDelegate.user?.sports = NSMutableSet(array: (sportsList as NSArray).sortedArrayUsingDescriptors([NSSortDescriptor(key: "expertLevel.length", ascending: false)]))
//                sportsList.sort({ (sport1, sport2) -> Bool in
//                    return count((sport1 as UserSports).expertLevel) > count((sport2 as UserSports).expertLevel)
//                })
                println (appDelegate.user!.sports)
            }
        }
        appDelegate.saveContext()
    }
    
    func connection(connection: CustomURLConnection, didReceiveResponse: NSURLResponse) {
        connection.receiveData.length = 0
    }
    
    func connection(connection: CustomURLConnection, didReceiveData data: NSData) {
        connection.receiveData.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: CustomURLConnection) {
        let response = NSString(data: connection.receiveData, encoding: NSUTF8StringEncoding)
        println("NOTIFICATION RESPONSE \(response)")
        var error: NSError?
        
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(connection.receiveData, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
            if let status = jsonResult["status"] as? Int {
                if connection.connectionTag == Connection.userProfile {
                    println("USER PROFILE")
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
                        populateProfileContents(profileUser!)
                    } else {
                        populateProfileContents(appDelegate.user!)
                    }
                } else if connection.connectionTag == Connection.logout {
                    
                    println("LOG OUT")
                    if status == ResponseStatus.error {
                        if let message = jsonResult["message"] as? String {
                            showDismissiveAlertMesssage(message)
                        } else {
                            showDismissiveAlertMesssage(Message.Error)
                        }
                    } else {
                        Globals.clearSession()
                        
                          let appDomain = NSBundle.mainBundle().bundleIdentifier!
                          NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
                            let controller  = storyboard?.instantiateViewControllerWithIdentifier("LoginOrSignUpViewController") as! LoginOrSignUpViewController
                            controller.hidesBottomBarWhenPushed = true
                            navigationController?.pushViewController(controller, animated: true)
  
//                        } else {
//                            
//                             (self.presentingViewController as! UINavigationController).popToRootViewControllerAnimated(true)
//                            
//                        }
                        
                      
                       // dismissViewControllerAnimated(true, completion: nil)
                        
                    }
                } else if connection.connectionTag == Connection.updateSports {
                    println("UPDATESPORTS")
                    if status == ResponseStatus.sessionOut {
                        dismissOnSessionExpire()
                    }
                } else if connection.connectionTag == Connection.unfavourite {
                    println("UNFAVOURITE")
                    if status == ResponseStatus.success {
                        profileUser!.isFavorite = favoriteButton.selected
                        NSNotificationCenter.defaultCenter().postNotificationName(PushNotification.favNotif, object: nil, userInfo: ["user" : profileUser!])
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
                    println("NOTIFICATIONREQUEST")
                    if status == ResponseStatus.success {
                        if var notifications = jsonResult["data"] as? NSMutableArray {
                            println("NOT EMPTY")
                            Notification.deleteNotificationList()
                            notificationListArray.removeAll(keepCapacity: true)
                            let predicate = NSPredicate(format: "status == %@ || status == %@", argumentArray: [TrainingStatus.pendingCanceled, TrainingStatus.acceptCanceled])
                            let filteredArray = notifications.filteredArrayUsingPredicate(predicate)
                            notifications.removeObjectsInArray(filteredArray)
                            for notif in notifications {
                                var notifBody = ""
                                if let body = notif["ntfn_body"] as? String {
                                    notifBody = body
                                }
                                Notification.saveNotification(Globals.checkStringNull(notif["user_name"] as? String), userID: Globals.checkIntNull(notif["user_id"] as? Int), requestID: Globals.checkIntNull(notif["request_id"] as? Int), trainerID: Globals.checkIntNull(notif["trainer_id"] as? Int), spID: Globals.checkIntNull(notif["sports_id"] as? Int), spName: Globals.checkStringNull(notif["sports_name"] as? String), type: Globals.checkStringNull(notif["type"] as? String), loc: Globals.checkStringNull(notif["location"] as? String), readStatus: Globals.checkIntNull(notif["read_status"] as? Int), startTime: Globals.checkStringNull(notif["start_time"] as? String), endTime: Globals.checkStringNull(notif["end_time"] as? String), allotedDate: Globals.checkStringNull(notif["alloted_date"] as? String), userImage: Globals.checkStringNull(notif["user_image"] as? String), trainerName: Globals.checkStringNull(notif["trainer_name"] as? String), trainerImage: Globals.checkStringNull(notif["trainer_image"] as? String), body: notifBody)
                            }
                            if let listArray = Notification.fetchNotifications() as? Array<Notification> {
                                notificationListArray = listArray
                            }
                            label?.hidden = true
                            
                            
                            var i:Int = 0
                            while i < notificationListArray.count {
                                
                                let notification = notificationListArray[i]
                                if notification.type == TrainingStatus.sessionAutoCancel{
                                    if let user = appDelegate.user {
                                        if  user.profileID == notification.trainerID {
                                            notificationListArray.removeAtIndex(i)
                                            
                                        }else{
                                            
                                            i++
                                        }
                                    }
                                }else {
                                    
                                    i++
                                }
                            }

                            
                            
//                            var i:Int = 0
//                            
//                            for i=0; i<notificationListArray.count; i++ {
//                                
//                                
//                                let notification = notificationListArray[i]
//                                if notification.type == TrainingStatus.sessionAutoCancel{
//                                    if let user = appDelegate.user {
//                                    if  user.profileID == notification.trainerID {
//                                        notificationListArray.removeAtIndex(i)
//                                    }
//                                    }
//                                }
//                            }
                            notificationTableView.reloadData()
                        } else
                        {
                            println("NOTIFICATION IS EMPTY")
                           
                        }
                        if notificationListArray.count <= 0 {
                            println("NOTIFICATION IS EMPTY ZERO")
                             label?.hidden = false
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
                } else {
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
            if let profUser = profileUser {
                populateProfileContents(profUser)
            }
        } else {
            if let currentUser = appDelegate.user {
                populateProfileContents(currentUser)
            }
        }
        showLoadingView(false)
    }
    
    func setExpertiseLevel(level: String) {
        let sports  = ((appDelegate.user!.sports.allObjects as NSArray).sortedArrayUsingDescriptors([NSSortDescriptor(key: "expertLevel.length", ascending: false)]))[sportsCarousel.currentItemIndex] as! UserSports
        var type    = ""
        if count(sports.expertLevel) == 0 && count(level) > 0 {
            type = SportsLevel.typeAdd
        } else if count(sports.expertLevel) > 0 && count(level) > 0 {
            type = SportsLevel.typeUpdate
        } else if count(sports.expertLevel) > 0 && count(level) == 0 {
            type = SportsLevel.typeDelete
        }
        sports.expertLevel = level
        sendRequestForUpdateSportsLevel(sports, type: type)
        let currentView = sportsCarousel.itemViewAtIndex(sportsCarousel.currentItemIndex)
        let tickImageView = currentView?.viewWithTag(4) as! UIImageView
        tickImageView.hidden = level == "" ? true : false
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
        if let profID = profileID {
            if let profUser = profileUser {
                
                return profUser.sports.count
                
            }
        } else {
            if let user = appDelegate.user {
                return user.sports.count
            }
        }
        return 0
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        var contentView: UIView
        var titleLabel: UILabel
        var sportsImageView: UIImageView
        var indicatorView: UIActivityIndicatorView
        var tickImageView: UIImageView
        
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
        
        var tapGesturesportscarousel = UITapGestureRecognizer(target: self, action: "viewTap:")
        tapGesturesportscarousel.cancelsTouchesInView = false
        contentView.addGestureRecognizer(tapGesturesportscarousel)
        
        var source          = profileID == nil ? appDelegate.user!.sports.allObjects : profileUser!.sports.allObjects
//        println(source)
        source              = (source as NSArray).sortedArrayUsingDescriptors([NSSortDescriptor(key: "expertLevel.length", ascending: false)])
        let sports          = source[index] as! UserSports
        sportsImageView.image = UIImage(named: "default_image")
        sportsImageView.contentMode = UIViewContentMode.ScaleAspectFit
        CustomURLConnection.downloadAndSetImage(sports.logo, imageView: sportsImageView, activityIndicatorView: indicatorView)
        
        if index == carousel.currentItemIndex {
            titleLabel.text = sports.sportsName.uppercaseString as String
            if profileID == nil {
                if sports.expertLevel == SportsLevel.beginner {
                    beginnerButton.selected = true
                } else if sports.expertLevel == SportsLevel.moderate {
                    moderateButton.selected = true
                } else if sports.expertLevel == SportsLevel.expert {
                    expertButton.selected = true
                }
            } else {
                expertLevelLabel.superview?.superview?.hidden = false
                if sports.expertLevel ==  "" {
                    expertLevelLabel.superview?.superview?.hidden = true
                } else {
                    expertLevelLabel.text = sports.expertLevel
                }
            }
        } else {
            titleLabel.text = sports.sportsName
        }
        
        if sports.expertLevel == "" {
            tickImageView.hidden = true
        } else {
            tickImageView.hidden = false
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
        if !notificationBackgroundView.hidden {
            notificationButton.tag = 0
            UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.notificationBackgroundView.hidden  = true
                }, completion: nil)

        } else if menuView.frame.origin.x == 0 {
            hideMenuView()
        } else {
            beginnerButton.selected = false
            moderateButton.selected = false
            expertButton.selected   = false
            carousel.reloadData()
        }
    }
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        
        if !notificationBackgroundView.hidden {
            notificationButton.tag=0
            UIView.animateWithDuration(animateInterval, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.notificationBackgroundView.hidden  = true
                }, completion: nil)
            
        } else if menuView.frame.origin.x == 0 {
            hideMenuView()
        }
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
            if let profID = profileID {
                if let profUser = profileUser {
                    return profUser.reviews.count
                }
            } else {
                if let user = appDelegate.user {
                    return user.reviews.count
                }
            }
        } else if collectionView.isEqual(badgesCollectionView) {
            if let profID = profileID {
                if let profUser = profileUser {
                    return profUser.badges.count
                }
            } else {
                if let user = appDelegate.user {
                    return user.badges.count
                }
            }
        }
        var source = NSMutableSet()
        if let profID = profileID {
            if let profUser = profileUser {
                source = profUser.availableTime
            }
        } else {
            if let user = appDelegate.user {
                source =  user.availableTime
            }
        }
        
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
        dateFormatter.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
        let dateString = dateFormatter.stringFromDate(date) as String
        println("current date \(dateString)")
        var dateFromString : NSDate
        dateFromString = dateFormatter.dateFromString(dateString)!
        println("current datell \(dateFromString)")
        
        
        let dateFormatterDate = NSDateFormatter()
        dateFormatterDate.dateFormat = "YYYY-MM-dd"
        dateFormatterDate.locale     = NSLocale(localeIdentifier: "en_US_POSIX")
        let dateOnlyString = dateFormatterDate.stringFromDate(date) as String
        println("current date \(dateOnlyString)")
        var dateOnlyFromString : NSDate
        dateOnlyFromString = dateFormatterDate.dateFromString(dateOnlyString)!
        println("current datell \(dateOnlyFromString)")

        
        tempFilterTimeArray = (source.allObjects as NSArray).filteredArrayUsingPredicate(NSPredicate(format: "date = %@", dateOnlyString))
        
        if tempFilterTimeArray.count == 0 {
            
            println("NOT TODAY")
            tempFilterTimeArray = (source.allObjects as NSArray).filteredArrayUsingPredicate(NSPredicate(format: "dateTime > %@", dateString))
            
        } else {
            println("YES TODAY")
            tempFilterTimeArray = tempFilterTimeArray.filteredArrayUsingPredicate(NSPredicate(format: "dateTime > %@", dateString))
            
            if tempFilterTimeArray.count == 0 {
                
                println("NNNOT TODAY")
                tempFilterTimeArray = (source.allObjects as NSArray).filteredArrayUsingPredicate(NSPredicate(format: "dateTime > %@", dateString))
                
            }
        }

          
        
//        tempFilterTimeArray = (source.allObjects as NSArray).filteredArrayUsingPredicate(NSPredicate(format: "dateTime > %@", dateString))
//        
//        
//        if tempFilterTimeArray.count == 0 {
//          
//            tempFilterTimeArray = (source.allObjects as NSArray).filteredArrayUsingPredicate(NSPredicate(format: "dateTime > %@", dateString))
//            
//        } else {
//            
//            tempFilterTimeArray = (source.allObjects as NSArray).filteredArrayUsingPredicate(NSPredicate(format: "dateTime > %@", dateString))
//        }
        
        var descriptor: NSSortDescriptor = NSSortDescriptor(key: "dateTime", ascending: true)
        filterTimeArray = tempFilterTimeArray.sortedArrayUsingDescriptors([descriptor])
        return filterTimeArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView.isEqual(reviewCollectionView) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("reviewCell", forIndexPath: indexPath) as! UserReviewCollectionViewCell
            let source = profileID == nil ? appDelegate.user!.reviews : profileUser!.reviews
            let review = source.allObjects[indexPath.row] as! UserReview
            cell.reviewView.starView.rating = review.userRating.floatValue
            cell.reviewView.reviewTextView.scrollRangeToVisible(NSMakeRange(0, 0))
            cell.reviewView.reviewTextView.text = review.userReview
            cell.reviewView.nameLabel.text      = review.profileName
            cell.reviewView.userImageView.image = UIImage(named: "default_image")
            cell.reviewView.userImageView.contentMode = UIViewContentMode.ScaleAspectFit
            CustomURLConnection.downloadAndSetImage(review.profilePic, imageView: cell.reviewView.userImageView, activityIndicatorView: cell.reviewView.indicatorView)
            return cell
        } else if collectionView.isEqual(badgesCollectionView){
            
            
            let source  = profileID == nil ? appDelegate.user!.badges : profileUser!.badges
            let badge   = source.allObjects[indexPath.row] as! UserBadges
            if badge.name == "no badge" {
                
                println("BadgesCollectionViewBadge")
                let cell    = collectionView.dequeueReusableCellWithReuseIdentifier("badgeCell", forIndexPath: indexPath) as! BadgesCollectionViewCell
                
                //cell.titleLabel.hidden  = badge.name == "no badge" ? true : false
                //cell.titleLabel.text    = badge.name.uppercaseString
                cell.badgeImageView.image = UIImage(named: "default_image")
                cell.badgeImageView.contentMode = UIViewContentMode.ScaleAspectFit
                CustomURLConnection.downloadAndSetImage(badge.imageURL, imageView: cell.badgeImageView, activityIndicatorView: cell.indicatorView)
                /// cell.badgeImageView.contentMode = UIViewContentMode.ScaleToFill
                cell.countLabel.text = "\(badge.sessionCount)"
                return cell

                
            } else {
                
                println("BadgesCollectionView")
                let cell    = collectionView.dequeueReusableCellWithReuseIdentifier("MedalCell", forIndexPath: indexPath) as! MedalCollectionViewCell
                
                //cell.titleLabel.hidden  = badge.name == "no badge" ? true : false
                //cell.titleLabel.text    = badge.name.uppercaseString
                cell.badgeImageView.image = UIImage(named: "default_image")
                //cell.badgeImageView.contentMode = UIViewContentMode.ScaleAspectFit
                CustomURLConnection.downloadAndSetImage(badge.imageURL, imageView: cell.badgeImageView, activityIndicatorView: cell.indicatorView)
                cell.badgeImageView.contentMode = UIViewContentMode.ScaleToFill
                cell.countLabel.text = "\(badge.sessionCount)"
                return cell

                
            }
            
            
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("timeCell", forIndexPath: indexPath) as! AvailableTimeCollectionViewCell
//            let source = profileID == nil ? appDelegate.user!.availableTime.allObjects : profileUser!.availableTime.allObjects
//            println("ARDRA \(profileUser!.availableTime.allObjects)")
//            var filteredArray = (source as NSArray).filteredArrayUsingPredicate(NSPredicate(format: "date = %@", argumentArray: [Globals.convertDate(NSDate())]))
//            filteredArray   = (filteredArray as NSArray).sortedArrayUsingComparator({ (obj1, obj2) -> NSComparisonResult in
//                println("filter \(filteredArray)")
//                let dateFormatter = NSDateFormatter()
//                dateFormatter.dateFormat = "HH:mm"
//                let date1 = dateFormatter.dateFromString((obj1 as! UserTime).timeStarts as String)
//                let date2 = dateFormatter.dateFromString((obj2 as! UserTime).timeStarts as String)
//                return date1!.compare(date2!)
//            })
            
            let time = filterTimeArray[indexPath.row] as! UserTime
            let tt = time.date + " " + Globals.convertTimeTo12Hours(time.timeStarts) as String
            cell.timeLabel.text = time.date + " " + Globals.convertTimeTo12Hours(time.timeStarts)
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
            return CGSize(width: 110.0, height: 22.0)
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
        var imageUrl:String = ""
        cell.roundLabel.layer.cornerRadius  = 10.0
        cell.roundLabel.layer.borderColor   = UIColor.clearColor().CGColor
        cell.roundLabel.clipsToBounds       = true
        cell.profilePic.layer.cornerRadius  = 25.0
        cell.profilePic.layer.borderColor   = UIColor.clearColor().CGColor
        cell.profilePic.clipsToBounds       = true
        let notification                    = notificationListArray[indexPath.row]
        let readStatus                      = notification.readStatus
        if  readStatus == 0{
            cell.roundLabel.backgroundColor = AppColor.boxBorderColor
        } else {
            cell.roundLabel.backgroundColor = AppColor.notifReadColor
        }
        
        if notification.type == TrainingStatus.requested {
            imageUrl            = notification.userImage
            cell.nameLabel.text = notification.userName
            cell.bodyLabel.text = "has requested for \(notification.sportsName)"
        } else if notification.type == TrainingStatus.accepted {
            imageUrl            = notification.trainerImage
            cell.nameLabel.text = notification.trainerName
            cell.bodyLabel.text = "has accepted your booking request"
        } else {
            imageUrl            = notification.userImage
            cell.nameLabel.text = notification.userName
            cell.bodyLabel.text = notification.message
        }
        
        cell.profilePic.image       = UIImage(named: "default_image")
        cell.profilePic.contentMode = UIViewContentMode.ScaleAspectFit
        let imageurl                = SERVER_URL.stringByAppendingString(imageUrl as String) as NSString
        if imageurl.length != 0 {
            if var imagesArray = Images.fetch(imageurl as String) {
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
                                if let image  = imageFromData{
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
        if notificationListArray[indexPath.row].readStatus == 0 {
            sendRequestForUpdateNotifReadStatus(notificationListArray[indexPath.row].requestID.integerValue)
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! NotificationCell
            cell.roundLabel.backgroundColor = AppColor.notifReadColor
            notificationListArray[indexPath.row].readStatus = 1
            notificationTableView.reloadData()
        }
        if notificationListArray[indexPath.row].type == TrainingStatus.requested {
            let controller  = storyboard?.instantiateViewControllerWithIdentifier("BookingRequestViewController") as! BookingRequestViewController
            self.definesPresentationContext   = true
            controller.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            controller.notification = notificationListArray[indexPath.row]
            presentViewController(controller, animated: true, completion: nil)
            notificationBackgroundView.hidden = true
        } else if notificationListArray[indexPath.row].type == TrainingStatus.eightHoursCompleted {
            
            let controller  = storyboard?.instantiateViewControllerWithIdentifier("FaceBookShareViewController") as! FaceBookShareViewController
            controller.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
            self.presentViewController(controller, animated: true, completion: nil)

        } else {
            
            let controller  = storyboard?.instantiateViewControllerWithIdentifier("NotificationDetailViewController") as! NotificationDetailViewController
            self.definesPresentationContext   = true
            controller.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            controller.notification = notificationListArray[indexPath.row]
            presentViewController(controller, animated: true, completion: nil)
            notificationBackgroundView.hidden = true
            
        }
        
        
    }
}
extension MyProfileViewController: FBSDKSharingDelegate {
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        println("FBBBBB \(results)")
        println("SHAREE \(sharer)")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        
        println("CAncel")
        
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        
        println("Eorror \(error)")
        
    }
}


