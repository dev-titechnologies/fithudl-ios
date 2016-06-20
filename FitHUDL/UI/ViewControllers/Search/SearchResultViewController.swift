//
//  SearchResultViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 28/10/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class SearchResultViewController: UIViewController {

    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var searchTableView: UITableView!
    var searchResultArray = Array<NSDictionary>()
    var searchIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setStatusBarColor()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
       searchTableView.reloadData()
    }
    
    @IBAction func backBauttonClicked(sender: AnyObject) {
        
        //dismissViewControllerAnimated(true, completion: nil)
        navigationController?.popViewControllerAnimated(true)
        
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
                if status == ResponseStatus.success {
                    let favUser      = searchResultArray[searchIndex]
                    let value: Int   = (favUser["favourite"] as! Int) == 0 ? 1 : 0
                    favUser.setValue(value, forKey: "favourite")
                    searchTableView.reloadData()
                }
                else if status == ResponseStatus.error {
                    if let message = jsonResult["message"] as? String {
                        showDismissiveAlertMesssage(message)
                    } else {
                        showDismissiveAlertMesssage(ErrorMessage.invalid)
                    }
                } else {
                    showLoadingView(false)
                    dismissOnSessionExpire()
                    return
                }

            }
        }
        showLoadingView(false)
    }
    
    func connection(connection: CustomURLConnection, didFailWithError error: NSError) {
        showDismissiveAlertMesssage(error.localizedDescription)
        showLoadingView(false)
    }
    
    func unFavouriteAction(sender:UIButton) {
        searchIndex = sender.tag
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(sender.selected ? 0:1, forKey: "favorite")
        requestDictionary.setObject(self.searchResultArray[sender.tag].objectForKey("id")!, forKey: "trainer_id")
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "favourite/manage", requestType: HttpMethod.post),delegate: self,tag: Connection.unfavourite)
    }
    
    func manageFavorite (notif: NSNotification) {
        let userInfo: NSDictionary  = notif.userInfo!
        let favUser                 = userInfo["user"] as? User
        let filteredArray           = (searchResultArray as NSArray).filteredArrayUsingPredicate(NSPredicate(format: "id = %d", argumentArray: [favUser!.profileID]))
        if filteredArray.count > 0 {
            let user = filteredArray.first as? NSDictionary
            user?.setValue(favUser!.isFavorite, forKey: "favourite")
            (NSMutableArray(array: searchResultArray)).replaceObjectAtIndex(NSMutableArray(array: searchResultArray).indexOfObject(user!), withObject: user!)
            searchTableView.reloadData()
        }
        NSNotificationCenter.defaultCenter().removeObserver(self, name: PushNotification.favNotif, object: nil)
    }
}

extension SearchResultViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchResultArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell                            = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FavouritesListCell
        cell.starView.rating                = 0
        cell.prof_pic.layer.borderWidth     = 1.0
        cell.prof_pic.layer.masksToBounds   = false
        cell.prof_pic.layer.borderColor     = UIColor.clearColor().CGColor
        cell.prof_pic.layer.cornerRadius    = cell.prof_pic.frame.size.height/2
        cell.prof_pic.clipsToBounds         = true
        cell.prof_pic.image                 = UIImage(named: "default_image")
        cell.prof_pic.contentMode           = UIViewContentMode.ScaleAspectFit
        cell.favouriteButton.selected       = false
        if let url = self.searchResultArray[indexPath.row].objectForKey("profile_pic") as? String {
            let imageurl = SERVER_URL.stringByAppendingString(url as String) as NSString
            if imageurl.length != 0 {
                if var imagesArray = Images.fetch(imageurl as String) {
                    let image      = imagesArray[0] as! Images
                    let coverImage = UIImage(data: image.imageData)!
                    cell.prof_pic.contentMode = UIViewContentMode.ScaleAspectFill
                    cell.prof_pic.image = UIImage(data: image.imageData)!
                    cell.indicatorView.stopAnimating()
                } else {
                    if let imageURL = NSURL(string: imageurl as String){
                        let request  = NSURLRequest(URL: imageURL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: TimeOut.Image)
                        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                            if let updatedCell = tableView.cellForRowAtIndexPath(indexPath) as? FavouritesListCell {
                                if error == nil {
                                    let imageFromData:UIImage? = UIImage(data: data)
                                    if let image  = imageFromData {
                                        updatedCell.prof_pic.contentMode = UIViewContentMode.ScaleAspectFill
                                        updatedCell.prof_pic.image = image
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
        }
        
        cell.nameLabel?.text            = searchResultArray[indexPath.row].objectForKey("name") as? String
        let favorite                    = searchResultArray[indexPath.row].objectForKey("favourite") as? Int
        cell.favouriteButton.selected   = favorite == 0 ? false : true
        
        if let ratevalue = self.searchResultArray[indexPath.row].objectForKey("rating_count") as? Float {
            cell.starView.rating = ratevalue
        }
        
        if let session_count = self.searchResultArray[indexPath.row].objectForKey("session") as? Int {
            cell.sessionCounterLabel?.text = "\(session_count)"
        }
        
        cell.favouriteButton.tag = indexPath.row
        cell.favouriteButton.addTarget(self, action: "unFavouriteAction:", forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
}

extension SearchResultViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let userProfile         = storyboard?.instantiateViewControllerWithIdentifier("MyProfileViewController") as! MyProfileViewController
        let id                  = self.searchResultArray[indexPath.row].objectForKey("id") as! Int
        userProfile.profileID   = "\(id)"
        userProfile.searchResultId = "SEARCH"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "manageFavorite:", name: PushNotification.favNotif, object: nil)
        navigationController?.pushViewController(userProfile, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

