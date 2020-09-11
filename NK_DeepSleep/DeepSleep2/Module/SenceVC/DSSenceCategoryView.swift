//
//  DSSenceCategoryView.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/9/7.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import DeviceKit
class DSSenceCategoryView: UIView {

    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var contentCollection: UICollectionView!
    var currentSceneList: [SceneBundle] = []
    
    var didSelectSceneBundle: ((SceneBundle)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        topTitleLabel.font(20, UIFont.FontNames.Quicksand_Bold)
        
    }

}

extension DSSenceCategoryView {
    func setupData(sceneBundle: [SceneBundle]) {
        DispatchQueue.main.async {
            [weak self] in
            guard let `self` = self else {return}
            self.topTitleLabel.text = sceneBundle.first?.category_name ?? "Category"
            self.currentSceneList = sceneBundle
            self.contentCollection.reloadData()
        }
        
    }
    
    func setupView() {
        contentCollection.register(nibWithCellClass: DSSenceCell.self)
        
    }
}


extension DSSenceCategoryView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: DSSenceCell.self, for: indexPath)
        let item = currentSceneList[indexPath.item]
        
        cell.nameLabel.text = item.name
        
        if let buildinName = DSBuildinManager.default.buildinResourceName(remoteName: item.img_cover)  {
            cell.coverImageView.image = UIImage.init(named: buildinName)
        } else {
            cell.coverImageView.url(item.img_cover, placeholderImage: UIImage.named("plus_bg_ic"))
        }
        
        
        if item.is_free == 1 || PurchaseManager.default.inSubscription{
//            cell.proBgView.isHidden = true
        } else {
            cell.proBgView.isHidden = false
        }
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentSceneList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

extension DSSenceCategoryView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 156
        var width: CGFloat = 108
        /*
         case .iPhoneX: return 5.8
         case .iPhoneXS: return 5.8
         case .iPhoneXSMax: return 6.5
         case .iPhoneXR: return 6.1
         case .iPhone11: return 6.1
         case .iPhone11Pro: return 5.8
         case .iPhone11ProMax: return 6.5
         */
        if Device.current.diagonal <= 6.5 && Device.current.diagonal >= 5.5 {
            width = 120
            height = 168
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let padding: CGFloat = 20
        return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let padding: CGFloat = 5
        return padding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let padding: CGFloat = 5
        return padding
    }
    
}

extension DSSenceCategoryView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = currentSceneList[indexPath.item]
        didSelectSceneBundle?(item)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}






