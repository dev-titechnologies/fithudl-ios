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
    var twitterID: Int!
    let faceBookPermissions = ["public_profile", "email"]
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var connectFBButton: UIButton!
    @IBOutlet weak var connectTwitterButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationController?.setStatusBarColor()
        
        if IS_IPHONE4S {
            titleImageView.setTranslatesAutoresizingMaskIntoConstraints(true)
            titleImageView.frame = CGRect(x: (view.frame.size.width-240)/2.0, y: 20.0, width: 240, height: 40)
            bgImageView.setTranslatesAutoresizingMaskIntoConstraints(true)
            bgImageView.frame    = CGRect(x: (view.frame.size.width-250)/2.0, y: 65.0, width: 250, height: 250)
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
                connectTwitterButton.hidden = true
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
                    self.connectTwitterButton.hidden = false
                })
            }
        }
    }
    
    @IBAction func connectWithTwitterClicked(sender: UIButton) {
        let account = ACAccountStore()
        let type    = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        account.requestAccessToAccountsWithType(type, options: nil) { (granted, error) -> Void in
            if error != nil {
                println(error)
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
                    let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: NSURL(string: "https://api.twitter.com/1.1/users/show.json"), parameters: details as [NSObject : AnyObject])
                    request.account = twitterAccount
                    
                    request.performRequestWithHandler({ (responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            println(responseData)
                            println(urlResponse)
                            println(error)
                            if urlResponse.statusCode == 429 {
                                return
                            }
                            if let err = error {
                                return
                            }
                            if let response = responseData {
                                var error: NSError?
                                if let data = NSJSONSerialization.JSONObjectWithData(response, options: NSJSONReadingOptions.MutableLeaves, error: &error) as? NSDictionary{
                                    println(data)
                                    self.twitterID = data["id"] as! Int
                                    self.sendRequestToCheckNewTwitterUser()
                                }
                            }
                        })
                    })
                    println(twitterAccount?.accountDescription)
                    println(twitterAccount?.username)
                    println(twitterAccount?.credential)
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let alert = UIAlertController(title: alertTitle, message: "No twitter accounts configured! Go to settings to configure your account.", preferredStyle: UIAlertControllerStyle.Alert)
                        let settingsAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { (settingsAction) -> Void in
                            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                            return
                        })
                        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (okAction) -> Void in
                            return
                        })
                        alert.addAction(okAction)
                        alert.addAction(settingsAction)
                        self.presentViewController(alert, animated: false, completion: nil)
                    })
                }
            }
        }
    }
    
    @IBAction func connectWithFBClicked(sender: UIButton) {
        if FBSDKAccessToken.currentAccessToken() != nil {
            fbAccessToken   = FBSDKAccessToken.currentAccessToken().tokenString
            fbUserID        = FBSDKAccessToken.currentAccessToken().userID
            getUserData()
            return
        }
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.SystemAccount
        fbLoginManager.logInWithReadPermissions(faceBookPermissions, handler: { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if error != nil {
                fbLoginManager.logOut()
            } else if result.isCancelled {
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
        requestDictionary.setObject(twitterID!, forKey: "twitter_id")
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "user/emailExists", requestType: HttpMethod.post), delegate: self, tag: Connection.checkUser)
    }
    
    func sendRequestToGetSportsList() {
        if !Globals.isInternetConnected() {
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
                        appDelegate.sportsArray.removeAllObjects()
                        if let sportsList = jsonResult["sportsList"] as? NSArray {
                            appDelegate.sportsArray.addObjectsFromArray(sportsList as [AnyObject])
                        }
                    }
                } else {
                    if status == ResponseStatus.success {
                        if let newUser = jsonResult["new_user"] as? Bool {
                            if newUser == true {
                                let signupController = storyboard?.instantiateViewControllerWithIdentifier("SignupViewController") as! SignupViewController
                                if connection.connectionTag == Connection.checkUserFB {
                                    signupController.fbUserDictionary = fbUserDictionary
                                } else {
                                    signupController.twitterID = twitterID
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
