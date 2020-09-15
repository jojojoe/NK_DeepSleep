//
//  DSSevenPlanVC.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/9/8.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import NoticeObserveKit
class DSSevenPlanVC: UIViewController {

    @IBOutlet weak var gradientBgView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBAction func backBtnClick(_ sender: UIButton) {
        popVC()
    }
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var contentCollection: UICollectionView!
    let topColor = UIColor.init(hexString: "#1D1A26") ?? UIColor.white
    var dayColors: [UIColor] = []
    var itemList: [SevenPlanItem] = []
    var gradientLayer: CAGradientLayer = CAGradientLayer()
    let cardBgImages = ["plan_7d_bg_1", "plan_7d_bg_2", "plan_7d_bg_3", "plan_7d_bg_4", "plan_7d_bg_5", "plan_7d_bg_6", "plan_7d_bg_7"]
    let videoBgImages = ["plan_video1", "plan_video2", "plan_video3", "plan_video4", "plan_video5", "plan_video6", "plan_video7"]
    var currentBgVideoImage: String = "plan_video1"
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        setupBgColor()
        setupView()
        
    }
    
}

extension DSSevenPlanVC {
    func initData() {
//        let plan1 = SevenPlanItem.init(day: 1)
//        let plan2 = SevenPlanItem.init(day: 2)
//        let plan3 = SevenPlanItem.init(day: 3)
//        let plan4 = SevenPlanItem.init(day: 4)
//        let plan5 = SevenPlanItem.init(day: 5)
//        let plan6 = SevenPlanItem.init(day: 6)
//        let plan7 = SevenPlanItem.init(day: 7)
        if let sevenPlanList = Request.default.resourceModel?.scene_plan {
            itemList = sevenPlanList
        }
        
         
    }
    
    func setupView() {
        let rate = UIScrollView.DecelerationRate.init(rawValue: 0.05)
        
        contentCollection.decelerationRate = rate
        contentCollection.register(nibWithCellClass: DSSevenPlanCell.self)
        
        topTitleLabel.font(16, UIFont.FontNames.Quicksand_Medium)
    }
    
    func setupBgColor() {
        
        
        let day1Color = UIColor.init(hexString: "#46250E") ?? UIColor.white
        let day2Color = UIColor.init(hexString: "#4A3F36") ?? UIColor.white
        let day3Color = UIColor.init(hexString: "#553B59") ?? UIColor.white
        let day4Color = UIColor.init(hexString: "#7D8384") ?? UIColor.white
        let day5Color = UIColor.init(hexString: "#2E2E2C") ?? UIColor.white
        let day6Color = UIColor.init(hexString: "#3A2416") ?? UIColor.white
        let day7Color = UIColor.init(hexString: "#0D1613") ?? UIColor.white
        
        dayColors = [day1Color, day2Color, day3Color, day4Color, day5Color, day6Color, day7Color]
        
        
        gradientLayer = self.gradientBgView.gradientBackground(self.topColor, day1Color)
        
     
        
    }
    
     
    
}

extension DSSevenPlanVC {
    func startActionTodayPlan(planItem: SevenPlanItem, isTodayPan: Bool, day: Int) {
        if isTodayPan {
            MTEvent.default.tga_eventPlan7Day_Start(day: day)
            DSSevenPlanManager.default.finishedCurrentPlan()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                [weak self] in
                guard let `self` = self else {return}
                self.contentCollection.reloadData()
            }
        }
        
        Notice.Center.default.post(name: Notice.Names.noti_pauseCurrentSounds, with: nil)
        
        let playerVC = DSSevenPlanPlayerVC(planItem: planItem, bgPlaceholder: currentBgVideoImage)
        pushVC(playerVC, animate: true)
        
    }
}

