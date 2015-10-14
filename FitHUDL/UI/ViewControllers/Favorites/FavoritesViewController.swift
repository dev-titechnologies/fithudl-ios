//
//  FavoritesViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 28/09/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    var favouriteList_array = Array<NSDictionary>()
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
                if status == ResponseStatus.success {
                    favouriteList_array = jsonResult["details"] as! Array
                    println(favouriteList_array)
                    favourite_tableview.reloadData()
                }
            }
        }
        showLoadingView(false)
        
    }
    
    func connection(connection: CustomURLConnection, didFailWithError error: NSError) {
        showDismissiveAlertMesssage(error.localizedDescription)
        showLoadingView(false)
    }
}

extension FavoritesViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows in section")
        return self.favouriteList_array.count;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell=tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FavouritesListCell
        cell.starView.setStarViewValue(4.5)
        cell.prof_pic.layer.borderWidth=1.0
        cell.prof_pic.layer.masksToBounds = false
        cell.prof_pic.layer.borderColor = UIColor.clearColor().CGColor
        cell.prof_pic.layer.cornerRadius = cell.prof_pic.frame.size.height/2
        cell.prof_pic.clipsToBounds = true
        cell.nameLabel?.text=self.favouriteList_array[indexPath.row].objectForKey("name") as? String
        cell.starView.setStarViewValue((self.favouriteList_array[indexPath.row].objectForKey("rating_count") as? Float)!)
        cell.sessionCounterLabel?.text=self.favouriteList_array[indexPath.row].objectForKey("rating_count") as? String
        
        return cell
        
        
    }
    
    
}
