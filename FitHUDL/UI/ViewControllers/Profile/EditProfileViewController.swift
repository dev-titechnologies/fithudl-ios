//
//  EditProfileViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 14/10/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

//    @IBOutlet weak var monthPick: SRMonthPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "YYYY"
//        monthPick.minimumYear  = dateFormatter.stringFromDate(NSDate()).toInt()!
//        monthPick.maximumYear  = monthPick.minimumYear+25
//        monthPick.font         = UIFont(name: "Open-Sans", size: 17.0)
//        monthPick.fontColor    = UIColor(red: 0, green: 120/255, blue: 109/255, alpha: 1.0)
//        monthPick.monthPickerDelegate = self
        
        // Do any additional setup after loading the view.
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


extension EditProfileViewController: SRMonthPickerDelegate {
    func monthPickerWillChangeDate(monthPicker: SRMonthPicker!) {
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitMonth, fromDate: NSDate())
        if monthPicker.selectedYear == monthPicker.minimumYear && monthPicker.selectedMonth < components.month {
            showDismissiveAlertMesssage("You have selected a past month. Please select a future date!")
        }
    }
    
    func monthPickerDidChangeDate(monthPicker: SRMonthPicker!) {
        
    }
}