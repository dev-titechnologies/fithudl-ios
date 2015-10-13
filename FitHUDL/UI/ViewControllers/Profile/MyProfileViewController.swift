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
    
    var profileID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var nib = UINib(nibName: "UserReviewCollectionViewCell", bundle: nil)
        reviewCollectionView.registerNib(nib, forCellWithReuseIdentifier: "reviewCell")
        
        nib = UINib(nibName: "BadgesCollectionViewCell", bundle: nil)
        badgesCollectionView.registerNib(nib, forCellWithReuseIdentifier: "badgeCell")
        
        badgePrevButton.enabled  = false
        badgeNextButton.enabled  = true
        
        reviewCollectionView.contentOffset = CGPointZero
        reviewBackButton.enabled = false
        reviewNextButton.enabled = true
        
        sportsCarousel.type = iCarouselType.Custom
        navigationController?.setStatusBarColor()
        
        if IS_IPHONE6PLUS {
            profileViewHeightConstraint.constant = 260.0
            reviewTopConstraint.constant = 30.0
            reviewBottomConstraint.constant = 30.0
            view.layoutIfNeeded()
        }
    
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
        badgeNextButton.hidden      = false
        badgePrevButton.hidden      = false
        reviewNextButton.superview?.hidden = false
        sendRequestForProfile()
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
    
    @IBAction func editButtonClicked(sender: UIButton) {
        
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
        
    }
    
    @IBAction func notificationsButtonClicked(sender: UIButton) {
        
    }
    
    @IBAction func bioLabelTapped(sender: UITapGestureRecognizer) {
        let custompopController = storyboard?.instantiateViewControllerWithIdentifier("CustomPopupViewController") as! CustomPopupViewController
        custompopController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        custompopController.viewTag = ViewTag.bioText
        custompopController.bioText = "IT IS A LONG ESTABLISHED FACT THAT A READER WILL BE ASSIGNING"
        presentViewController(custompopController, animated: true, completion: nil)
    }
    
    func populateProfileContents() {
        nameLabel.text = appDelegate.user.name
        CustomURLConnection.downloadAndSetImage(appDelegate.user.imageURL!, imageView: userImageView, activityIndicatorView: indicatorView)
        if let bioText = appDelegate.user.bio {
            if count(bioText) > BIOTEXT_LENGTH {
                bioLabel.userInteractionEnabled = true
                attributedBioText((bioText as NSString).substringToIndex(BIOTEXT_LENGTH-1), lengthExceed: true)
            } else {
                bioLabel.userInteractionEnabled = false
                attributedBioText((bioText as NSString).substringToIndex((bioText as NSString).length), lengthExceed: false)
            }
        }
        sportsCarousel.currentItemIndex = 0
        sportsCarousel.reloadData()
        
        if let hours = appDelegate.user.totalHours {
            hoursLabel.text = "\(hours) hours"
        } else {
            hoursLabel.text = "0 hours"
        }
        
        if let count = appDelegate.user.usageCount {
            sessionCountLabel.text = "\(count)"
        } else {
            sessionCountLabel.text = "0"
        }
       
        if let rate = appDelegate.user.rating {
            rateLabel.text = "\(rate)"
            starView.setStarViewValue(rate)
        } else {
            rateLabel.text = "0"
            starView.setStarViewValue(0.0)
        }
        
        if appDelegate.user.availableTimeArray.count <= 3 {
            morebgView.hidden = true
            moreButton.hidden = true
        }
        if appDelegate.user.badgesArray.count <= 3 {
            badgeNextButton.hidden = true
            badgePrevButton.hidden = true
        }
        if appDelegate.user.userReviewsArray.count <= 1 {
            reviewNextButton.superview?.hidden = true
        }
        
        if appDelegate.user.availableTimeArray.count == 0 {
            notimeLabel.hidden = false
            availableTimeCollectionView.hidden = true
        } else {
            availableTimeCollectionView.reloadData()
        }
        
        if appDelegate.user.badgesArray.count == 0 {
            noBadgeLabel.hidden = false
            badgesCollectionView.hidden = true
        } else {
            badgesCollectionView.reloadData()
        }
        
        if appDelegate.user.userReviewsArray.count == 0 {
            noreviewLabel.hidden = false
            reviewCollectionView.hidden = true
        } else {
            reviewCollectionView.reloadData()
        }
    }
    
    
    //MARK: - Profile API
    func sendRequestForProfile() {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        if let id = profileID {
            requestDictionary.setObject(id, forKey: "user_id")
        }
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "profile/profile", requestType: HttpMethod.post), delegate: self, tag: Connection.userProfile)
    }
    
    func parseProfileResponse(responseDictionary: NSDictionary) {
        appDelegate.user.profileID  = responseDictionary["profile_id"] as! Int
        appDelegate.user.name       = responseDictionary["profile_name"] as! String
        appDelegate.user.email      = responseDictionary["email"] as! String
        if let imageUrl = responseDictionary["profile_image"] as? String {
            appDelegate.user.imageURL = imageUrl
        } else {
            appDelegate.user.imageURL = ""
        }
        
        if let bio = responseDictionary["profile_desc"] as? String {
            appDelegate.user.bio = bio
        }
        if let session = responseDictionary["Training_session"] as? NSArray {
            appDelegate.user.availableTimeArray.addObjectsFromArray(session as! [NSDictionary])
        }
        if let usageCount = responseDictionary["usage_count"] as? Int {
            appDelegate.user.usageCount = usageCount
        }
        if let rate = responseDictionary["rating"] as? Float {
            appDelegate.user.rating = rate
        }
        if let badges = responseDictionary["Badges"] as? NSArray {
            appDelegate.user.badgesArray.addObjectsFromArray(badges as! [NSDictionary])
        }
        if let comments = responseDictionary["User_comments"] as? NSArray {
            appDelegate.user.userReviewsArray.addObjectsFromArray(comments as! [NSDictionary])
        }

        if let sportsArray = responseDictionary["Sports_list"] as? NSArray {
            for sports in appDelegate.sportsArray {
                let sport = NSMutableDictionary()
                sport.setObject(sports["id"] as! Int, forKey: "sports_id")
                sport.setObject(sports["title"] as! String, forKey: "sport_name")
                if let logo = sports["logo"] as? String {
                    sport.setObject(logo, forKey: "logo")
                } else {
                    sport.setObject("", forKey: "logo")
                }
                
                if sportsArray.valueForKey("sports_id")!.containsObject(sports["id"] as! Int) {
                    let index = sportsArray.valueForKey("sports_id")?.indexOfObject(sports["id"] as! Int)
                    let dict  = sportsArray.objectAtIndex(index!) as! NSDictionary
                    sport.setObject(dict["expert_level"] as! String, forKey: "expert_level")
                } else {
                    sport.setObject("", forKey: "expert_level")
                }
                appDelegate.user.sportsArray.addObject(sport)
            }
        }
        populateProfileContents()
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
                    parseProfileResponse(jsonResult)
                } else if status == ResponseStatus.error {
                    if let message = jsonResult["message"] as? String {
                        showDismissiveAlertMesssage(message)
                    } else {
                        showDismissiveAlertMesssage(Message.Error)
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
    
    func setExpertiseLevel(level: String) {
        let sports  = appDelegate.user.sportsArray[sportsCarousel.currentItemIndex] as? NSMutableDictionary
        sports!.setObject(level, forKey: "expert_level")
    }
    
    func attributedBioText(bio: String, lengthExceed: Bool) {
        var bioTitle = NSMutableAttributedString(string: "BIO", attributes: [NSFontAttributeName: UIFont(name: "OpenSans", size: 15.0)!, NSForegroundColorAttributeName: AppColor.yellowTextColor])
        bioTitle.appendAttributedString(NSAttributedString(string: ":", attributes: [NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 14.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()]))
        bioTitle.appendAttributedString(NSAttributedString(string: " \(bio)", attributes: [NSFontAttributeName: UIFont(name: "OpenSans-Light", size: 13.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()]))
        if lengthExceed == true {
            bioTitle.appendAttributedString(NSAttributedString(string: "...", attributes: [NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 14.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()]))
        }
        bioLabel.attributedText = bioTitle
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


extension MyProfileViewController: iCarouselDataSource {
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return appDelegate.user.sportsArray.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        var contentView: UIView
        var titleLabel: UILabel
        var sportsImageView: UIImageView
        if view == nil {
            contentView                         = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 78.0, height: carousel.frame.size.height)))
            sportsImageView                     = UIImageView(frame: CGRect(origin: CGPoint(x: 10.0, y: 0.0), size: CGSize(width: carousel.frame.size.height-20.0, height: carousel.frame.size.height-20.0)))
            sportsImageView.contentMode         = .ScaleAspectFit
            sportsImageView.backgroundColor     = UIColor(red: 0, green: 142/255, blue: 130/255, alpha: 1.0)
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
        } else {
            contentView     = view!
            sportsImageView = contentView.viewWithTag(1) as! UIImageView
            titleLabel      = contentView.viewWithTag(2) as! UILabel
        }
        let sports          = appDelegate.user.sportsArray[index] as! NSDictionary
        if index == carousel.currentItemIndex {
            titleLabel.text = sports["sport_name"]!.uppercaseString as String
            if sports["expert_level"] as? String == SportsLevel.beginner {
                beginnerButton.selected = true
            } else if sports["expert_level"] as? String == SportsLevel.moderate {
                moderateButton.selected = true
            } else if sports["expert_level"] as? String == SportsLevel.expert {
                expertButton.selected = true
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
            return appDelegate.user.userReviewsArray.count
        } else if collectionView.isEqual(badgesCollectionView) {
            return appDelegate.user.badgesArray.count
        }
        return appDelegate.user.availableTimeArray.count
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView.isEqual(reviewCollectionView) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("reviewCell", forIndexPath: indexPath) as! UserReviewCollectionViewCell
            let review = appDelegate.user.userReviewsArray[indexPath.row] as! NSDictionary
            cell.reviewView.starView.setStarViewValue(review["user_rating"] as! Float)
            cell.reviewView.reviewTextView.scrollRangeToVisible(NSMakeRange(0, 0))
            cell.reviewView.reviewTextView.text = review["user_review"] as! String
            cell.reviewView.nameLabel.text      = review["profile_name"] as? String
            cell.reviewView.userImageView.backgroundColor = AppColor.statusBarColor
            return cell
        } else if collectionView.isEqual(badgesCollectionView){
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("badgeCell", forIndexPath: indexPath) as! BadgesCollectionViewCell
            let badge = appDelegate.user.badgesArray[indexPath.row] as! NSDictionary
            cell.titleLabel.text = badge["name"] as? String
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("timeCell", forIndexPath: indexPath) as! AvailableTimeCollectionViewCell
            let time = appDelegate.user.availableTimeArray[indexPath.row] as! NSDictionary
            cell.timeLabel.text = Globals.convertTimeTo12Hours((time["time_starts"] as? String)!) 
            return cell
        }
    }
}

extension MyProfileViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView.isEqual(availableTimeCollectionView) {
            let custompopController = storyboard?.instantiateViewControllerWithIdentifier("CustomPopupViewController") as! CustomPopupViewController
            custompopController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            custompopController.viewTag = ViewTag.timeView
            custompopController.timeDictionary = appDelegate.user.availableTimeArray[indexPath.row] as? NSDictionary
            presentViewController(custompopController, animated: true, completion: nil)
        }

    }
}

extension MyProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView.isEqual(reviewCollectionView) {
            return collectionView.frame.size
        } else if collectionView.isEqual(availableTimeCollectionView) {
            return CGSize(width: 60.0, height: 22.0)
        }
        return CGSize(width: (collectionView.frame.size.width-6.0)/3.0, height: ((collectionView.frame.size.width-6.0)/3.0)+10.0)
    }
}