extension DSSevenPlanVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: DSSevenPlanCell.self, for: indexPath)
        let item = itemList[indexPath.item]
        cell.planItem = item
        
        cell.topTitle1.text = item.dayDesc()?["title"]
        cell.topTitle2.text = item.dayDesc()?["desc"]
        let bgName = cardBgImages[indexPath.item]
        cell.coverImageView.url(item.cover_url, placeholderImage: UIImage.named(bgName))
        //
        
        
        
        let archivePlan = DSSevenPlanManager.default.archivePlanDay()
        var currentPlan: Int = 0
        var hasArchiveCurrentPlan: Bool = false
        if archivePlan.count == 0 {
            currentPlan = 0
        } else {
            if let lastPlan = archivePlan.last, let index = lastPlan.keys.first, let archiveDate = lastPlan[index] {
                
                let currentDateString = Date().string(withFormat: "yyyy-MM-dd")
                let archiveDateString = archiveDate.string(withFormat: "yyyy-MM-dd")
                if currentDateString.contains(archiveDateString) {
                    hasArchiveCurrentPlan = true
                    currentPlan = index
                } else {
                    currentPlan = index + 1
                }
            }
        }
        
        if indexPath.item < currentPlan {
            cell.bottomInfoLabel.isHidden = false
            cell.bottomInfoLabel.text = "Achieved"
            cell.startBtn.isEnabled = true
            cell.startBtn.setTitle("Restart", for: .normal)
//            "before" // "current" "after"
            cell.status = "before"
        } else if indexPath.item == currentPlan {
            
            if hasArchiveCurrentPlan {
                //当天的任务已经完成
                cell.bottomInfoLabel.isHidden = false
                cell.bottomInfoLabel.text = "Achieved"
                cell.startBtn.isEnabled = true
                cell.startBtn.setTitle("Restart", for: .normal)
                cell.status = "before"
            } else {
                cell.bottomInfoLabel.isHidden = true
                cell.startBtn.isEnabled = true
                cell.startBtn.setTitle("Start", for: .normal)
                cell.status = "current"
            }
        } else {
            cell.bottomInfoLabel.isHidden = false
            cell.bottomInfoLabel.text = "You need to complete the previous plan，and come back the next day."
            cell.startBtn.isEnabled = false
            cell.startBtn.setTitle("Start", for: .normal)
            cell.status = "after"
            
            
        }
        
         
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

extension DSSevenPlanVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let left: CGFloat = 45
        let width: CGFloat = (UIScreen.width - (left * 2))
        let height: CGFloat = width * (500.0/284)
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let left: CGFloat = 45
        return UIEdgeInsets(top: 0, left: left, bottom: 0, right: left)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let padding: CGFloat = 20
        return padding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let padding: CGFloat = 20
        return padding
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        
        let x: CGFloat = (targetContentOffset.pointee.x + (contentCollection.width / 2))
        let y: CGFloat = contentCollection.height / 2
        let point = CGPoint.init(x: x, y: y)
        var targetIndexPath: IndexPath = IndexPath.init(row: 0, section: 0)
        if let indexPath = contentCollection.indexPathForItem(at: point) {
            targetIndexPath = indexPath
        } else {
            let point1 = CGPoint.init(x: x + 30, y: y)
            if let indexPath1 = contentCollection.indexPathForItem(at: point1) {
                targetIndexPath = indexPath1
            }
            
        }
        if let cell = contentCollection.cellForItem(at: targetIndexPath) {
            let offset = cell.center.x - (UIScreen.width / 2)
            targetContentOffset.pointee.x = offset
            debugPrint("scrollViewWillEndDragging")
            contentCollection.scrollToItem(at: targetIndexPath, at: .centeredHorizontally, animated: true)
        }
        
        let dayColor = dayColors[targetIndexPath.item]
        UIView.animate(withDuration: 0.2) {
            [weak self] in
            guard let `self` = self else {return}
            self.gradientLayer.colors = [self.topColor.cgColor, dayColor.cgColor]
            
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let centerPointX = contentCollection.contentOffset.x + UIScreen.width / 2
        let centetPointY: CGFloat = contentCollection.height / 2
        let center = CGPoint.init(x: centerPointX, y:centetPointY)
        if let indexPath = contentCollection.indexPathForItem(at: center) {
            contentCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            
            
        }
        
    }
    
}

extension DSSevenPlanVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell: DSSevenPlanCell = collectionView.cellForItem(at: indexPath) as? DSSevenPlanCell {
            
            if collectionView.contentOffset.x < cell.center.x && cell.center.x < (collectionView.contentOffset.x + UIScreen.width) {
                
            } else {
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                return
            }
            // test
//            cell.startBtn.isEnabled = true
            
            if cell.startBtn.isEnabled {
                // 可以点击听
                let item = itemList[indexPath.item]
                var isTodayPan: Bool = true
                if cell.status == "before" {
                    isTodayPan = false
                }
                currentBgVideoImage = videoBgImages[indexPath.item]
                startActionTodayPlan(planItem: item, isTodayPan: isTodayPan, day: indexPath.item + 1)
            } else {
                // 不可以点击听
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}








