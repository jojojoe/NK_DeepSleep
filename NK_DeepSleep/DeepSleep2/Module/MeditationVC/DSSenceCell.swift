//
//  DSSenceCell.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/14.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit

class DSSenceCell: UICollectionViewCell {
    @IBOutlet weak var topContentBgView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var proBgView: UIView!
    @IBOutlet weak var proLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font(13, UIFont.FontNames.Quicksand_Medium)
    }
    
    

}










