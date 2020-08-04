//
//  SISupscriptionBottomLinkView.swift
//  StoryInsights
//
//  Created by JOJO on 2020/7/2.
//  Copyright © 2020 Adrian. All rights reserved.
//

import UIKit

class SISupscriptionBottomLinkView: UIView {
    @IBOutlet weak var purchaseBtn: UIButton!
    @IBAction func purchaseBtnClick(_ sender: UIButton) {
        purchaseBtnBlock?()
    }
    @IBOutlet weak var termsBtn: UIButton!
    @IBAction func termsBtnClick(_ sender: UIButton) {
        termsBtnBlock?()
    }
    @IBOutlet weak var privacyBtn: UIButton!
    @IBAction func privacyBtnClick(_ sender: UIButton) {
        privacyBtnBlock?()
    }
    var purchaseBtnBlock: (()->Void)?
    var termsBtnBlock: (()->Void)?
    var privacyBtnBlock: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        purchaseBtn.titleColor(UIColor.hexString("BEC1CB").withAlphaComponent(0.8), .normal)
        termsBtn.titleColor(UIColor.hexString("BEC1CB").withAlphaComponent(0.8), .normal)
        privacyBtn.titleColor(UIColor.hexString("BEC1CB").withAlphaComponent(0.8), .normal)
        
        
    }

}
