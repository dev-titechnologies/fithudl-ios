//
//  SignupViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 22/09/15.
//  Copyright © 2015 Ti Technologies. All rights reserved.
//

import UIKit
import CoreLocation

class SignupViewController: UIViewController {

    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var femaleYConstraint: NSLayoutConstraint!
    @IBOutlet weak var maleYConstraint: NSLayoutConstraint!
//    @IBOutlet weak var nameViewYConstraint: NSLayoutConstraint!
//    @IBOutlet weak var sportsViewYConstraint: NSLayoutConstraint!
//    @IBOutlet weak var imageViewYConstraint: NSLayoutConstraint!
//    @IBOutlet weak var genderViewYConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var sportsCarousel: iCarousel!
    @IBOutlet weak var beginnerButton: UIButton!
    @IBOutlet weak var moderateButton: UIButton!
    @IBOutlet weak var expertButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    var networkingID: String = "0"
    var twitterName: String?
    var fbUserDictionary: NSDictionary?
    var selectedSportsArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBarHidden = false
        sportsCarousel.type             = .Custom
                
        if appDelegate.sportsArray.count == 0 {
            sportsCarousel.superview?.hidden = true
        }
        
        maleYConstraint.constant   = 0
        femaleYConstraint.constant = 0
        
//        if IS_IPHONE4S {
//            imageViewYConstraint.constant  = 5
//            nameViewYConstraint.constant   = 1
//            sportsViewYConstraint.constant = 1
//            genderViewYConstraint.constant = 3
//            signupButtonHeight.constant    = 40
//        } else if IS_IPHONE6 || IS_IPHONE6PLUS {
//            genderViewYConstraint.constant = 40
//        }
//        view.layoutIfNeeded()
       
        
        let colorAttributes     = [NSForegroundColorAttributeName: AppColor.placeholderText]
        var placeHolderString   = NSAttributedString(string: emailTextField.placeholder!, attributes: colorAttributes)
        emailTextField.attributedPlaceholder = placeHolderString
        
        placeHolderString   = NSAttributedString(string: nameTextField.placeholder!, attributes: colorAttributes)
        nameTextField.attributedPlaceholder = placeHolderString
        
        placeHolderString   = NSAttributedString(string: passwordTextField.placeholder!, attributes: colorAttributes)
        passwordTextField.attributedPlaceholder = placeHolderString
        
        placeHolderString = NSAttributedString(string: confirmPasswordTextField.placeholder!, attributes: colorAttributes)
        confirmPasswordTextField.attributedPlaceholder = placeHolderString
        
        genderButton.layer.borderColor = AppColor.statusBarColor.CGColor
        
