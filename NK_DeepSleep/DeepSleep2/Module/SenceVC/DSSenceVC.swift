//
//  DSSenceVC.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/9/7.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import NoticeObserveKit
import DeviceKit
class DSSenceVC: UIViewController {
    var montherVC: UIViewController?
    
    @IBOutlet weak var sevenPlanBgView: UIView!
    @IBOutlet weak var sevenTopTitleLabel: UILabel!
    @IBOutlet weak var sevenTopDesLabel: UILabel!
    @IBAction func sevenCardBtnClick(_ sender: UIControl) {
        sevenPlanClickAction()
    }
    @IBOutlet weak var sevenCardTitleLabel: UILabel!
    @IBOutlet weak var sevenCardDesLabel: UILabel!
    
    @IBOutlet weak var senceBgView: UIView!
    @IBOutlet weak var senceBgViewHeight: NSLayoutConstraint!
    
    var categoryBundleList: [Int: [SceneBundle]] = [:]
    var currentSceneList: [SceneBundle] = [] {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
                [weak self] in
                guard let `self` = self else {return}
                
            }
            self.setupSenceBgView()
        }
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        addObserver()
        setupSevenPlanBgView()
        
        
//        titleLabel1.font(24, UIFont.FontNames.Quicksand_Bold)
        sevenTopTitleLabel.font(30, UIFont.FontNames.Quicksand_Bold)
        sevenTopDesLabel.font(14, UIFont.FontNames.Quicksand_Medium)
        sevenCardTitleLabel.font(20, UIFont.FontNames.Quicksand_Medium)
        
        sevenCardDesLabel.font(14, UIFont.FontNames.Quicksand_Regular)
    }
    
    func setupSevenPlanBgView() {
        sevenCardTitleLabel.text = "7 Day Sleep Plan"
        sevenCardDesLabel.text = "Fall asleep fast，start a healthier life"
    }
    
    func setupSenceBgView() {
        var res: [Int:[SceneBundle]] = [:]
        for bundle in currentSceneList {
            if let categoryId = bundle.category_id {
                if var categoryBunlds = res[categoryId] {
                    categoryBunlds.append(bundle)
                    res[categoryId] = categoryBunlds
                } else {
                    res[categoryId] = [bundle]
                }
            }
        }
        let sortKeys = res.keys.sorted { (obj1, obj2) -> Bool in
            return obj1 < obj2
        }
        debugPrint(sortKeys)
        categoryBundleList = res
        
        var index: CGFloat = 0
        var perHeight: CGFloat = 204
        if Device.current.diagonal <= 6.5 && Device.current.diagonal >= 5.5 {
            perHeight = 216
        }
        let originalX: CGFloat = 0
        let perWidth: CGFloat = UIScreen.width
        let allHeight: CGFloat = perHeight * CGFloat(sortKeys.count)
        senceBgViewHeight.constant = allHeight
        self.senceBgView.alpha = 0
        UIView.animate(withDuration: 0.15, delay: 0.15, options: .curveEaseInOut, animations: {
            self.senceBgView.alpha = 1
        }) { (finished) in
            
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0) {
            [weak self] in
            guard let `self` = self else {return}
            self.senceBgView.removeSubviews()
            
            for key in sortKeys {
                debugPrint("key = \(key)")
                if let bundle = res[key] {
                    let originalY: CGFloat = index * perHeight
                    let categoryView = DSSenceCategoryView.loadNib()
                    categoryView.setupData(sceneBundle: bundle)
                    categoryView.frame = CGRect.init(x: originalX, y: originalY, width: perWidth, height: perHeight)
                    self.senceBgView.addSubview(categoryView)
                    categoryView.snp.makeConstraints {
                        $0.left.equalToSuperview().offset(originalX)
                        $0.top.equalToSuperview().offset(originalY)
                        $0.width.equalTo(perWidth)
                        $0.height.equalTo(perHeight)
                    }
                    categoryView.didSelectSceneBundle = {[weak self] bundle in
                        guard let `self` = self else {return}
                        self.didSelectSence(senceItem: bundle)
                    }
                    
                    index += 1
                }
            }
        }
        
        
    }
    
    
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


extension DSSenceVC {
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(getDeepSleepResourceSuccess), name: Notification.Name("getDeepSleepResource"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(noti_purchaseSuccessAciton(noti:)), name: NSNotification.Name(rawValue: PurchaseStatusNotificationKeys.success), object: nil)
        
        
        
    }
    
    @objc func noti_purchaseSuccessAciton(noti: Notification) {
        DispatchQueue.main.async {
            [weak self] in
            guard let `self` = self else {return}
            
            
            guard let resourceModel = Request.default.resourceModel else { return }
            guard let sceneList = resourceModel.scene else { return }
//            self.currentSceneList = sceneList
        }
    }
    
    @objc func getDeepSleepResourceSuccess() {
        guard let resourceModel = Request.default.resourceModel else { return }
        guard let sceneList = resourceModel.scene else { return }
        
        DispatchQueue.main.async {
            [weak self] in
            guard let `self` = self else {return}
//            self.currentSceneList = sceneList
        }
    }
    
    func loadData() {
        guard let resourceModel = Request.default.resourceModel else { return }
//        guard let resourceModel = LoadJsonData.default.loadJson(DeepSleepResource.self, name: "testResource") else { return }
        guard let sceneList = resourceModel.scene else { return }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0) {
            self.currentSceneList = sceneList
        }
        
    }
    
    
    
}

extension DSSenceVC {
    func sevenPlanClickAction() {
        
        MTEvent.default.tga_eventPlan7Day_Click()
        self.montherVC?.pushVC(DSSevenPlanVC(), animate: true)
    }
}




