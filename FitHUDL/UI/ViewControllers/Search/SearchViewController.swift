//
//  SearchViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 28/09/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit
import MapKit

class SearchViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate{
    
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var searchItemsContainerView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var uiSlider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var sportsCarousel: iCarousel!
    @IBOutlet weak var expertButton: UIButton!
    @IBOutlet weak var moderateButton: UIButton!
    @IBOutlet weak var beginnerButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var user: User!
    
    @IBOutlet weak var allSportsCollectionView: UICollectionView!
    @IBOutlet weak var allSportsView: UIView!
    var selectedIndexArray  = NSMutableArray()
    var usersListArray      = NSMutableArray()
    var searchString:String = ""
    var searchActive : Bool = false
    var filtered            = NSMutableArray()
    var allSportsArray      = NSMutableArray()
    var searchResultArray   = Array<NSDictionary>()
    var sliderValue:Int     = 10
    var expertFlag:Bool     = false
    var userSelectedArray   = NSMutableArray()
    var count:Int           = 0
    var point: MKPointAnnotation! = MKPointAnnotation()
    var mapViewTouchFlag : Bool = false
    var nameSearchFlag   : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       

        
        navigationController?.setStatusBarColor()
        selectedIndexArray              = NSMutableArray()
        allSportsArray.addObjectsFromArray(appDelegate.sportsArray as [AnyObject])
        for userSports in allSportsArray {
            (userSports as! SportsList).level = "NO"
        }
        sportsCarousel.type             = iCarouselType.Custom
        sportsCarousel.currentItemIndex = 0

