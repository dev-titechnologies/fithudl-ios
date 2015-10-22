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
    let faceBookPermissions = ["public_profile", "email"]
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var connectFBButton: UIButton!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var tosButton: UIButton!
    @IBOutlet weak var contactusButton: UIButton!
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
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
        if let token = NSUserDefaults.standardUserDefaults().objectForKey("API_TOKEN") as? String {
            if token != "" {
                signInButton.hidden = true
                signUpButton.hidden = true
                contactusButton.hidden = true
                tosButton.hidden       = true
                copyrightLabel.hidden  = true
                connectFBButton.hidden = true
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
                    self.signInButton.hidden = false
                    self.signUpButton.hidden = false
                    self.contactusButton.hidden = false
                    self.tosButton.hidden       = false
                    self.copyrightLabel.hidden  = false
                    self.connectFBButton.hidden = false
                })
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
            }
        })
    }
    
    func getUserData() {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, first_name, last_name, email, gender"]).startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                self.fbUserDictionary = result as! NSDictionary
                print(self.fbUserDictionary)
                self.sendRequestToCheckNewUser()
            }
        }
    }
        
    func sendRequestToCheckNewUser() {
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(fbUserDictionary["email"]!, forKey: "email")
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
                                signupController.fbUserDictionary = fbUserDictionary
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
