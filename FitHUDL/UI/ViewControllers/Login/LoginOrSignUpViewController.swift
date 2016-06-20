//
//  LoginOrSignUpViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 22/09/15.
//  Copyright © 2015 Ti Technologies. All rights reserved.
//

import UIKit

class LoginOrSignUpViewController: UIViewController {
    var fbAccessToken: String!
    var fbUserID: String!
    var fbUserDictionary: NSDictionary!
    var twitterID: String!
    var twitterName: String!
    let faceBookPermissions = ["public_profile", "email"]
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var connectFBButton: UIButton!
    @IBOutlet weak var connectTwitterButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    
    @IBOutlet weak var privacyBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var termsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fbTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var signupTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationController?.setStatusBarColor()
        
        if IS_IPHONE4S {
            titleImageView.setTranslatesAutoresizingMaskIntoConstraints(true)
            titleImageView.frame = CGRect(x: (view.frame.size.width-240)/2.0, y: 20.0, width: 240, height: 40)
            bgImageView.setTranslatesAutoresizingMaskIntoConstraints(true)
            bgImageView.frame    = CGRect(x: (view.frame.size.width-250)/2.0, y: 65.0, width: 250, height: 250)
        }
        if IS_IPHONE6PLUS {
            logoTopConstraint.constant          = 15
            bgTopConstraint.constant            = 25
            signupTopConstraint.constant        = 20
            fbTopConstraint.constant            = 15
            bottomViewHeightConstraint.constant = 70
            labelBottomConstraint.constant      = 15
            termsBottomConstraint.constant      = 0
            privacyBottomConstraint.constant    = 0
            view.layoutIfNeeded()
        }
        
        if let token = appDelegate.deviceToken {
            
        } else {
            appDelegate.deviceToken = NSUserDefaults.standardUserDefaults().objectForKey("deviceToken") as? String
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
        if let token = NSUserDefaults.standardUserDefaults().objectForKey("API_TOKEN") as? String {
            if token != "" {
                signInButton.hidden = true
                signUpButton.hidden = true
                bottomView.hidden   = true
                connectFBButton.hidden = true
               // connectTwitterButton.hidden = true
            }
        }
        sendRequestToGetSportsList()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if let token = NSUserDefaults.standardUserDefaults().objectForKey("API_TOKEN") as? String {
            if token != "" {
                let mainTabController = storyboard?.instantiateViewControllerWithIdentifier("MainTabbarViewController") as! MainTabbarViewController
                presentViewController(mainTabController, animated: true, completion: { () -> Void in
                    self.navigationController?.navigationBarHidden = false
                    self.signInButton.hidden    = false
                    self.signUpButton.hidden    = false
                    self.bottomView.hidden      = false
                    self.connectFBButton.hidden = false
                    //self.connectTwitterButton.hidden = false
                })
            }
        }
    }
    
    @IBAction func termsButtonClicked(sender: UIButton) {
        performSegueWithIdentifier("modalSegueToWebView", sender: sender)
    }
    
    @IBAction func privacyButtonClicked(sender: UIButton) {
        performSegueWithIdentifier("modalSegueToWebView", sender: sender)
    }
    
