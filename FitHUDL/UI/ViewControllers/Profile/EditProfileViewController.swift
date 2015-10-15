//
//  EditProfileViewController.swift
//  FitHUDL
//
//  Created by Ti Technologies on 14/10/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var monthPick: SRMonthPicker!
    @IBOutlet weak var timeCollectionView: UICollectionView!
    @IBOutlet weak var datePicker: DIDatepicker!
    @IBOutlet weak var monthButton: UIButton!
    
    @IBOutlet weak var contentViewHeightConstriant: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorAttributes     = [NSForegroundColorAttributeName: UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)]
        var placeHolderString   = NSAttributedString(string: nameTextField.placeholder!, attributes: colorAttributes)
        nameTextField.attributedPlaceholder = placeHolderString
        
        if IS_IPHONE6PLUS {
            contentViewHeightConstriant.constant = view.frame.size.height-64.0
            view.layoutIfNeeded()
        }
        
        monthPick.superview!.setTranslatesAutoresizingMaskIntoConstraints(true)
        monthPick.superview!.frame = CGRect(x: 0.0, y: view.frame.size.height, width: view.frame.size.width, height: monthPick.frame.size.height)
        
        datePicker.fillDatesFromDate(NSDate(), toDate: endOfMonth())
      
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY"
        monthPick.minimumYear  = dateFormatter.stringFromDate(NSDate()).toInt()!
        monthPick.maximumYear  = monthPick.minimumYear+25
        monthPick.font         = UIFont(name: "Open-Sans", size: 17.0)
        monthPick.fontColor    = UIColor(red: 0, green: 120/255, blue: 109/255, alpha: 1.0)
        monthPick.monthPickerDelegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        if IS_IPHONE4S || IS_IPHONE5 {
            contentScrollView.contentSize = CGSize(width: contentScrollView.frame.size.width, height: 603.0)
        } else {
            contentScrollView.contentSize = CGSize(width: contentScrollView.frame.size.width, height: contentScrollView.frame.size.height)
        }
    }
    
    func endOfMonth() -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let months   = NSDateComponents()
        months.month = 1
        
        if let plusOneMonthDate = calendar.dateByAddingComponents(months, toDate: NSDate(), options: nil) {
            let plusOneMonthDateComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth, fromDate: plusOneMonthDate)
            let endOfMonth = calendar.dateFromComponents(plusOneMonthDateComponents)?.dateByAddingTimeInterval(-1)
            return endOfMonth
        }
        return nil
    }

    @IBAction func backButtonClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func photoButtonClicked(sender: UIButton) {
   
    }
    
    @IBAction func addTimeButtonClicked(sender: UIButton) {
    
    }
    
    @IBAction func doneButtonClicked(sender: UIButton) {
    
    }
    
    @IBAction func monthButtonClicked(sender: UIButton) {
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.monthPick.superview!.frame = CGRect(origin: CGPoint(x: 0.0, y: self.view.frame.size.height - self.monthPick.superview!.frame.size.height), size: self.monthPick.superview!.frame.size)
            return
        })
    }
    
    @IBAction func pickerDoneClicked(sender: UIButton) {
        let components   = NSDateComponents()
        components.month = monthPick.selectedMonth
        components.year  = monthPick.selectedYear
        let selectedDate = NSCalendar.currentCalendar().dateFromComponents(components);
        let formatter    = NSDateFormatter()
        formatter.dateFormat = "MMM yyyy"
        hidePickerView()
        if monthButton.titleLabel?.text == formatter.stringFromDate(selectedDate!).uppercaseString {
            return
        }
        monthButton.setTitle(formatter.stringFromDate(selectedDate!).uppercaseString, forState: .Normal)
        formatter.dateFormat = "MMM"
        let month            = formatter.stringFromDate(selectedDate!)
        formatter.dateFormat = "yyyy"
        let year             = formatter.stringFromDate(selectedDate!)
        datePicker.filDatesWithMonth(month, year: year)
        
    }
    
    @IBAction func pickerCancelClicked(sender: UIButton) {
        hidePickerView()
    }
    
    func hidePickerView() {
        UIView.animateWithDuration(animateInterval, animations: { () -> Void in
            self.monthPick.superview!.frame = CGRect(origin: CGPoint(x: 0.0, y: self.view.frame.size.height), size: self.monthPick.superview!.frame.size)
            return
        })
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

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension EditProfileViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        if count(textView.text) == 0 {
            placeholderLabel.hidden = false
        } else {
            placeholderLabel.hidden = true
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            if count(textView.text) == 0 {
                placeholderLabel.hidden = false
            }
            return false
        }
        return true
    }
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