//
//  CustomURLConnection.swift
//  FitHUDL
//
//  Created by Ti Technologies on 23/09/15.
//  Copyright © 2015 Ti Technologies. All rights reserved.
//

import UIKit

class CustomURLConnection: NSURLConnection {

    var connectionTag: Int
    var receiveData: NSMutableData
    var requestTime: Double
    
    init?(request: NSURLRequest, delegate: AnyObject?, tag: Int) {
        self.connectionTag = tag
        self.receiveData   = NSMutableData()
        self.requestTime   = NSDate().timeIntervalSince1970
        super.init(request: request, delegate: delegate, startImmediately: true)
    }
    
    func cancelConnection(){
        super.cancel()
    }
    
    class func createRequest(params: NSMutableDictionary?, methodName: String, requestType: String) -> NSURLRequest {
        var error: NSError?
        let serverURL   = NSURL(string: SERVER_URL.stringByAppendingString(methodName))
        let urlRequest  = NSMutableURLRequest(URL: serverURL!)
        urlRequest.HTTPMethod = requestType
        urlRequest.timeoutInterval = TimeOut.Data
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let parameters = params {
            if !methodName.hasSuffix("forgotPassword") {
                if let deviceToken = appDelegate.deviceToken {
                    parameters.setObject(deviceToken, forKey:"device_id")
                } else {
                    parameters.setObject("xyz", forKey: "device_id")
                }
                if let apiToken = NSUserDefaults.standardUserDefaults().objectForKey("API_TOKEN") as? String {
                    parameters.setObject(apiToken, forKey: "token")
                }
            }
            
            println("PARAM\(parameters)")
            let jsonData        = NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
            urlRequest.HTTPBody = jsonData
        }
        return urlRequest
    }
    
    class func downloadAndSetImage(url: NSString, imageView: UIImageView, activityIndicatorView: UIActivityIndicatorView) {
        activityIndicatorView.startAnimating()
        let imageurl = SERVER_URL.stringByAppendingString(url as String) as NSString
        if imageurl.length != 0 {
            if var imagesArray = Images.fetch(url as String) {
                let image      = imagesArray[0] as! Images
                let coverImage = UIImage(data: image.imageData)!
                imageView.image   =   UIImage(data: image.imageData)!
                activityIndicatorView.stopAnimating()
            } else {
                if let imageURL = NSURL(string: imageurl as String){
                    let request  = NSURLRequest(URL: imageURL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: TimeOut.Image)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                        if error == nil {
                            let imageFromData:UIImage? = UIImage(data: data)
                            if let image  = imageFromData {
                                imageView.image =   image
                                Images.save(imageurl as String, imageData: data)
                            }
                        }
                        activityIndicatorView.stopAnimating()
                    }
                } else {
                    activityIndicatorView.stopAnimating()
                }
            }
        } else {
            activityIndicatorView.stopAnimating()
        }
    }
}
