//
//  WebViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 14/01/16.
//  Copyright (c) 2016 Ti Technologies. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var termsWebView: UIWebView!
    
    var viewTag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewTag == ViewTag.termsView {
            titleLabel.text = "Terms Of Service"
            loadWebContent("")
        } else {
            titleLabel.text = "Privacy Policy"
            loadWebContent("")
        }
        
        // Do any additional setup after loading the view.
    }
    
    func loadWebContent(url: String) {
        let loadURL = NSURL(string: url)
        let urlRequest = NSMutableURLRequest(URL: loadURL!)
        termsWebView.loadRequest(urlRequest)
    }

    @IBAction func backButtonClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
