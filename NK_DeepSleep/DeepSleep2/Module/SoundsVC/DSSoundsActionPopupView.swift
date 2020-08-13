//
//  DSSoundsActionPopupView.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/10.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import Foundation
import FlexLayout
import RxSwift

class DSSoundsActionPopupView: UIView {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 160, height: 90)
    }
    var randomActionBlock: (()->Void)?
    var myFavoriteActionBlock: (()->Void)?
    var addFavoriteActionBlock: (()->Void)?
    
    
    let randomMixBtn = UIButton(type: .custom).image(UIImage.named("random_mix_ic"), .normal).title("Random Mix", .normal).font(13, .Quicksand_Medium).titleColor(UIColor.white, .normal)
    let myFavouriteBtn = UIButton(type: .custom).image(UIImage.named("my_favoirite_ic"), .normal).title("My favourite", .normal).font(13, .Quicksand_Medium).titleColor(UIColor.white, .normal)
    let addToFavoriteBtn = UIButton(type: .custom).image(UIImage.named("add_favourite_ic"), .normal).title("Add to favourites", .normal).font(13, .Quicksand_Medium).titleColor(UIColor.white, .normal).titleColor(UIColor.white.withAlphaComponent(0.4), .disabled)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        flex.layout()
    }
    
}

extension DSSoundsActionPopupView {
    @objc func randomBtnAction() {
        randomActionBlock?()
    }
    
    @objc func myFavoriteBtnAction() {
        myFavoriteActionBlock?()
    }
    
    @objc func addFavoriteBtnAction() {
        addFavoriteActionBlock?()
    }
    
}


extension DSSoundsActionPopupView {
    
    func setupView() {
        backgroundColor = UIColor.init(hexString: "#241C2C")
        layer.masksToBounds = false
        // Shadow Code
        
        layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        layer.shadowOffset = CGSize.init(width: 0, height: 0)
        layer.shadowRadius = 10
        layer.shadowOpacity = 1
        // Radius Code
        layer.cornerRadius = 8
        
    }
    
    func setupSubViews() {
        
        
//
        randomMixBtn.addTarget(self, action: #selector(randomBtnAction), for: .touchUpInside)
        myFavouriteBtn.addTarget(self, action: #selector(myFavoriteBtnAction), for: .touchUpInside)
        addToFavoriteBtn.addTarget(self, action: #selector(addFavoriteBtnAction), for: .touchUpInside)
        
        
        randomMixBtn.contentHorizontalAlignment = .left
        randomMixBtn.titleEdgeInsets = UIEdgeInsets(top: 0,left: 20,bottom: 0,right: 0)
        randomMixBtn.imageEdgeInsets = UIEdgeInsets(top: 0,left: 10,bottom: 0,right: 0)
        
        myFavouriteBtn.contentHorizontalAlignment = .left
        myFavouriteBtn.titleEdgeInsets = UIEdgeInsets(top: 0,left: 20,bottom: 0,right: 0)
        myFavouriteBtn.imageEdgeInsets = UIEdgeInsets(top: 0,left: 10,bottom: 0,right: 0)
        
        addToFavoriteBtn.contentHorizontalAlignment = .left
        addToFavoriteBtn.titleEdgeInsets = UIEdgeInsets(top: 0,left: 20,bottom: 0,right: 0)
        addToFavoriteBtn.imageEdgeInsets = UIEdgeInsets(top: 0,left: 10,bottom: 0,right: 0)
        
        
        
        self.flex.direction(.column).alignContent(.start).justifyContent(.center).alignItems(.start).define {
//            $0.addItem(randomMixBtn).width(100%).height(40)
            $0.addItem(myFavouriteBtn).marginTop(4).width(100%).height(40)
            $0.addItem(addToFavoriteBtn).marginTop(4).width(100%).height(40)
        }
        
        
    }
    
}


