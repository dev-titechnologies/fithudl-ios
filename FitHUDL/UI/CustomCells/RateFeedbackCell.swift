//
//  RateFeedbackCell.swift
//  FitHUDL
//
//  Created by Ti Technologies on 14/10/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class RateFeedbackCell: UICollectionViewCell {

    @IBOutlet weak var RateCategory_name: UILabel!
    @IBOutlet weak var arrowShape: UIImageView!
    
    @IBOutlet weak var rateView: RateView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
