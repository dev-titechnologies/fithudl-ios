//
//  FavoritesViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 28/09/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var nofavourites_label: UILabel!
    var favouriteList_array = Array<NSDictionary>()
    var favouritelist_index : Int = 0
    @IBOutlet weak var favourite_tableview: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setStatusBarColor()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        sendRequestToGetFavouriteList()
    }
    
    
    //MARK: - FavouriteList API
    
    func sendRequestToGetFavouriteList() {
        let requestDictionary = NSMutableDictionary()
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "favourite/favoritesList", requestType: HttpMethod.post),delegate: self,tag: Connection.favouriteList)
    }
    
    func connection(connection: CustomURLConnection, didReceiveResponse: NSURLResponse) {
        return connection.receiveData.length=0
    }
    
    func connection(connection: CustomURLConnection, didReceiveData data: NSData) {
        connection.receiveData.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: CustomURLConnection) {
        
        let response = NSString(data: connection.receiveData, encoding: NSUTF8StringEncoding)
        println(response)
        var error : NSError?
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(connection.receiveData, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
            if let status = jsonResult["status"] as? Int {
                if connection.connectionTag == Connection.favouriteList {
                    if status == ResponseStatus.success {
                        if let favourites = jsonResult["details"] as? NSArray {
                            favouriteList_array = favourites as! Array
                            println(favouriteList_array)
                            favourite_tableview.reloadData()
                        }
                        else {
                            println("dfdsfdsfdf")
                            nofavourites_label.hidden=false
                        }
                        

                    }
                    else if status == ResponseStatus.error {
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
                else {
                    
                     if status == ResponseStatus.success {
                        favouriteList_array.removeAtIndex(favouritelist_index)
                        favourite_tableview.reloadData()
                        if (favouriteList_array.count==0) {
                            nofavourites_label.hidden=false
                            
                        }
                        
                    }
                     else if status == ResponseStatus.error {
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
        showDismissiveAlertMesssage(error.localizedDescription)
        showLoadingView(false)
    }
    
    func UnFavouriteAction(sender:UIButton) {
        
        favouritelist_index = sender.tag
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(0, forKey: "favorite")
        requestDictionary.setObject(self.favouriteList_array[sender.tag].objectForKey("id")!, forKey: "trainer_id")
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "favourite/manage", requestType: HttpMethod.post),delegate: self,tag: Connection.unfavourite)
        
    }
}

extension FavoritesViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return self.favouriteList_array.count;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell=tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FavouritesListCell
        cell.starView.rating = 0
        cell.prof_pic.layer.borderWidth=1.0
        cell.prof_pic.layer.masksToBounds = false
        cell.prof_pic.layer.borderColor = UIColor.clearColor().CGColor
        cell.prof_pic.layer.cornerRadius = cell.prof_pic.frame.size.height/2
        cell.prof_pic.clipsToBounds = true
        
        if let url = self.favouriteList_array[indexPath.row].objectForKey("profile_pic") as? String {
            CustomURLConnection.downloadAndSetImage(url, imageView: cell.prof_pic, activityIndicatorView: cell.indicatorView)
        } else {
            CustomURLConnection.downloadAndSetImage("", imageView: cell.prof_pic, activityIndicatorView: cell.indicatorView)
        }

        cell.nameLabel?.text=self.favouriteList_array[indexPath.row].objectForKey("name") as? String
        if let ratevalue = self.favouriteList_array[indexPath.row].objectForKey("rating_count") as? Float {
            cell.starView.rating = ratevalue
        }
        
        if let session_count = self.favouriteList_array[indexPath.row].objectForKey("rating_count") as? Int {
            cell.sessionCounterLabel?.text=String(session_count)
        }
        
        cell.favouriteButton.tag=indexPath.row
        
        cell.favouriteButton.addTarget(self, action: "UnFavouriteAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
}

extension FavoritesViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let userProfile         = storyboard?.instantiateViewControllerWithIdentifier("MyProfileViewController") as! MyProfileViewController
        userProfile.profileID   = String(stringInterpolationSegment: self.favouriteList_array[indexPath.row].objectForKey("id") as? Int)
        navigationController?.pushViewController(userProfile, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
