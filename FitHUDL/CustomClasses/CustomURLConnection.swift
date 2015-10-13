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
                    parameters.setObject("rahul_device_id", forKey: "device_id")
                }
                if let apiToken = NSUserDefaults.standardUserDefaults().objectForKey("API_TOKEN") as? String {
                    parameters.setObject(apiToken, forKey: "token")
                }
            }
            let jsonData        = NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
            urlRequest.HTTPBody = jsonData
        }
        return urlRequest
    }
}
