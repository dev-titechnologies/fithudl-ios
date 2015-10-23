//
//  SearchViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 28/09/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var usersListArray = NSMutableArray()

    var searchActive : Bool = false
   // var data = ["San Francisco","New York","San Jose","Chicago","Los Angeles","Austin","Seattle"]
    var filtered = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setStatusBarColor()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.fetchUserListFromDb()
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

    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive=false
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        for name in usersListArray {
            let text  = name["userName"] as! NSString
            let range = text.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            if range.location != NSNotFound {
                filtered.addObject(name)
            }
            
        }
        
//        filtered = usersListArray. .filter({ (text) -> Bool in
//            let tmp: NSString = text
//            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
//            return range.location != NSNotFound
//        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }

}
