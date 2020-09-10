//
//  DSSevenPlanCell.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/9/8.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit

class DSSevenPlanCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var topTitle1: UILabel!
    @IBOutlet weak var topTitle2: UILabel!
    
    @IBOutlet weak var bottomInfoLabel: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBAction func startBtnClick(_ sender: UIButton) {
        startBtnClickBlock?(planItem)
    }
    var startBtnClickBlock: ((SevenPlanItem?)->Void)?
    var planItem: SevenPlanItem?
    var status: String = "before" // "current" "after"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        startBtn.isUserInteractionEnabled = false
        
        topTitle1.font(24, UIFont.FontNames.Quicksand_Bold)
        topTitle2.font(16, UIFont.FontNames.Quicksand_Medium)
        bottomInfoLabel.font(14, UIFont.FontNames.Quicksand_Medium)
        startBtn.titleLabel?.font(16, UIFont.FontNames.Quicksand_Medium)
        
    }

}
