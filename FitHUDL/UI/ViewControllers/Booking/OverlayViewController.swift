//
//  OverlayViewController.swift
//  
//
//  Created by Ti Technologies on 20/05/16.
//
//

import UIKit

class OverlayViewController: UIViewController,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var introImage: UIImageView!
    var controllerFlag : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch(controllerFlag){
            
        case 1 :
            introImage.image = UIImage(named: "1.png")
        case 2 :
            introImage.image = UIImage(named: "2.png")
        case 3 :
            introImage.image = UIImage(named: "3.png")
        case 4 :
            introImage.image = UIImage(named: "4.png")
        case 5 :
            introImage.image = UIImage(named: "6.png")
        case 6 :
            introImage.image = UIImage(named: "5.png")
        default :
            break
        }
        var tapGesture = UITapGestureRecognizer(target: self, action: "introTap")
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)

        // Do any additional setup after loading the view.
    }
    func introTap(){
        self.dismissViewControllerAnimated(true, completion: nil)
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