        tableView.layer.cornerRadius    = 4.0
        tableView.layer.borderColor     = UIColor.lightGrayColor().CGColor
        userSelectedArray               = NSMutableArray()
        let searchField                 = searchBar.valueForKey("searchField") as? UITextField
        searchField?.textColor          = UIColor.whiteColor()
        searchButton.enabled            = false
        moderateButton.superview?.hidden = true
    }
    
    func mapViewTouch(gestureRecognizer: UITapGestureRecognizer){
        self.mapViewTouchFlag = true
        let annotationsToRemove = mapView.annotations.filter { $0 !== self.mapView.userLocation }
        mapView.removeAnnotations(annotationsToRemove)
        let touchLocation       = gestureRecognizer.locationInView(mapView)
        let locationCoordinate  = mapView.convertPoint(touchLocation, toCoordinateFromView: mapView)
        self.point              = MKPointAnnotation()
        self.point.coordinate   = locationCoordinate
        mapView.addAnnotation(self.point)
        
        var location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(locationMark, error) -> Void in
            if error != nil {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            if locationMark.count > 0 {
                let locationmark = locationMark[0] as! CLPlacemark
                println("GEOO\(locationmark.locality)")
                self.locationName.text = locationmark.locality
            } else {
                println("Problem with the data received from geocoder")
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
            appDelegate.locationManager.requestWhenInUseAuthorization()
            appDelegate.locationManager.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways && CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse {
            let alert = UIAlertController(title: alertTitle, message: "Location services are not enabled in this device. Go to Settings > Privacy > Location Services > FitHudl to enable it.", preferredStyle: UIAlertControllerStyle.Alert)
            let settingsAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { (settingsAction) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                return
            })
            alert.addAction(settingsAction)
            self.presentViewController(alert, animated: false, completion: nil)
        }
        userSelectedArray.removeAllObjects()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentLocationInMap", name: "showLocation", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        println("View DidAppear SEARCH")
        currentLocationInMap()
        var tapGesture      = UITapGestureRecognizer(target: self, action: "mapViewTouch:")
        self.mapView.addGestureRecognizer(tapGesture)
        self.fetchUserListFromDb()
        filtered            = NSMutableArray()
        mapView.delegate    = self
        searchButton.layer.cornerRadius = searchButton.frame.size.height/2
        searchButton.layer.borderColor  = AppColor.statusBarColor.CGColor
        searchButton.layer.borderWidth  = 1.0
        searchButton.backgroundColor    = UIColor.clearColor()
        count = 0
    }
    
    func currentLocationInMap() {
        let annotationsToRemove   = mapView.annotations.filter { $0 !== self.mapView.userLocation }
        mapView.removeAnnotations(annotationsToRemove)
        mapView.showsUserLocation = true
        if let currentLocation = appDelegate.currentLocation {
            let center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapView.setRegion(region, animated: true)
            
            CLGeocoder().reverseGeocodeLocation(appDelegate.locationManager.location, completionHandler: { (placemarks, error) -> Void in
                if (error != nil) {
                    println("Error:" + error.localizedDescription)
                    return
                }
                if placemarks.count > 0 {
                    if !self.mapViewTouchFlag {
                        println("setting map pin image")
                        let pm                  = placemarks[0] as! CLPlacemark
                        self.point              = MKPointAnnotation()
                        self.point.coordinate   = appDelegate.currentLocation!.coordinate
                        self.point.title        = pm.locality
                        self.locationName.text  = pm.locality
                        self.point.subtitle     = pm.administrativeArea
                        self.mapView.addAnnotation(self.point)
                    }
                } else {
                    println("Error with data")
                }
            })
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        allSportsArray.removeAllObjects()
        allSportsArray.addObjectsFromArray(appDelegate.sportsArray as [AnyObject])
        for userSports in allSportsArray {
            (userSports as! SportsList).level = "NO"
        }
        self.sportsCarousel.reloadData()
        searchActive     = false
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        searchBar.text   = ""
        tableView.hidden = true
        self.mapViewTouchFlag = false
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "showLocation", object: nil)
        if let loadView = view.viewWithTag(999) {
            showLoadingView(false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchUserListFromDb() {
        
        if var usersArray = UsersList.fetchUsersList() {
            
          usersListArray = NSMutableArray()
            
            var i:Int = 0
            for i=0; i<usersArray.count; i++ {
                let User      = usersArray[i] as! UsersList
                let searchUserId:Int? = User.userID.toInt()
                if let currentUser = appDelegate.user {
                    if currentUser.profileID as Int != searchUserId {
                        let userDictionary = NSMutableDictionary()
                        userDictionary.setObject(User.userName, forKey: "userName")
                        userDictionary.setObject(User.userID, forKey: "userID")
                        usersListArray.addObject(userDictionary)
                    }
                }
            }
            tableView.reloadData()
        }
    }
    
    @IBAction func maleButtonClicked(sender: UIButton) {
        maleButton.selected = !maleButton.selected
    }
    
    
    @IBAction func femaleButtonClicked(sender: UIButton) {
        femaleButton.selected = !femaleButton.selected
    }
    
    @IBAction func beginnerButtonClicked(sender: UIButton) {
        expertFlag=true
        Globals.selectButton([beginnerButton, moderateButton, expertButton], selectButton: beginnerButton)
        beginnerButton.selected == true ? setExpertiseLevel(SportsLevel.beginner) : setExpertiseLevel("")
    }
    
    @IBAction func moderateButtonClicked(sender: UIButton) {
        expertFlag=true
        Globals.selectButton([beginnerButton, moderateButton, expertButton], selectButton: moderateButton)
        moderateButton.selected == true ? setExpertiseLevel(SportsLevel.moderate) : setExpertiseLevel("")
    }
    
    @IBAction func expertButtonClicked(sender: UIButton) {
        expertFlag=true
        Globals.selectButton([beginnerButton, moderateButton, expertButton], selectButton: expertButton)
        expertButton.selected == true ? setExpertiseLevel(SportsLevel.expert) : setExpertiseLevel("")
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        var currentValue = Int(sender.value)
        sliderValue = currentValue
        var sliderDistacce = "\(currentValue)"
        var sliderMiles = " Miles"
        distanceLabel.text = sliderDistacce+sliderMiles
    }
    
    @IBAction func viewAllButtonClicked(sender: UIButton) {
        allSportsCollectionView.reloadData()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.allSportsView.alpha = 1.0
        })
    }
    
    @IBAction func upArrowAction(sender: AnyObject) {
        let arrowButton = sender as! UIButton
        searchItemsContainerView.setTranslatesAutoresizingMaskIntoConstraints(true)
        if arrowButton.selected == false {
            UIView.animateWithDuration(animateInterval, animations: { () -> Void in
                self.searchItemsContainerView.frame = CGRect(x: self.searchItemsContainerView.frame.origin.x, y: self.view.frame.size.height-self.searchItemsContainerView.frame.size.height, width: self.searchItemsContainerView.frame.size.width, height: self.searchItemsContainerView.frame.size.height)
            })
        } else {
            UIView.animateWithDuration(animateInterval, animations: { () -> Void in
                self.searchItemsContainerView.frame = CGRect(x: self.searchItemsContainerView.frame.origin.x, y: self.view.frame.size.height-75.0, width: self.searchItemsContainerView.frame.size.width, height: self.searchItemsContainerView.frame.size.height)
            })
        }
        arrowButton.selected = !arrowButton.selected
    }
    
    func setExpertiseLevel(level: String) {
        if userSelectedArray.valueForKey("sportsId")!.containsObject(allSportsArray.objectAtIndex(sportsCarousel.currentItemIndex).valueForKey("sportsId") as! Int){
            var indexValue = userSelectedArray.valueForKey("sportsId")?.indexOfObject(allSportsArray.objectAtIndex(sportsCarousel.currentItemIndex).valueForKey("sportsId") as! Int)
            userSelectedArray.removeObjectAtIndex(indexValue!)
        }
        let userSport   = allSportsArray[sportsCarousel.currentItemIndex] as! SportsList
        userSport.level = level
        userSelectedArray.addObject(userSport)
    }

    //MARK: MKMapView Functions
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is MKUserLocation) {
            //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
            //return nil so map draws default view for it (eg. blue dot)....
            return nil
        }
        
        let reuseId = "test"
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView.image = UIImage(named:"map-pointer.png")
            anView.canShowCallout = false
        } else {
            anView.annotation = annotation
        }
        return anView
    }
    
    @IBAction func viewAllCloseButtonClicked(sender: UIButton) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.allSportsView.alpha = 0.0
        })
        if userSelectedArray.count > 0 {
            moderateButton.superview?.hidden = false
            searchButton.enabled             = true
        } else {
            moderateButton.superview?.hidden = true
            searchButton.enabled             = false
        }
        sportsCarousel.reloadData()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "searchToSearchResult" {
            var DestViewController = segue.destinationViewController as! SearchResultViewController
            DestViewController.searchResultArray = searchResultArray
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
        let cell                 = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.font     = UIFont(name: "Open Sans",size: 15.0)
        if(searchActive){
            cell.textLabel?.text = filtered[indexPath.row].objectForKey("userName") as? String
        } else {
            cell.textLabel?.text = usersListArray[indexPath.row].objectForKey("userName") as? String
        }
        return cell
    }
    
}
extension SearchViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let userProfile         = storyboard?.instantiateViewControllerWithIdentifier("MyProfileViewController") as! MyProfileViewController
       let id                   = self.filtered[indexPath.row].objectForKey("userID") as! String
        userProfile.profileID   = "\(id)"
        navigationController?.pushViewController(userProfile, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        searchBar.text          = ""
        searchBar.resignFirstResponder()
        tableView.hidden        = true
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
        searchBar.text=""
        tableView.hidden=true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.nameSearchFlag = true
        searchActive       = false
        searchBar.resignFirstResponder()
        tableView.hidden   = true
        searchBar.showsCancelButton = false
        searchBar.text      = ""
        self.sendRequestToGetSearchUsers()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
        filtered     = NSMutableArray()
        for name in usersListArray {
            let text  = name["userName"] as! NSString
            let range = text.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            if range.location != NSNotFound {
                tableView.hidden=false
               // searchItemsContainerView.hidden=true
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
    
    @IBAction func searchButtonClicked(sender: AnyObject) {
        self.sendRequestToGetSearchUsers()
    }
    
//    func sendRequestToGetUsersSports() {
//        let requestDictionary = NSMutableDictionary()
//        requestDictionary.setObject(Int(appDelegate.user.profileID), forKey: "user_id")
//       
//        if !Globals.isInternetConnected() {
//            return
//        }
//        showLoadingView(true)
//        CustomURLConnection(request: CustomURLConnection.createRequest(requestDictionary, methodName: "sports/userSports", requestType: HttpMethod.post),delegate: self,tag: Connection.userSportsList)
//        
//    }

    func sendRequestToGetSearchUsers() {
        let requestDictionary = NSMutableDictionary()
        requestDictionary.setObject(searchString, forKey: "search_name")
        requestDictionary.setObject(sliderValue, forKey: "distance")
        if let location = point {
            requestDictionary.setObject(location.coordinate.latitude, forKey: "latitude")
            requestDictionary.setObject(location.coordinate.longitude, forKey: "longitude")
        } else {
//            requestDictionary.setObject(37.785834, forKey: "latitude")
//            requestDictionary.setObject(-122.406417, forKey: "longitude")
        }
        
        if (femaleButton.selected && maleButton.selected) || (!femaleButton.selected && !maleButton.selected) {
            requestDictionary.setObject("", forKey: "gender")
        } else if maleButton.selected {
            requestDictionary.setObject(Gender.male, forKey: "gender")
        } else if femaleButton.selected{
            requestDictionary.setObject(Gender.female, forKey: "gender")
        }
        
        if self.userSelectedArray.count > 0 {
            
            
            let sportsArray = NSMutableArray()
            for sport in self.userSelectedArray {
                let sportDictionary = NSMutableDictionary()
                sportDictionary.setObject((sport as! SportsList).sportsId, forKey: "sports_id")
                sportDictionary.setObject((sport as! SportsList).sportsName, forKey: "title")
                sportDictionary.setObject((sport as! SportsList).logo, forKey: "logo")
                sportDictionary.setObject((sport as! SportsList).status, forKey: "status")
                sportDictionary.setObject((sport as! SportsList).level, forKey: "level")
                sportsArray.addObject(sportDictionary)
            }
            requestDictionary.setObject(sportsArray, forKey: "sportsList")
        }
        else {
            
            if(self.nameSearchFlag) {
                
                
            }
            else {
                
                UIAlertView(title: "Please Select Atleast one sport", message: "", delegate: self, cancelButtonTitle: "OK").show()
                return
            }
          
        }
        println(requestDictionary)
        searchString = ""
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
        let response = NSString(data: connection.receiveData, encoding: NSUTF8StringEncoding)
        var error : NSError?
        println(response)
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(connection.receiveData, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
            
            if let status = jsonResult["status"] as? Int {
                if connection.connectionTag == Connection.searchUserName {
                    if status == ResponseStatus.success {
                        if let results = jsonResult["search_list"] as? NSArray {
                            searchResultArray = results as! Array
                            if searchResultArray.count > 0 {
                               performSegueWithIdentifier("searchToSearchResult", sender: self)
                            } else {
                                showDismissiveAlertMesssage("No search results found!")
                            }
                        } else {
                        }
                    } else {
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
                } else if  connection.connectionTag == Connection.userSportsList {
                    if status == ResponseStatus.success {
                        if let favourites = jsonResult["data"] as? NSMutableArray {
                            userSelectedArray = favourites as NSMutableArray
                            for userSports in allSportsArray {
                                if userSelectedArray.valueForKey("sports_id")!.containsObject(userSports["sports_id"] as! Int) {
                                    var index = userSelectedArray.valueForKey("sports_id")?.indexOfObject(userSports["sports_id"] as! Int)
                                    allSportsArray.replaceObjectAtIndex(count, withObject: userSelectedArray.objectAtIndex(index!))
                                } else {
                                    userSports.setObject("NO", forKey: "level")
                                    allSportsArray.replaceObjectAtIndex(count, withObject: userSports)
                                }
                                count=count+1
                            }
                            sportsCarousel.reloadData()
                        } else {
                        }
                    } else {
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
                } else {
                    if status == ResponseStatus.success {
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
        showDismissiveAlertMesssage(error.localizedDescription)
        showLoadingView(false)
    }
    
}

extension SearchViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allSportsArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("sportCell", forIndexPath: indexPath) as! AllSportsCollectionViewCell
        let sport = allSportsArray[indexPath.row] as! SportsList
        cell.sportNameLabel.text = sport.sportsName
        cell.sportImageView.image = UIImage(named: "default_image")
        let url = sport.logo
        let imageurl = SERVER_URL.stringByAppendingString(url as String) as NSString
        if imageurl.length != 0 {
            if var imagesArray = Images.fetch(imageurl as String) {
                let image      = imagesArray[0] as! Images
                let sportImage = UIImage(data: image.imageData)!
                cell.sportImageView.image = UIImage(data: image.imageData)!
            } else {
                if let imageURL = NSURL(string: imageurl as String){
                    let request  = NSURLRequest(URL: imageURL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: TimeOut.Image)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                        if let updatedCell = collectionView.cellForItemAtIndexPath(indexPath) as? AllSportsCollectionViewCell {
                            if error == nil {
                                let imageFromData:UIImage? = UIImage(data: data)
                                if let image  = imageFromData {
                                    updatedCell.sportImageView.image = image
                                    Images.save(imageurl as String, imageData: data)
                                }
                            }
                        }
                    }
                }
            }
        }
        cell.tickImageView.hidden = sport.level == "NO" ? true : false
        return cell
    }
    
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if userSelectedArray.valueForKey("sportsId")!.containsObject((allSportsArray.objectAtIndex(indexPath.item) as! SportsList).sportsId.integerValue) {
            var indexValue  = userSelectedArray.valueForKey("sportsId")?.indexOfObject((allSportsArray.objectAtIndex(indexPath.item) as! SportsList).sportsId.integerValue)
            userSelectedArray.removeObjectAtIndex(indexValue!)
            let allSports   = allSportsArray[indexPath.item] as! SportsList
            allSports.level = "NO"
            allSportsArray.replaceObjectAtIndex(indexPath.item, withObject: allSports)
        } else{
            let userSport   = allSportsArray[indexPath.item] as! SportsList
            userSport.level = ""
            userSelectedArray.addObject(userSport)
            allSportsArray.replaceObjectAtIndex(indexPath.item, withObject: userSport)
        }
        collectionView.reloadData()
        
    }
}



extension SearchViewController: iCarouselDataSource {
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return  allSportsArray.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        var contentView: UIView
        var titleLabel: UILabel
        var sportsImageView: UIImageView
        var tickImageView: UIImageView
        
        var indicatorView: UIActivityIndicatorView
        if view == nil {
            contentView                         = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 78.0, height: carousel.frame.size.height)))
            sportsImageView                     = UIImageView(frame: CGRect(origin: CGPoint(x: 10.0, y: 0.0), size: CGSize(width: carousel.frame.size.height-20.0, height: carousel.frame.size.height-20.0)))
            sportsImageView.contentMode         = .ScaleAspectFit
            sportsImageView.tag                 = 1
            sportsImageView.layer.cornerRadius  = sportsImageView.frame.size.height/2.0
            contentView.addSubview(sportsImageView)
            
            titleLabel           = UILabel(frame: CGRect(x: 0.0, y: sportsImageView.frame.size.height+2.0, width: contentView.frame.size.width, height: 20.0))
            titleLabel.center    = CGPoint(x: sportsImageView.center.x, y: titleLabel.center.y)
            titleLabel.font      = UIFont(name: "OpenSans", size: 13.0)
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.textColor = UIColor.blackColor()
            titleLabel.textAlignment = NSTextAlignment.Center
            titleLabel.tag       = 2
            contentView.addSubview(titleLabel)
            indicatorView           = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            indicatorView.center    = sportsImageView.center
            indicatorView.hidesWhenStopped  = true
            indicatorView.tag       = 3
            indicatorView.startAnimating()
            contentView.addSubview(indicatorView)
            
            tickImageView           = UIImageView(image: UIImage(named: "tick"))
            tickImageView.frame     = CGRect(origin: CGPoint(x: 12.0, y: 0.0), size: tickImageView.image!.size)
            tickImageView.tag       = 4
            tickImageView.hidden    = true
            contentView.addSubview(tickImageView)
            
        } else  {
            
            contentView     = view!
            sportsImageView = contentView.viewWithTag(1) as! UIImageView
            titleLabel      = contentView.viewWithTag(2) as! UILabel
            indicatorView   = contentView.viewWithTag(3) as! UIActivityIndicatorView
            tickImageView   = contentView.viewWithTag(4) as! UIImageView
        }
        let source          = allSportsArray
        let sports          = source[index] as! SportsList
        
//         println("ALL Sports Array : \(allSportsArray)")
        
        sportsImageView.image = UIImage(named: "default_image")
        sportsImageView.contentMode = UIViewContentMode.ScaleAspectFit
        CustomURLConnection.downloadAndSetImage(sports.logo, imageView: sportsImageView, activityIndicatorView: indicatorView)

        if index == carousel.currentItemIndex {
            tickImageView.hidden = false
            titleLabel.text = sports.sportsName.uppercaseString as String
            if sports.level == SportsLevel.beginner {
                beginnerButton.selected = true
            } else if sports.level == SportsLevel.moderate {
                moderateButton.selected = true
            } else if sports.level == SportsLevel.expert {
                expertButton.selected = true
            } else if sports.level == SportsLevel.noType {
                
                expertButton.selected   = false
                beginnerButton.selected = false
                moderateButton.selected = false
                
            }  else {}
            
        } else {
            titleLabel.text = sports.sportsName
        }
        
        tickImageView.hidden = sports.level == "NO" ? true : false
        return contentView
    }
}

