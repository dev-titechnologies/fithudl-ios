//
//  SearchViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 28/09/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class SearchViewController: UIViewController,MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    var searchResultArray = Array<NSDictionary>()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var usersListArray = NSMutableArray()
    var searchString:String = ""
    var searchActive : Bool = false
    var filtered = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setStatusBarColor()
        
        
        
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.fetchUserListFromDb()
        
        
        mapView.delegate = self
        
        // self.sendRequestToGetSearchUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchUserListFromDb() {
        
        if var usersArray = UsersList.fetchUsersList() {
            
            var i:Int=0
            for i=0;i<usersArray.count;i++ {
                
                let User      = usersArray[i] as! UsersList
                let userDictionary = NSMutableDictionary()
                userDictionary.setObject(User.userName, forKey: "userName")
                userDictionary.setObject(User.userID, forKey: "userID")
                usersListArray.addObject(userDictionary)
            }
            tableView.reloadData()
            
        }
        
    }
    
    
    //MARK: MKMapView Functions
    
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        
        
        mapView.centerCoordinate = userLocation.location.coordinate
    }
    
}

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(searchActive) {
            return filtered.count
        }
        return usersListArray.count;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell=tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        if(searchActive){
            cell.textLabel?.text = filtered[indexPath.row].objectForKey("userName") as? String
        } else {
            cell.textLabel?.text = usersListArray[indexPath.row].objectForKey("userName") as? String
        }
        return cell
    }
    
}

extension SearchViewController:UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton=true
        searchActive=true
    }
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive=false
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive=false
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton=false
        tableView.hidden=true
        
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive=false
        println("SEARCH button clicked")
        
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchString=searchText
        filtered = NSMutableArray()
        for name in usersListArray {
            let text  = name["userName"] as! NSString
            let range = text.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            if range.location != NSNotFound {
                tableView.hidden=false
                filtered.addObject(name)
            }
            
        }
        
        if(filtered.count == 0){
            tableView.hidden=true
            searchActive = false;
        } else {
            tableView.hidden=false
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    
    //MARK: Serach API CALL
    
    func sendRequestToGetSearchUsers() {
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(searchString, forKey: "search_name")
        
        if !Globals.isInternetConnected() {
            return
        }
        showLoadingView(true)
        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "search/search", requestType: HttpMethod.post),delegate: self,tag: Connection.searchUserName)
        
    }
    
    func connection(connection: CustomURLConnection, didReceiveResponse: NSURLResponse) {
        return connection.receiveData.length=0
    }
    
    func connection(connection: CustomURLConnection, didReceiveData data: NSData) {
        connection.receiveData.appendData(data)
    }
    func connectionDidFinishLoading(connection: CustomURLConnection) {
        var rating_categoryTemp_array = Array<NSDictionary>()
        let response = NSString(data: connection.receiveData, encoding: NSUTF8StringEncoding)
        println("REEEEEE \(response)")
        var error : NSError?
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(connection.receiveData, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
            
            println("search results \(jsonResult)")
            if let status = jsonResult["status"] as? Int {
                if connection.connectionTag == Connection.ratecategory {
                    if status == ResponseStatus.success {
                        
                    }
                    else
                        if status == ResponseStatus.error {
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
    
}

