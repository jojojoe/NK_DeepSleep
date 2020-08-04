//
//  DSMediatationVC.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/7.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import Kingfisher
import NoticeObserveKit

class DSMediatationVC: UIViewController {

    var montherVC: UIViewController?
    
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var topDesLabel: UILabel!
    @IBOutlet weak var contentCollection: UICollectionView!
    var currentSceneList: [SceneBundle] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupView()
        addObserver()
        
        topTitleLabel.font(30, UIFont.FontNames.Quicksand_Bold)
        topDesLabel.font(14, UIFont.FontNames.Quicksand_Bold)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
     
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

}

extension DSMediatationVC {
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(getDeepSleepResourceSuccess), name: Notification.Name("getDeepSleepResource"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(noti_purchaseSuccessAciton(noti:)), name: NSNotification.Name(rawValue: PurchaseStatusNotificationKeys.success), object: nil)
        
        
        
    }
    
    @objc func noti_purchaseSuccessAciton(noti: Notification) {
        DispatchQueue.main.async {
            [weak self] in
            guard let `self` = self else {return}
            self.contentCollection.reloadData()
        }
    }
    
    @objc func getDeepSleepResourceSuccess() {
        guard let resourceModel = Request.default.resourceModel else { return }
        guard let sceneList = resourceModel.scene else { return }
        currentSceneList = sceneList
        DispatchQueue.main.async {
            [weak self] in
            guard let `self` = self else {return}
            self.contentCollection.reloadData()
        }
    }
    
    func loadData() {
        guard let resourceModel = Request.default.resourceModel else { return }
        guard let sceneList = resourceModel.scene else { return }
        currentSceneList = sceneList
        self.contentCollection.reloadData()
    }
    
    func setupView() {
        contentCollection.register(nibWithCellClass: DSSenceCell.self)
        
    }
    
    
    
}

extension DSMediatationVC {
    func didSelectSence(senceItem: SceneBundle) {
        MTEvent.default.tga_eventMeditationItemClick(itemName: senceItem.name ?? "senceName")
        
        Notice.Center.default.post(name: Notice.Names.noti_pauseCurrentSounds, with: nil)
        
        
        
        if senceItem.is_free == 1 || PurchaseManager.default.inSubscription {
            let sencePlayVC = DSSencePlayVC(sence: senceItem)
            pushVC(sencePlayVC, animate: true)
        } else {
            AppDelegate.showSubscriptionVC(source: "meditation")
            
        }
        
    }
}


extension DSMediatationVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: DSSenceCell.self, for: indexPath)
        /*
         let id: String?
         let name: String?
         let cover: String?
         let bg_img: String?
         let free: Bool?
         let musics: [MusicItem]?
         */
        let item = currentSceneList[indexPath.item]
        cell.nameLabel.text = item.name
        
        if let buildinName = DSBuildinManager.default.buildinResourceName(remoteName: item.img_cover)  {
            cell.coverImageView.image = UIImage.init(named: buildinName)
        } else {
            cell.coverImageView.url(item.img_cover, placeholderImage: UIImage.named("plus_bg_ic"))
        }
        
        if item.is_free == 1 || PurchaseManager.default.inSubscription{
            cell.proBgView.isHidden = true
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

extension DSMediatationVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let ratio: CGFloat = 20.0 / 12.0
        let leftPadding: CGFloat = 10
        let perCount: CGFloat = 3
        let width: CGFloat = (UIScreen.width - (leftPadding * 2)) / perCount
        let height: CGFloat = width * ratio
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let leftPadding: CGFloat = 10
        return UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: leftPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension DSMediatationVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = currentSceneList[indexPath.item]
        didSelectSence(senceItem: item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}


