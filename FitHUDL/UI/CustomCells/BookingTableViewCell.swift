//
//  BookingTableViewCell.swift
//  FitHUDL
//
//  Created by Ti Technologies on 26/10/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class BookingTableViewCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var disabledView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        locationTextField.delegate = self
        bookButton.layer.borderWidth = 1.0
        bookButton.layer.borderColor = AppColor.statusBarColor.CGColor
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
