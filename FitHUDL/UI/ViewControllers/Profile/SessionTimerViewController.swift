//
//  SessionTimerViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 16/11/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class SessionTimerViewController: UIViewController {
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var timerView: TimerView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var timerLabel: MZTimerLabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let radius        = max(circleView.frame.size.width,circleView.frame.size.height)
        circleView.layer.cornerRadius = CGFloat(radius)/2.0
        circleView.layer.borderWidth  = 2.0
        circleView.layer.borderColor  = AppColor.timerColor.CGColor
        timerLabel.timerType = MZTimerLabelTypeTimer
        timerLabel.timeLabel = timerLabel
        timerLabel.delegate  = self
        timerLabel.setCountDownTime(TimeOut.sessionDuration)
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        timerLabel.start()
        timerView.resetView()
    }
    
    func showSessionExtensionAlert() {
        let alert = UIAlertController(title: "", message: "The session is complete. Do you wish to extend the session?", preferredStyle: UIAlertControllerStyle.Alert)
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (yesAction) -> Void in
            self.timerView.layer.sublayers.removeLast()
            self.timerView.setNeedsDisplay()
            self.timerLabel.reset()
            self.timerView.resetView()
            self.timerLabel.start()
            self.statusLabel.text = "This session has been started."
        }
        let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) { (noAction) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        presentViewController(alert, animated: true, completion: nil)
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

extension SessionTimerViewController: MZTimerLabelDelegate {
    func timerLabel(timerLabel: MZTimerLabel!, finshedCountDownTimerWithTime countTime: NSTimeInterval) {
        statusLabel.text = "This session is complete."
        showSessionExtensionAlert()
    }
}
