//
//  CustomPopupViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 01/10/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

protocol ConfirmBookDelegate {
    func confirmSessionBook()
}

class CustomPopupViewController: UIViewController {

    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var bioView: UIView!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var timeOkButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeTitleLabel: UILabel!
    @IBOutlet weak var timeMsgLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var weekValueLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var timeValueLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var sportsLabel: UILabel!
    @IBOutlet weak var sportsImageView: UIImageView!
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var confirmView: UIView!
    
    @IBOutlet weak var updateButton: UIButton!
//    @IBOutlet weak var closeButton: UIButton!
    var delegate:ConfirmBookDelegate?
    var viewTag = 0
    var bioText: String?
    var timeDictionary: NSDictionary?
    var sessionDictionary: NSMutableDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bioView.hidden  = true
        timeView.hidden = true
        confirmView.hidden = true
        
        bioView.layer.cornerRadius  = 10.0
        timeView.layer.cornerRadius = 10.0
        
        timeOkButton.layer.cornerRadius = 23.0
        timeOkButton.layer.borderWidth  = 2.0
        timeOkButton.layer.borderColor  = AppColor.statusBarColor.CGColor
        
        bookButton.layer.borderColor    = AppColor.statusBarColor.CGColor
        bookButton.layer.borderWidth    = 1.0
        
        switch (viewTag) {
        case ViewTag.bioText:
            bioView.hidden      = false
            if bioText == "" {
                updateButton.hidden  = false
                updateButton.layer.borderColor = UIColor.whiteColor().CGColor
                bioTextView.editable = true
                bioTextView.becomeFirstResponder()
            } else {
                updateButton.hidden  = true
                bioTextView.editable = false
                bioTextView.setTranslatesAutoresizingMaskIntoConstraints(true)
                bioTextView.frame    = CGRect(origin: CGPointZero, size: CGSize(width: bioView.frame.size.width, height: bioView.frame.size.height))
            }
            
            attributedBioText()
        case ViewTag.timeView:
            timeView.hidden = false
            setValueForTimeView()
        case ViewTag.bookView:
            confirmView.hidden = false
            setUpBookConfirmView()
        default:
            timeView.hidden = false
        }

        // Do any additional setup after loading the view.
    }

    func setValueForTimeView() {
        if let time = timeDictionary {
            timeLabel.text = time["time"] as? String
            if time["disabled"] as? Bool == true {
                timeTitleLabel.text = "Activate the time"
                timeMsgLabel.text   = "By clicking OK you will be activating your time"
            } else {
                timeTitleLabel.text = "Deactivate the time"
                timeMsgLabel.text   = "By clicking OK you will be deactivating your time"
            }
        }
    }
    
    func sendRequestToEditProfile() {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject((bioTextView.text as NSString).substringWithRange(NSMakeRange(4, count(bioTextView.text)-4)), forKey: "bio")
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "user/editProfile", requestType: HttpMethod.post), delegate: self, tag: Connection.userProfile)
    }

    
    func setUpBookConfirmView() {
        let predicate       = NSPredicate(format: "sportsId = %d", argumentArray: [sessionDictionary!["sports_id"] as! Int])
        let filteredArray   = appDelegate.sportsArray.filteredArrayUsingPredicate(predicate)
        sportsImageView.image = UIImage(named: "default_image")
        sportsImageView.contentMode = UIViewContentMode.ScaleAspectFit
        if filteredArray.count > 0 {
            let imageURL    = (filteredArray[0] as! SportsList).logo
            CustomURLConnection.downloadAndSetImage(imageURL, imageView: sportsImageView, activityIndicatorView: indicatorView)
            let sportName   = (filteredArray[0] as! SportsList).sportsName.uppercaseString
            sportsLabel.text = "\(sportName) session on"
        }
        nameLabel.text      = appDelegate.user!.name.uppercaseString
        let startTime       = Globals.convertTimeTo12Hours(sessionDictionary!["start_time"] as! String)
        let endTime         = Globals.convertTimeTo12Hours(sessionDictionary!["end_time"] as! String)
        timeValueLabel.text = "\(startTime) to \(endTime)"
        placeLabel.text     = sessionDictionary!["location"] as? String
        weekValueLabel.text = "No"
    }
    
    func attributedBioText() {
        var bioTitle = NSMutableAttributedString(string: "BIO", attributes: [NSFontAttributeName: UIFont(name: "OpenSans", size: 14.0)!, NSForegroundColorAttributeName: AppColor.yellowTextColor])
        bioTitle.appendAttributedString(NSAttributedString(string: ":", attributes: [NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 14.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()]))
        bioTitle.appendAttributedString(NSAttributedString(string: " \(bioText!)", attributes: [NSFontAttributeName: UIFont(name: "OpenSans-Light", size: 13.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()]))
        bioTextView.attributedText = bioTitle
    }
    
    @IBAction func updateBioClicked(sender: UIButton) {
        if count(bioTextView.text) > 5 {
            sendRequestToEditProfile()
        } else {
            showDismissiveAlertMesssage("Please enter your profile description")
        }
    }
    
    @IBAction func timeOkButtonClicked(sender: UIButton) {

    }
    
    @IBAction func bookButtonClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
        delegate?.confirmSessionBook()
    }
    
    @IBAction func weeklyButtonClicked(sender: UIButton) {
        sender.selected     = !sender.selected
        weekValueLabel.text = sender.selected ? "Yes" : "No"
    }
    
    @IBAction func stopBookButtonClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func closeButtonClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    appDelegate.user!.bio = (bioTextView.text as NSString).substringWithRange(NSMakeRange(4, count(bioTextView.text)-4))
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CustomPopupViewController: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        if text == "" {
            if range.location <= 4 {
                return false
            }
            return true
        }
        return count(textView.text) + (count(text) - range.length) <= BIOLIMIT
    }
}

