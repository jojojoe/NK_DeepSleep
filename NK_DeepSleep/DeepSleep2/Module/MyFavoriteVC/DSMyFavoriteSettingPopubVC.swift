//
//  DSMyFavoriteSettingPopubVC.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/14.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import FlexLayout
import RxSwift


class DSMyFavoriteSettingPopubVC: UIViewController {

//    var bumpToTopActionBlock: (()->Void)?
    var renameActionBlock: (()->Void)?
    var deleteActionBlock: (()->Void)?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubViews()
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.flex.padding(view.safeArea)
        view.flex.layout()
        
    }

}

extension DSMyFavoriteSettingPopubVC {
//    @objc func bumpToTopBtnAction() {
//        bumpToTopActionBlock?()
//    }
    
    @objc func renameBtnAction() {
        dismissVC()
        renameActionBlock?()
    }
    
    @objc func deleteBtnAction() {
        dismissVC()
        deleteActionBlock?()
    }
    
}


extension DSMyFavoriteSettingPopubVC {
    
    func setupView() {
        view.backgroundColor = UIColor.clear
        view.layer.masksToBounds = false
        
        // Shadow Code
        
//        layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
//        layer.shadowOffset = CGSize.init(width: 0, height: 0)
//        layer.shadowRadius = 10
//        layer.shadowOpacity = 1
        // Radius Code
        view.layer.cornerRadius = 20
       
        
        
        
    }
    
    @objc func bgBtnClick() {
        dismissVC()
    }
    
    func setupSubViews() {
        
        let bgBtn = UIButton.init(type: .custom).backgroundColor(UIColor.clear)
        bgBtn.addTarget(self, action: #selector(bgBtnClick), for: .touchUpInside)
        
        let bottomBgView = UIView()
        bottomBgView.backgroundColor = UIColor.init(hexString: "#1B1C1E")
        bottomBgView.layer.cornerRadius = 20
        
        let topTitleLabel = UILabel.init(text: "My Sleep Sounds")
        topTitleLabel.textColor = UIColor.white.withAlphaComponent(0.42)
        topTitleLabel.textAlignment = .left
        topTitleLabel.font(14, .Quicksand_Regular)
        
//        let bumpTopBtn = UIButton(type: .custom).title("Bump to Top", .normal).font(13, .AvenirMedium).titleColor(UIColor.white, .normal)
        let renameBtn = UIButton(type: .custom).title("Rename", .normal).font(13, .Quicksand_Medium).titleColor(UIColor.white, .normal)
        let deleteBtn = UIButton(type: .custom).title("Delete", .normal).font(13, .Quicksand_Medium).titleColor(UIColor.white, .normal)
        //
//        bumpTopBtn.addTarget(self, action: #selector(bumpToTopBtnAction), for: .touchUpInside)
        renameBtn.addTarget(self, action: #selector(renameBtnAction), for: .touchUpInside)
        deleteBtn.addTarget(self, action: #selector(deleteBtnAction), for: .touchUpInside)
        
        
//        bumpTopBtn.contentHorizontalAlignment = .left
//        bumpTopBtn.titleEdgeInsets = UIEdgeInsets(top: 0,left: 30,bottom: 0,right: 0)
        
        
        renameBtn.contentHorizontalAlignment = .left
        renameBtn.titleEdgeInsets = UIEdgeInsets(top: 0,left: 30,bottom: 0,right: 0)
        
        
        deleteBtn.contentHorizontalAlignment = .left
        deleteBtn.titleEdgeInsets = UIEdgeInsets(top: 0,left: 30,bottom: 0,right: 0)
        
        
        self.view.flex.addItem(bgBtn).width(100%).height(100%).direction(.column).alignContent(.end).justifyContent(.end).define {
            $0.addItem(bottomBgView).width(100%).height(160).define {
                $0.addItem(topTitleLabel).left(30).height(40)
//                $0.addItem(bumpTopBtn).width(100%).height(60)
//                $0.addItem().backgroundColor(.white).width(100%).height(0.5)
                $0.addItem(renameBtn).width(100%).height(60)
                $0.addItem().backgroundColor(UIColor.white.withAlphaComponent(0.1)).width(100%).height(0.1)
                $0.addItem(deleteBtn).width(100%).height(60)
            }
            
        }
        
        
    }
    
}

