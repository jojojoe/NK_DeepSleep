//
//  DSMPVolumeView.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/8.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import FlexLayout


class DSMPVolumeView: UIView {

//    @IBOutlet weak var closeBtn: UIButton!
//    @IBAction func closeBtnClick(_ sender: UIButton) {
//        closeBtnActionBlock?()
//    }
//    @IBOutlet weak var iconImageView1: UIImageView!
//    @IBOutlet weak var volumeSlider1: UISlider!
//    @IBAction func volumeSlider1Change(_ sender: UISlider) {
//        soundsVolumeChangeBlock?(0, CGFloat(sender.value))
//    }
//
//    @IBOutlet weak var iconImageView2: UIImageView!
//    @IBOutlet weak var volumeSlider2: UISlider!
//    @IBAction func volumeSlider2Change(_ sender: UISlider) {
//        soundsVolumeChangeBlock?(1, CGFloat(sender.value))
//    }
//
//    @IBOutlet weak var iconImageView3: UIImageView!
//    @IBOutlet weak var volumeSlider3: UISlider!
//    @IBAction func volumeSlider3Change(_ sender: UISlider) {
//        soundsVolumeChangeBlock?(2, CGFloat(sender.value))
//    }
    
    let icon1 = UIImageView().image("my_favoirite_ic")
    let icon2 = UIImageView().image("my_favoirite_ic")
    let icon3 = UIImageView().image("my_favoirite_ic")
    let slider1 = UISlider()
    let slider2 = UISlider()
    let slider3 = UISlider()
    
    var closeBtnActionBlock:(()->Void)?
    
    var soundsVolumeChangeBlock:((_ trackIndex: Int, _ value: CGFloat)->Void)?
    
    var iconImageViews: [UIImageView] = []
    var volumeSliders: [UISlider] = []
//    var sliderBgViews: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBlurView()
        setupContentSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        flex.layout()
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//
//
//
//
//
////        iconImageViews.append(iconImageView1)
////        iconImageViews.append(iconImageView2)
////        iconImageViews.append(iconImageView3)
////        volumeSliders.append(volumeSlider1)
////        volumeSliders.append(volumeSlider2)
////        volumeSliders.append(volumeSlider3)
////
////        volumeSlider1.setThumbImage(UIImage.named("volume_adjust_ic"), for: .normal)
////        volumeSlider2.setThumbImage(UIImage.named("volume_adjust_ic"), for: .normal)
////        volumeSlider3.setThumbImage(UIImage.named("volume_adjust_ic"), for: .normal)
//
//    }
    
    
    
    func setupContentSubViews() {
        let closeBtn = UIButton.init(type: .custom).image(UIImage.named("close_ic"), .normal)
        closeBtn.addTarget(self, action: #selector(closeBtnClick(sender:)), for: .touchUpInside)
        
        icon1.contentMode = .scaleAspectFit
        icon2.contentMode = .scaleAspectFit
        icon3.contentMode = .scaleAspectFit
        icon1.backgroundColor = .clear
        icon2.backgroundColor = .clear
        icon3.backgroundColor = .clear
        slider1.isContinuous = true
        slider2.isContinuous = true
        slider3.isContinuous = true
        
        slider1.addTarget(self, action: #selector(volumeSliderChange(sender:)), for: .valueChanged)
        slider2.addTarget(self, action: #selector(volumeSliderChange(sender:)), for: .valueChanged)
        slider3.addTarget(self, action: #selector(volumeSliderChange(sender:)), for: .valueChanged)
        
        slider1.minimumTrackTintColor = .white
        slider2.minimumTrackTintColor = .white
        slider3.minimumTrackTintColor = .white
        slider1.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        slider2.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        slider3.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        
        slider1.setThumbImage(UIImage.named("volume_adjust_ic"), for: .normal)
        slider2.setThumbImage(UIImage.named("volume_adjust_ic"), for: .normal)
        slider3.setThumbImage(UIImage.named("volume_adjust_ic"), for: .normal)
        
        
//        let sliderBgView1 = UIView()
//        let sliderBgView2 = UIView()
//        let sliderBgView3 = UIView()
        
        iconImageViews = [icon1, icon2, icon3]
        volumeSliders = [slider1, slider2, slider3]
//        sliderBgViews = [sliderBgView1, sliderBgView2, sliderBgView3]
        
        flex.direction(.column).grow(1).alignContent(.center).justifyContent(.center).alignItems(.center).define {
            $0.addItem().direction(.row).alignContent(.center).alignItems(.center).define {
                $0.addItem(icon1).width(20).height(20).marginRight(10)
                $0.addItem(slider1).grow(1).width(60%).height(40)
            }
            $0.addItem().direction(.row).alignContent(.center).alignItems(.center).marginTop(8).define {
                $0.addItem(icon2).grow(1).width(20).height(20).marginRight(10)
                $0.addItem(slider2).grow(1).width(60%).height(40)
            }
            $0.addItem().direction(.row).alignContent(.center).alignItems(.center).marginTop(8).define {
                $0.addItem(icon3).grow(1).width(20).height(20).marginRight(10)
                $0.addItem(slider3).grow(1).width(60%).height(40)
            }
            
            $0.addItem(closeBtn).top(24).width(44).height(44)
        }
        
    }
    
    @objc func closeBtnClick(sender: UIButton) {
        closeBtnActionBlock?()
    }
    
    @objc func volumeSliderChange(sender: UISlider) {
         
        let index = volumeSliders.firstIndex(of: sender) ?? 0
        soundsVolumeChangeBlock?(index, CGFloat(sender.value))
        
    }
    
    func setupBlurView() {
        backgroundColor = UIColor.hexString("171424").withAlphaComponent(0.7)
        let blurView = APCustomBlurView(withRadius: 10)
        addSubview(blurView)
        blurView.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.left.top.right.bottom.equalToSuperview()
        }
        sendSubviewToBack(blurView)
    }

}

extension DSMPVolumeView {
    
    func updateContentStatus(itemList: [ContentPlayerItem] = DSMPPlayerManager.default.audioItemList) {
        itemList.forEach {
            if $0.audioItem == nil {
                let imageView = iconImageViews[$0.index]
                let slider = volumeSliders[$0.index]
//                let bgView = sliderBgViews[$0.index]
                imageView.flex.isDisplay = false
                slider.flex.isDisplay = false
//                bgView.flex.isDisplay = false
            } else {
                let imageView = iconImageViews[$0.index]
                let slider = volumeSliders[$0.index]
//                let bgView = sliderBgViews[$0.index]
                imageView.flex.isDisplay = true
                slider.flex.isDisplay = true
//                bgView.flex.isDisplay = true
//                imageView.image = UIImage.named($0.audioItem?.icon_url)
                slider.value = $0.columeValue ?? 0
                if $0.itemStatus == .pause {
                    slider.value = 0
                }
                
                 
                
                if let buildinName = DSBuildinManager.default.buildinResourceName(remoteName: $0.audioItem?.icon_url) {
                    imageView.image = UIImage.named(buildinName)
                } else {
                    imageView.url($0.audioItem?.icon_url)
                }
                
                
                
                
                
                
                imageView.backgroundColor = .clear
            }
            
        }
        
    }
    
}




