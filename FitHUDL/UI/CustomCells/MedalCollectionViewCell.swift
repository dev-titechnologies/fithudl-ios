//
//  MedalCollectionViewCell.swift
//  FitHUDL
//
//  Created by Ti Technologies on 29/03/16.
//  Copyright (c) 2016 Ti Technologies. All rights reserved.
//

import UIKit

class MedalCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
