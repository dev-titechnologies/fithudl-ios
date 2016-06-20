//
//  CreateStripeViewController.swift
//  
//
//  Created by Ti Technologies on 11/05/16.
//
//

import UIKit

class CreateStripeViewController: UIViewController {

    @IBOutlet weak var okButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.navigationBar.hidden = true
        okButton.layer.cornerRadius    = 23.0
        okButton.layer.borderWidth     = 2.0
        okButton.layer.borderColor     = AppColor.statusBarColor.CGColor
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func OkButtonClicked(sender: AnyObject) {
        
        self.performSegueWithIdentifier("poptostripe", sender: self)
        
//        let controller  = storyboard?.instantiateViewControllerWithIdentifier("StripeAccount") as! AccountStripeViewController
//        controller.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
//        controller.stripeFlag = "STRIPE"
//        let navController = UINavigationController(rootViewController: controller)
//        self.presentViewController(navController, animated: true, completion: nil)
        
        
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