    @IBAction func connectWithTwitterClicked(sender: UIButton) {
        showLoadingView(true)
        let account = ACAccountStore()
        let type    = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        account.requestAccessToAccountsWithType(type, options: nil) { (granted, error) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.showLoadingView(false)
                    self.showDismissiveAlertMesssage(error.localizedDescription)
                })
                return
            }
            if granted {
                let accountsArray = account.accountsWithAccountType(type) as! [ACAccount]
                if accountsArray.count > 0 {
                    let twitterAccount = accountsArray.last
                    let properties = twitterAccount!.dictionaryWithValuesForKeys(["properties"])
                    println(properties)
                    let details = properties["properties"] as! NSDictionary
                    println(details)
                    self.twitterID   = details["user_id"] as! String
                    if let account = twitterAccount {
                        self.twitterName = account.userFullName
                    }
                    let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: NSURL(string: "https://api.twitter.com/1.1/users/show.json"), parameters: details as [NSObject : AnyObject])
                    request.account = twitterAccount
                    
                    request.performRequestWithHandler({ (responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.showLoadingView(false)
                            println(responseData)
                            println(urlResponse)
                            println(error)
                            if let err = error {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.sendRequestToCheckNewTwitterUser()
                                })
                                return
                            }
                            if urlResponse.statusCode == 429 {
                                return
                            }
                            if let response = responseData {
                                var error: NSError?
                                if let data = NSJSONSerialization.JSONObjectWithData(response, options: NSJSONReadingOptions.MutableLeaves, error: &error) as? NSDictionary{
                                    println(data)
                                    self.twitterName = data["name"] as! String
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.sendRequestToCheckNewTwitterUser()
                                    })
                                }
                            }
                        })
                    })
                    println(twitterAccount?.accountDescription)
                    println(twitterAccount?.username)
                    println(twitterAccount?.credential)
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let alert = UIAlertController(title: alertTitle, message: "No twitter accounts configured! Go to Settings > Twitter to configure your account.", preferredStyle: UIAlertControllerStyle.Alert)
                        let settingsAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { (settingsAction) -> Void in
                            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                            return
                        })
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (okAction) -> Void in
                            return
                        })
                        alert.addAction(settingsAction)
                        alert.addAction(okAction)
                        self.presentViewController(alert, animated: false, completion: nil)
                    })
                }
            }
        }
    }
    
    @IBAction func connectWithFBClicked(sender: UIButton) {
        showLoadingView(true)
        if FBSDKAccessToken.currentAccessToken() != nil {
            fbAccessToken   = FBSDKAccessToken.currentAccessToken().tokenString
            fbUserID        = FBSDKAccessToken.currentAccessToken().userID
            showLoadingView(false)
            getUserData()
            return
        }
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.SystemAccount
        fbLoginManager.logInWithReadPermissions(faceBookPermissions, handler: { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            self.showLoadingView(false)
            println("FB RESULT \(result)")
            if error != nil {
                UIAlertView(title: alertTitle, message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
                fbLoginManager.logOut()
            } else if result.isCancelled {
                UIAlertView(title: alertTitle, message: "Login was cancelled by the user", delegate: nil, cancelButtonTitle: "OK").show()
                fbLoginManager.logOut()
            } else {
                var allPermsGranted = true
                
                let grantedPermissions = result.grantedPermissions
                for permission in self.faceBookPermissions {
                    if !contains(grantedPermissions, permission) {
                        allPermsGranted = false
                        break
                    }
                }
                if allPermsGranted {
                    self.fbAccessToken  = result.token.tokenString
                    self.fbUserID       = result.token.userID
                    self.getUserData()
                }
                fbLoginManager.logOut()
            }
        })
    }
    
    func getUserData() {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, first_name, last_name, email, gender"]).startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                self.fbUserDictionary = result as? NSDictionary
                print(self.fbUserDictionary)
                if let email = self.fbUserDictionary["email"] as? String {
                    self.sendRequestToCheckNewFBUser()
                } else {
                    self.showDismissiveAlertMesssage("Failed to retrieve your email!")
                }
            }
        }
    }
        
    func sendRequestToCheckNewFBUser() {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(fbUserDictionary["email"]!, forKey: "email")
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "user/emailExists", requestType: HttpMethod.post), delegate: self, tag: Connection.checkUserFB)
    }
    
    func sendRequestToCheckNewTwitterUser() {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(twitterID, forKey: "twitter_id")
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "user/emailExists", requestType: HttpMethod.post), delegate: self, tag: Connection.checkUser)
    }
    
    func sendRequestToGetSportsList() {
        if !Globals.checkNetworkConnectivity() {
            if let sportsArray = SportsList.fetchSportsList() {
                appDelegate.sportsArray.removeAllObjects()
                appDelegate.sportsArray.addObjectsFromArray(sportsArray as! [SportsList])
            } else {
                showDismissiveAlertMesssage(Message.Offline)
            }
            return
        }
        CustomURLConnection(request: CustomURLConnection.createRequest(nil, methodName: "sports/list", requestType: HttpMethod.get), delegate: self, tag: Connection.sportsList)
    }
    
    func connection(connection: CustomURLConnection, didReceiveResponse: NSURLResponse) {
        connection.receiveData.length = 0
        
    }
    
    func connection(connection: CustomURLConnection, didReceiveData data: NSData) {
        connection.receiveData.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: CustomURLConnection) {
        let responseString = NSString(data: connection.receiveData, encoding: NSUTF8StringEncoding)
        println(responseString)
        var error: NSError?
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(connection.receiveData, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
            if let status = jsonResult["status"] as? Int {
                if connection.connectionTag == Connection.sportsList {
                    if status == ResponseStatus.success {
                        SportsList.deleteSportsList()
                        appDelegate.sportsArray.removeAllObjects()
                        if let sportsList = jsonResult["sportsList"] as? NSArray {
                            for sports in sportsList {
                                SportsList.saveSportsList(sports["id"] as! Int, spName: sports["title"] as! String, status: sports["status"] as! Int, logo: sports["logo"] as! String, level: "")
                            }
                            if let sportsArray = SportsList.fetchSportsList() as? [SportsList]{
                                appDelegate.sportsArray.addObjectsFromArray(sportsArray)
                            }
                            NSNotificationCenter.defaultCenter().postNotificationName(PushNotification.sportsList, object: nil, userInfo: ["success" : true])
                        }
                    } else {
                        NSNotificationCenter.defaultCenter().postNotificationName(PushNotification.sportsList, object: nil, userInfo: ["success" : false])
                    }
                } else {
                    if status == ResponseStatus.success {
                        if let newUser = jsonResult["new_user"] as? Bool {
                            if newUser == true {
                                let signupController = storyboard?.instantiateViewControllerWithIdentifier("SignupViewController") as! SignupViewController
                                if connection.connectionTag == Connection.checkUserFB {
                                    signupController.fbUserDictionary = fbUserDictionary
                                    signupController.networkingID = fbUserID
                                } else {
                                    signupController.networkingID = twitterID
                                    signupController.twitterName  = twitterName
                                }
                                navigationController?.pushViewController(signupController, animated: true)
                            } else {
                                if let token = jsonResult["token"] as? String {
                                    NSUserDefaults.standardUserDefaults().setObject(token, forKey: "API_TOKEN")
                                    performSegueWithIdentifier("modalSeguetoTab", sender: self)
                                }
                            }
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
        }
        showLoadingView(false)
    }
    
    func connection(connection: CustomURLConnection, didFailWithError error: NSError) {
        showLoadingView(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "modalSegueToWebView" {
            let navController = segue.destinationViewController as! UINavigationController
            let webController = navController.topViewController as! WebViewController
            if sender as! UIButton == termsButton {
                webController.viewTag = ViewTag.termsView
            } else {
                webController.viewTag = ViewTag.privacyView
            }
        }

    }
}
