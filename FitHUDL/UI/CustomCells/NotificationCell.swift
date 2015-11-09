//
//  NotificationCell.swift
//  FitHUDL
//
//  Created by Ti Technologies on 06/11/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        roundLabel.layer.cornerRadius = 10.0
        roundLabel.layer.borderColor=UIColor.clearColor().CGColor
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
