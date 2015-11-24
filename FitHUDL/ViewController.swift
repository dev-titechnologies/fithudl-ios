//
//  ViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 23/09/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

extension UINavigationController {
    func setStatusBarColor() {
        let statusBarView: UIView = UIView(frame: CGRect(x: 0, y: -20.0, width: view.frame.size.width, height: 20.0))
        statusBarView.backgroundColor = AppColor.statusBarColor
        navigationBar.addSubview(statusBarView)
    }
}

extension UIViewController {
    
    func dismissOnSessionExpire() {
        if let presentingController = self.presentingViewController as? UINavigationController {
            Globals.clearSession()
            presentingController.popToRootViewControllerAnimated(true)
            UIAlertView(title: "", message: ErrorMessage.sessionOut, delegate: nil, cancelButtonTitle: "OK").show()
            dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
    func showDismissiveAlertMesssage(message: String) {
        let alertController = UIAlertController(title: alertTitle, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (okAction) -> Void in
            return
        }
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showLoadingView(animating: Bool) {
        if animating {
            let overlayView             = UIView(frame: view.bounds)
            overlayView.tag             = 999
            overlayView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
            
            let loadingView                 = UIView(frame: CGRect(x: (overlayView.frame.size.width-100.0)/2.0, y: (overlayView.frame.size.height-100.0)/2.0, width: 100.0, height: 100.0))
            loadingView.backgroundColor     = UIColor.blackColor().colorWithAlphaComponent(0.7)
            loadingView.layer.cornerRadius  = 10.0
            
            let indicatorView               = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            indicatorView.tag               = 998
            indicatorView.frame             = CGRect(x: (loadingView.frame.size.width-indicatorView.frame.size.width)/2.0, y: 20.0, width: indicatorView.frame.size.width, height: indicatorView.frame.size.height)
            indicatorView.hidesWhenStopped  = true
            loadingView.addSubview(indicatorView)
            
            let loadingLabel            = UILabel(frame: CGRect(x: 10.0, y: indicatorView.frame.origin.y+indicatorView.frame.size.height+5.0, width: 80.0, height: 30.0))
            loadingLabel.text           = "Loading"
            loadingLabel.textColor      = UIColor.whiteColor()
            loadingLabel.font           = UIFont(name: "OpenSans", size: 16.0)
            loadingLabel.textAlignment  = NSTextAlignment.Center
            loadingView.addSubview(loadingLabel)
            overlayView.addSubview(loadingView)
            indicatorView.startAnimating()
            view.addSubview(overlayView)
        } else {
            if let indicatorView   = view.viewWithTag(998) as? UIActivityIndicatorView {
                indicatorView.stopAnimating()
            }
            if let overlayView     = view.viewWithTag(999) {
                overlayView.removeFromSuperview()
            }
        }
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

