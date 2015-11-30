//
//  BadgesCollectionViewCell.swift
//  FitHUDL
//
//  Created by Ti Technologies on 30/09/15.
//  Copyright (c) 2015 Ti Technologies. All rights reserved.
//

import UIKit

class BadgesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}


class AllSportsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var sportImageView: UIImageView!
    @IBOutlet weak var sportNameLabel: UILabel!
}