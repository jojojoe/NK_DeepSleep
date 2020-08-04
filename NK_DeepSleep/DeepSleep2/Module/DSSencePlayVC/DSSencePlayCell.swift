//
//  DSSencePlayCell.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/15.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import Lottie
class DSSencePlayCell: UICollectionViewCell {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playingStatusBgView: UIView!
    let animationView: AnimationView = AnimationView(name: "deep_playing")
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
//        playingStatusBgView.isHidden = true
        animationView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        playingStatusBgView.addSubview(animationView)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
        nameLabel.font(12, UIFont.FontNames.Quicksand_Medium)
    }
    
    
}