extension SearchViewController: iCarouselDelegate {
    func carousel(carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        let centerItemZoom: CGFloat = 1.5
        let centerItemSpacing: CGFloat = 1.3
        var offset      = offset
        var transform   = transform
        let spacing     = self.carousel(carousel, valueForOption: iCarouselOption.Spacing, withDefault: 1.0)
        let absClampedOffset = min(1.0, fabs(offset))
        let clampedOffset = min(1.0, max(-1.0, offset))
        let scaleFactor = 1.0 + absClampedOffset * (1.0/centerItemZoom - 1.0)
        offset = (scaleFactor * offset + scaleFactor * (centerItemSpacing - 1.0) * clampedOffset) * carousel.itemWidth * spacing
        transform = CATransform3DTranslate(transform, offset, 0.0, -absClampedOffset)
        transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1.0)
        return transform
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        
        println("currentItemIndexdidchange")
        
        beginnerButton.selected = false
        moderateButton.selected = false
        expertButton.selected   = false
        carousel.reloadData()
    }
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        if userSelectedArray.valueForKey("sportsId")!.containsObject((allSportsArray.objectAtIndex(index) as! SportsList).sportsId.integerValue) {
            var indexValue  = userSelectedArray.valueForKey("sportsId")?.indexOfObject((allSportsArray.objectAtIndex(index) as! SportsList).sportsId.integerValue)
            userSelectedArray.removeObjectAtIndex(indexValue!)
            let allSports   = allSportsArray[index] as! SportsList
            allSports.level = "NO"
            allSportsArray.replaceObjectAtIndex(index, withObject: allSports)
        } else{
            let userSport   = allSportsArray[index] as! SportsList
            userSport.level = ""
            userSelectedArray.addObject(userSport)
            allSportsArray.replaceObjectAtIndex(index, withObject: userSport)
        }
        if userSelectedArray.count > 0 {
            moderateButton.superview?.hidden = false
            searchButton.enabled             = true
        } else {
            moderateButton.superview?.hidden = true
            searchButton.enabled             = false
        }
        carousel.reloadData()
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .Spacing {
            return value * 1.4
        }
        return value
    }
}


