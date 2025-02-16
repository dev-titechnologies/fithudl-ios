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
    var favouriteListArray = Array<Favorites>()
    var favouritelistIndex : Int = 0
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
    
    override func viewWillDisappear(animated: Bool) {
        if let loadView = view.viewWithTag(999) {
            showLoadingView(false)
        }
    }
    
    //MARK: - FavouriteList API
    
    func sendRequestToGetFavouriteList() {
        let requestDictionary = NSMutableDictionary()
        if !Globals.checkNetworkConnectivity() {
            if let favList = Favorites.fetchFavorites() {
                favouriteListArray = favList as! Array<Favorites>
                favourite_tableview.reloadData()
            } else {
                showDismissiveAlertMesssage(Message.Offline)
            }
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
                        Favorites.deleteFavorites()
                        favouriteListArray.removeAll(keepCapacity: true)
                        if let favourites = jsonResult["details"] as? NSArray {
                            for favorite in favourites {
                                let fav = Favorites.saveFavorite(Globals.checkIntNull(favorite["id"] as? Int), name: Globals.checkStringNull(favorite["name"] as? String), picURL: Globals.checkStringNull(favorite["profile_pic"] as? String), rate: Globals.checkIntNull(favorite["rating_count"] as? Int), session: Globals.checkIntNull(favorite["session"] as? Int))
                                favouriteListArray.append(fav)
                            }
                            appDelegate.saveContext()
                            nofavourites_label.hidden = true
                        } else {
                            nofavourites_label.hidden = false
                        }
                        favourite_tableview.reloadData()
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

                } else {
                     if status == ResponseStatus.success {
                        favouriteListArray.removeAtIndex(favouritelistIndex)
                        favourite_tableview.reloadData()
                        if (favouriteListArray.count==0) {
                            nofavourites_label.hidden = false
                            
                        } else {
                            nofavourites_label.hidden = true
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
                            dismissOnSessionExpire()
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
    
    func unFavouriteAction(sender:UIButton) {
        favouritelistIndex = sender.tag
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(0, forKey: "favorite")
        requestDictionary.setObject((favouriteListArray[sender.tag] as Favorites).favID, forKey: "trainer_id")
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "favourite/manage", requestType: HttpMethod.post),delegate: self,tag: Connection.unfavourite)
        
    }
}

extension FavoritesViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return favouriteListArray.count;
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
        cell.prof_pic.image = UIImage(named: "default_image")
        cell.prof_pic.contentMode = UIViewContentMode.ScaleAspectFit
        let favorite = favouriteListArray[indexPath.row] as Favorites
        
        let imageurl = SERVER_URL.stringByAppendingString(favorite.profilePic) as NSString
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
       
        cell.nameLabel?.text = favorite.name
        cell.starView.rating = favorite.rateCount.floatValue
        cell.sessionCounterLabel?.text = "\(favorite.session)"
        
        cell.favouriteButton.tag = indexPath.row
        cell.favouriteButton.addTarget(self, action: "unFavouriteAction:", forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
}

extension FavoritesViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let userProfile         = storyboard?.instantiateViewControllerWithIdentifier("MyProfileViewController") as! MyProfileViewController
        let id                  = (favouriteListArray[indexPath.row] as Favorites).favID as! Int
        userProfile.profileID   = "\(id)"
        navigationController?.pushViewController(userProfile, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