        if let fbUser = fbUserDictionary {
            emailTextField.text = fbUser["email"] as! String
            nameTextField.text  = fbUser["name"] as! String
            if let gender = fbUser["gender"] as? String {
                genderButtonClicked(genderButton)
                if gender == Gender.male {
                    maleButtonClicked(maleButton)
                } else if gender == Gender.female {
                    femaleButtonClicked(femaleButton)
                }
            }
        }
        if let name = twitterName {
            nameTextField.text = name
        }
        println("SportslistArray\(appDelegate.sportsArray)")
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways && CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse {
            let alert = UIAlertController(title: alertTitle, message: "Location services are not enabled in this device. Go to Settings > Privacy > Location Services > FitHudl to enable it.", preferredStyle: UIAlertControllerStyle.Alert)
            let settingsAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { (settingsAction) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                return
            })
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (okAction) -> Void in
                return
            })
            alert.addAction(settingsAction)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: false, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        if IS_IPHONE4S || IS_IPHONE5 {
            contentScrollView.contentSize = CGSize(width: contentScrollView.frame.size.width, height: 550.0)
            contentViewHeight.constant = 550.0
        } else {
            contentScrollView.contentSize = CGSize(width: contentScrollView.frame.size.width, height: contentScrollView.frame.size.height)
            contentViewHeight.constant = view.frame.size.height
            signupButton.setTranslatesAutoresizingMaskIntoConstraints(true)
            signupButton.frame = CGRect(origin: CGPoint(x: 10.0, y: view.frame.size.height - 50.0), size: CGSize(width: view.frame.size.width - 20.0, height: signupButton.frame.size.height))
        }
        view.layoutIfNeeded()
    }
    
    
    @IBAction func genderButtonClicked(sender: UIButton) {
        genderButton.selected = !genderButton.selected
        if genderButton.selected {
            UIView.animateWithDuration(animateInterval, animations: { () -> Void in
                self.maleYConstraint.constant   = -40.0
                self.femaleYConstraint.constant = 41.0
                self.view.layoutIfNeeded()
                self.maleButton.hidden   = false
                self.femaleButton.hidden = false
            })
        } else {
            maleButton.selected     = false
            femaleButton.selected   = false
            UIView.animateWithDuration(animateInterval, animations: { () -> Void in
                self.maleYConstraint.constant   = 0
                self.femaleYConstraint.constant = 0
                self.view.layoutIfNeeded()
                self.maleButton.hidden   = true
                self.femaleButton.hidden = true
                }, completion: { (completed) -> Void in
//                    self.maleButton.hidden   = true
//                    self.femaleButton.hidden = true
            })
        }
    }
    
    @IBAction func backButtonClicked(sender: UIButton) {
        sportsCarousel.hidden = true
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func maleButtonClicked(sender: UIButton) {
        Globals.selectButton(maleButton, button2: femaleButton)
    }
    
    @IBAction func femaleButtonClicked(sender: UIButton) {
        Globals.selectButton(femaleButton, button2: maleButton)
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
    
    @IBAction func signupButtonClicked(sender: UIButton) {
        if validateFields() {
            sendSignupRequest()
        }
//        performSegueWithIdentifier("modalSeguetoTab", sender: self)
    }
    
    func validateFields() -> Bool {
        println(nameTextField.text.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " .")))
        if nameTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" || nameTextField.text.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " .")).count <= 1 {
            showDismissiveAlertMesssage("Please enter your full name")
            return false
        }
        if emailTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
            showDismissiveAlertMesssage("Please enter your email ID")
            return false
        } else if !Globals.isValidEmail(emailTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) {
            showDismissiveAlertMesssage("Please enter a valid email ID")
            return false
        }
        if passwordTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
            showDismissiveAlertMesssage("Please provide a password")
            return false
        }
        if confirmPasswordTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
            showDismissiveAlertMesssage("Please confirm your password")
            return false
        } else if passwordTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != confirmPasswordTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()){
            showDismissiveAlertMesssage("Password mismatch. Make sure the passwords are identical.")
            return false
        }
        if !maleButton.selected && !femaleButton.selected {
            showDismissiveAlertMesssage("Please choose your gender")
            return false
        }
        let filteredArray     = appDelegate.sportsArray.filteredArrayUsingPredicate(NSPredicate(format: "level.length > 0"))
        if filteredArray.count == 0 {
            showDismissiveAlertMesssage("Please select sports and your expertise level")
            return false
        }
        return true
    }
    
    func setExpertiseLevel(level: String) {
        let sports          = appDelegate.sportsArray[sportsCarousel.currentItemIndex] as! SportsList
        sports.level        = level
        sports.isSelected   = !sports.isSelected.boolValue
        sportsCarousel.reloadData()
    }
    
    func sendSignupRequest() {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(nameTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), forKey: "name")
        requestDictionary.setObject(emailTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), forKey: "email")
        requestDictionary.setObject(passwordTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), forKey: "password")
        if let location = appDelegate.currentLocation {
            requestDictionary.setObject(location.coordinate.latitude, forKey: "latitude")
            requestDictionary.setObject(location.coordinate.longitude, forKey: "longitude")
        } else {
//            requestDictionary.setObject(37.785834, forKey: "latitude")
//            requestDictionary.setObject(-122.406417, forKey: "longitude")
        }

        if maleButton.selected {
            requestDictionary.setObject(Gender.male, forKey: "gender")
        } else {
            requestDictionary.setObject(Gender.female, forKey: "gender")
        }
        requestDictionary.setObject(networkingID, forKey: "social_networking_id")
        
        let filteredArray     = appDelegate.sportsArray.filteredArrayUsingPredicate(NSPredicate(format: "level.length > 0"))
        if filteredArray.count > 0 {
            let sportsArray = NSMutableArray()
            for sport in filteredArray {
                let sportDictionary = NSMutableDictionary()
                sportDictionary.setObject((sport as! SportsList).sportsId, forKey: "id")
                sportDictionary.setObject((sport as! SportsList).sportsName, forKey: "title")
                sportDictionary.setObject((sport as! SportsList).logo, forKey: "logo")
                sportDictionary.setObject((sport as! SportsList).status, forKey: "status")
                sportDictionary.setObject((sport as! SportsList).level, forKey: "level")
                sportDictionary.setObject((sport as! SportsList).isSelected, forKey: "isSelected")
                sportsArray.addObject(sportDictionary)
            }
            requestDictionary.setObject(sportsArray, forKey: "sportsList")
        }
        
        println("Requset Dict is\(requestDictionary)")
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "user/signup", requestType: HttpMethod.post), delegate: self, tag: Connection.signup)
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
                    if let token = jsonResult["token"] as? String {
                        NSUserDefaults.standardUserDefaults().setObject(token, forKey: "API_TOKEN")
                        performSegueWithIdentifier("modalSeguetoTab", sender: self)
                    }
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

    override func viewWillDisappear(animated: Bool) {
        for sport in appDelegate.sportsArray {
            (sport as! SportsList).level      = ""
            (sport as! SportsList).isSelected = false
        }
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

extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SignupViewController: iCarouselDataSource {
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return appDelegate.sportsArray.count
    }
    
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        var contentView: UIView
        var titleLabel: UILabel
        var sportsImageView: UIImageView
        var indicatorView: UIActivityIndicatorView
        var tickImageView: UIImageView
        
        if view == nil {
            contentView                         = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 70.0, height: carousel.frame.size.height)))
            sportsImageView                     = UIImageView(frame: CGRect(origin: CGPoint(x: 10.0, y: 0.0), size: CGSize(width: carousel.frame.size.height-20.0, height: carousel.frame.size.height-20.0)))
            sportsImageView.contentMode         = .ScaleAspectFit
            sportsImageView.tag                 = 1
            sportsImageView.layer.cornerRadius  = 25.0
            contentView.addSubview(sportsImageView)
            titleLabel           = UILabel(frame: CGRect(x: 0.0, y: sportsImageView.frame.size.height+2.0, width: contentView.frame.size.width, height: 20.0))
            titleLabel.font      = UIFont(name: "OpenSans", size: 13.0)
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.textColor = UIColor.whiteColor()
            titleLabel.textAlignment = NSTextAlignment.Center
            titleLabel.tag       = 2
            contentView.addSubview(titleLabel)
            
            indicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            indicatorView.center = sportsImageView.center
            indicatorView.hidesWhenStopped = true
            indicatorView.tag = 3
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
        
        let sports          = appDelegate.sportsArray[index] as! SportsList
        sportsImageView.image = UIImage(named: "default_image")
        sportsImageView.contentMode = UIViewContentMode.ScaleAspectFit
        CustomURLConnection.downloadAndSetImage(sports.logo, imageView: sportsImageView, activityIndicatorView: indicatorView)
        if index == carousel.currentItemIndex {
            tickImageView.hidden = false
            titleLabel.text = sports.sportsName.uppercaseString as String
            if sports.level == SportsLevel.beginner {
                beginnerButton.selected = true
            } else if sports.level == SportsLevel.moderate {
                moderateButton.selected = true
            } else if sports.level == SportsLevel.expert {
                expertButton.selected = true
            }
        } else {
            titleLabel.text = sports.sportsName
        }
        if sports.isSelected == true{
            tickImageView.hidden = false
        } else {
            tickImageView.hidden = true
        }
        
        return contentView
    }
}

extension SignupViewController: iCarouselDelegate {
    func carousel(carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        let centerItemZoom: CGFloat = 1.3
        let centerItemSpacing: CGFloat = 1.2
        
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
    
