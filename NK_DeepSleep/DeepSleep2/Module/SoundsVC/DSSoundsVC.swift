//
//  DSSoundsVC.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/7.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import SEExtensions
import JXPagingView
import JXSegmentedView
import JXPopupView
import Alertift
import MediaPlayer
import SwifterSwift
import NoticeObserveKit
import DeviceKit

extension Notice.Names {
    static let noti_pauseCurrentSounds =
        Notice.Name<Any?>(name: "noti_pauseCurrentSounds")
    
    
    
//    Notice.Center.default.post(name: Notice.Names.receiptInfoDidChange, with: nil)
//    NotificationCenter.default.nok.observe(name: .keyboardWillShow) { keyboardInfo in
//        print(keyboardInfo)
//    }
//    .invalidated(by: pool)
}

class DSSoundsVC: UIViewController {
    var montherVC: UIViewController?
    @IBOutlet weak var canvasBgView: UIView!
    @IBOutlet weak var bottomBgView: UIView!
    @IBOutlet weak var topSoundConfigBtn: UIButton!
    @IBAction func topSoundConfigBtnClick(_ sender: UIButton) {
        hiddenVolumeSettingView()
        showSoundsConfigPopup()
        showSoundsConfigBtnAnimation(isStart: true)
    }
    
    @IBOutlet weak var randomMixBtn: UIButton!
    @IBAction func randomMixBtnClick(_ sender: UIButton) {
        soundsToolRandomAction()
    }
    
    @IBOutlet weak var bottomBgViewHeight: NSLayoutConstraint!
    
    var textF1 = UITextField()
    
    var headerInSectionHeight: Int = 50
    lazy var pagingView: JXPagingView = JXPagingView(delegate: self)
    lazy var segmentedView: JXSegmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: CGFloat(headerInSectionHeight)))
    var dataSource = JXSegmentedTitleDataSource()
    var titles = [""]
    
    var soundsBundleList: [SoundBundle] = []
    
    var soundsPreview: DSMPSoundsPreview?
    var volumeSettingView: DSMPVolumeView?
    var currentSoundsItemContentVC: DSSoundsItemContentVC?
    
    
    var viewWillApearOnce: Once = Once()
    
    var soundsConfigPopup: DSSoundsActionPopupView = DSSoundsActionPopupView()
    
    let maxLableCount: Int = 20
    
    
    var playCommandTarget: Any?
    var pauseCommandTarget: Any?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        debugPrint("\(self)已销毁")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        addObserver()
        setupData()
        setupView()
        setupCollection()
        initPlayerCountDownTimer()
//        setupRemoteTransportControls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillApearOnce.run {
            setupSoundsControlView()
            
            randomMixBtn.font(14, .Quicksand_Medium)
            canvasBgView.bringSubviewToFront(randomMixBtn)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupRemoteTransportControls()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeAllCommand()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let soundsPreview_T = soundsPreview {
            soundsPreview_T.center = CGPoint.init(x: canvasBgView.width / 2, y: canvasBgView.height / 2)
        }
        pagingView.frame = self.bottomBgView.bounds
    }

    
    
    
}

extension DSSoundsVC {
    
    func initPlayerCountDownTimer() {
        //TODO: 倒计时Block
        DSMPPlayerManager.default.setupDefaultCountDowTimerValue()
        DSMPPlayerManager.default.countDownTimerActionBlock = { [weak self] secoudValue, timeString in
            guard let `self` = self else {return}
            DispatchQueue.main.async {
                [weak self] in
                guard let `self` = self else {return}
                self.soundsPreview?.updateCountDownTimer(secound: secoudValue, isHandMoveToZero: false)
                if secoudValue <= 0 {

                    self.soundsPreview?.changePreviewStatus(isChangeToStart_m: false)
                }
                
            }
                
        }
        
    }
  
    func showSoundsConfigBtnAnimation(isStart: Bool) {
        
        if isStart {
            
            UIView.animate(withDuration: 0.3) {
                DispatchQueue.main.async {
                    [weak self] in
                    guard let `self` = self else {return}
                    self.topSoundConfigBtn.transform = CGAffineTransform(rotationAngle: .pi/4)
                    
                }
            }
        } else {
            
            UIView.animate(withDuration: 0.3) {
                
                DispatchQueue.main.async {
                    [weak self] in
                    guard let `self` = self else {return}
                    self.topSoundConfigBtn.transform = CGAffineTransform.identity
                    
                }
            }
        }
    }
    
    func showSoundsConfigPopup() {
        
        let width: CGFloat = 160
        let height: CGFloat = 110
        let x: CGFloat = UIScreen.width - width - 17
        let y: CGFloat = topSoundConfigBtn.frame.maxY + 10
        
        let layout: BaseAnimator.Layout = .frame(CGRect(x: x, y: y, width: width, height: height))
        let animator = FadeInOutAnimator(layout: layout)
        
        let popupView = PopupView(containerView: view, contentView: soundsConfigPopup, animator: animator)
        popupView.willDismissCallback = {
            [weak self] in
            guard let `self` = self else {return}
            self.showSoundsConfigBtnAnimation(isStart: false)
        }
         
        soundsConfigPopup.randomActionBlock = {
            [weak self] in
            guard let `self` = self else {return}
            self.soundsToolRandomAction()
            popupView.dismiss(animated: true, completion: nil)
            
        }
        soundsConfigPopup.myFavoriteActionBlock = {
            [weak self] in
            guard let `self` = self else {return}
            self.soundsToolMyFavoriteAction()
            popupView.dismiss(animated: true, completion: nil)
        }
        soundsConfigPopup.addFavoriteActionBlock = {
            [weak self] in
            guard let `self` = self else {return}
            self.soundsToolAddToFavoriteAction()
            popupView.dismiss(animated: true, completion: nil)
        }
        
        var hasAudioItem: Bool = false
        DSMPPlayerManager.default.audioItemList.forEach {
            if $0.audioItem != nil {
                hasAudioItem = true
            }
        }
        if hasAudioItem {
            soundsConfigPopup.addToFavoriteBtn.isEnabled(true)
        } else {
            soundsConfigPopup.addToFavoriteBtn.isEnabled(false)
        }
            
            
        //配置交互
        popupView.isDismissible = true
        popupView.isInteractive = true
        //可以设置为false，再点击弹框中的button试试？
        //        popupView.isInteractive = false
        popupView.isPenetrable = false
        //- 配置背景
        popupView.backgroundView.style = .solidColor
        popupView.backgroundView.color = .clear
        popupView.display(animated: true, completion: nil)
    }
    
}

extension DSSoundsVC {
    func soundsToolRandomAction() {
        MTEvent.default.tga_eventRandommixClick()
         
        if !isNetworkConnect {
            let firstBundle = soundsBundleList.first
            segmentedView.selectItemAt(index: 0)
            DSMPPlayerManager.default.randomAudioItems(audoItemList: firstBundle?.sounds ?? []) {
                [weak self] in
                guard let `self` = self else {return}
                DispatchQueue.main.async {
                    self.soundsPreview?.updateSoundsPreviewWith(itemList: DSMPPlayerManager.default.audioItemList)
                    self.currentSoundsItemContentVC?.updateCellStatus(itemList: DSMPPlayerManager.default.audioItemList)
                }
            }
            return
        }
        if PurchaseManager.default.inSubscription {
            let index = soundsBundleList.firstIndex {
                if $0.is_free == 0 {
                    return true
                }
                return false
            }
             
            segmentedView.selectItemAt(index: index ?? 1)
        }
//        guard let currentSoundsItemContentVC = currentSoundsItemContentVC else { return }
        debugPrint("*** begin random = \(Date().timeIntervalSince1970)")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            [weak self] in
            guard let `self` = self else {return}
            guard let currentSoundsItemContentVC = self.currentSoundsItemContentVC else { return }
            if currentSoundsItemContentVC.currentBundle?.is_free == 1 || PurchaseManager.default.inSubscription {
                
                let soundsList = currentSoundsItemContentVC.currentContentList
                
                DSMPPlayerManager.default.randomAudioItems(audoItemList: soundsList) {
                    [weak self] in
                    guard let `self` = self else {return}
                    DispatchQueue.main.async {
                        
                        debugPrint("*** end random = \(Date().timeIntervalSince1970)")
                        self.soundsPreview?.updateSoundsPreviewWith(itemList: DSMPPlayerManager.default.audioItemList)
                        self.currentSoundsItemContentVC?.updateCellStatus(itemList: DSMPPlayerManager.default.audioItemList)
                    }
                    
                }
            } else {
                let firstBundle = self.soundsBundleList.first
                self.segmentedView.selectItemAt(index: 0)
                DSMPPlayerManager.default.randomAudioItems(audoItemList: firstBundle?.sounds ?? []) {
                    [weak self] in
                    guard let `self` = self else {return}
                    DispatchQueue.main.async {
                        debugPrint("*** end random = \(Date().timeIntervalSince1970)")
                        self.soundsPreview?.updateSoundsPreviewWith(itemList: DSMPPlayerManager.default.audioItemList)
                        self.currentSoundsItemContentVC?.updateCellStatus(itemList: DSMPPlayerManager.default.audioItemList)
                    }
                }
            }
        }
        
        DSMPPlayerManager.default.downloadProgressStatusUpdateUIBlock = {
            [weak self] in
            debugPrint("*** self.currentSoundsItemContentVC?.updateCellStatus")
            guard let `self` = self else {return}
            DispatchQueue.main.async {
                
                self.currentSoundsItemContentVC?.updateCellStatus(itemList: DSMPPlayerManager.default.audioItemList)
            }
        }
        
    }
    func soundsToolMyFavoriteAction() {
        let favoriteVC = DSMyFavoriteVC()
        self.navigationController?.pushViewController(favoriteVC)
        favoriteVC.didSelectCurrentFavoriteItemBlock = {[weak self] item in
            guard let `self` = self else {return}
            if let itemSoundsList = item.sounds {
                self.playFavoriteMusic(items: itemSoundsList)
            }
            
        }
        MTEvent.default.tga_eventFavoriteShow()
         
    }
    
    func playFavoriteMusic(items: [DSFavoriteModel.FavoriteSound]) {
        
        DSMPPlayerManager.default.playFavoriteAudioItems(favoriteItemList: items) {
            [weak self] in
            guard let `self` = self else {return}
            DispatchQueue.main.async {
                self.soundsPreview?.updateSoundsPreviewWith(itemList: DSMPPlayerManager.default.audioItemList)
                self.currentSoundsItemContentVC?.updateCellStatus(itemList: DSMPPlayerManager.default.audioItemList)
            }
        }
         
    }
    
    
    func soundsToolAddToFavoriteAction() {
        
        func doAddToFavorite() {
            var hasAudioItem: Bool = false
            
            DSMPPlayerManager.default.audioItemList.forEach {
                if $0.audioItem != nil {
                    hasAudioItem = true
                }
            }
            
            if hasAudioItem {
                showAddToFavoriteInputNameAlert()
            } else {
                showHasNoPlayingAudioItemAlert()
            }
        }
        
        func showStoreVC() {
            AppDelegate.showSubscriptionVC(source: "favorite")
        }
        
        DSDBHelper.default.loadAllFavorite { result in
            DispatchQueue.main.async {
                
                if !PurchaseManager.default.inSubscription && result.count >= 5 {
                    showStoreVC()
                } else {
                    doAddToFavorite()
                }
            }
        }
    }
    
    
    
}

extension DSSoundsVC {
    func addToFavoriteAction(name: String) {
        var favoriteName = name
//        if favoriteName == "" {
//            favoriteName = Date().timeIntervalSince1970.string
//        }
        DSMPPlayerManager.default.addFavoriteAction(favoriteName: favoriteName) {
            DispatchQueue.main.async {
                self.showAddToMyFavoriteSuccessAlert()
            }
        }
    }
}

extension DSSoundsVC {
    func showAddToFavoriteInputNameAlert() {
            //设置中间变量textF1
        let alertC = UIAlertController(title: "", message: "Please Input a name of the sounds", preferredStyle: UIAlertController.Style.alert)
        let alertA = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {[weak self] (act) -> Void in
            
            guard let `self` = self else {return}
            debugPrint(self.textF1.text ?? "cancel")
        }
        let alertB = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {[weak self] (act) -> Void in
            guard let `self` = self else {return}
            debugPrint(self.textF1.text ?? "ok")
            
            self.addToFavoriteAction(name: self.textF1.text ?? "")
            
        }
        alertC.addTextField {[weak self] (textField1) -> Void in
            guard let `self` = self else {return}
            self.textF1 = textField1
            self.textF1.delegate = self
            self.textF1.placeholder = "Please input name"
        }
        alertC.addAction(alertA)
        alertC.addAction(alertB)
        self.montherVC?.present(alertC)
    }
    
    func showHasNoPlayingAudioItemAlert() {
        HUD.success("Please add music first")
//        Alertift.alert(title: "No music", message: "Please add music").action(.cancel("Ok")).show()
    }
    
    func showAddToMyFavoriteSuccessAlert() {
        HUD.success("Add Favorite Success")
//        Alertift.alert(title: "Add Favorite Success", message: "").action(.cancel("Ok")).show()
    }
    
    
}

extension DSSoundsVC {
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(getDeepSleepResourceSuccess), name: Notification.Name("getDeepSleepResource"), object: nil)
        
        setupTextViewNotification()
        
        NotificationCenter.default.nok.observe(name: .noti_pauseCurrentSounds) {_ in
            DispatchQueue.main.async {
                
                DSMPPlayerManager.default.pausePlayerCountDownTimer()
                DSMPPlayerManager.default.changePlayerStatus(isPause: true)
                
                self.soundsPreview?.updateSoundsPreviewWith()
                self.currentSoundsItemContentVC?.updateCellStatus()
                self.volumeSettingView?.updateContentStatus()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActiveNotifi), name: UIApplication.willResignActiveNotification, object: nil)
         
        
    }
    
    @objc func willResignActiveNotifi() {
        DSMPPlayerManager.default.addLastHistorySoundsAction {
            debugPrint("record history")
        }
    }
    
    
    @objc func getDeepSleepResourceSuccess() {
        guard let resourceModel = Request.default.resourceModel else { return }
        guard let sceneList = resourceModel.sound else { return }
        soundsBundleList = sceneList
        
        titles = soundsBundleList.compactMap {
            return $0.tag_name
        }
        DispatchQueue.main.async {
            [weak self] in
            guard let `self` = self else {return}
            self.pagingView.reloadData()
            self.dataSource.titles = self.titles
            self.segmentedView.dataSource = self.dataSource
            self.segmentedView.reloadData()
        }
    }
    
    func loadData() {
        guard let resourceModel = Request.default.resourceModel else { return }
        guard let sceneList = resourceModel.sound else { return }
        soundsBundleList = sceneList
        titles = soundsBundleList.compactMap {
            return $0.tag_name
        }
        pagingView.reloadData()
        segmentedView.reloadData()
    }
    
}

extension DSSoundsVC {
    
    
    
    
    func setupData() {
        DSDBHelper.default.loadRecordLastHistorySounds {[weak self] (soundsList) in
            guard let `self` = self else {return}
            self.playFavoriteMusic(items: soundsList)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                Notice.Center.default.post(name: Notice.Names.noti_pauseCurrentSounds, with: nil)
            }
            
        }
        
    }
    
    func setupView() {
        if Device.current.diagonal <= 4.7 || Device.current.diagonal >= 7.9 {
            bottomBgViewHeight.constant = 300
        }
    }
    
    func setupCollection() {
        dataSource.titles = titles
        
        dataSource.titleNormalColor = UIColor.white.withAlphaComponent(0.4)
        dataSource.titleSelectedColor = UIColor.white.withAlphaComponent(0.8)
        dataSource.titleNormalFont = UIFont.custom(16, name: .Quicksand_Medium)
        dataSource.titleSelectedFont = UIFont.custom(16, name: .Quicksand_Medium)
        dataSource.itemWidthSelectedZoomScale = 0
        dataSource.isTitleColorGradientEnabled = true
        dataSource.isTitleZoomEnabled = false

        segmentedView.backgroundColor = UIColor.clear
        segmentedView.delegate = self
        segmentedView.dataSource = dataSource
        
        
        
        bottomBgView.addSubview(pagingView)
        segmentedView.listContainer = pagingView.listContainerView
        
        pagingView.mainTableView.backgroundColor = .clear
        pagingView.mainTableView.alwaysBounceVertical = false
        pagingView.mainTableView.bounces = false
        pagingView.listContainerView.listCellBackgroundColor = .clear
    }
    
    //TODO: sounds volume setting
    func setupSoundsControlView() {
        let width = UIScreen.width * 0.8
        let height = width
        let x = (UIScreen.width - width) / 2
        let y: CGFloat = 10
        soundsPreview = DSMPSoundsPreview.init(frame: CGRect.init(x: x, y: y, width: width, height: height))
        
        if let soundsPreview_T = soundsPreview {
            canvasBgView.addSubview(soundsPreview_T)
            soundsPreview_T.settingBtnClickBlock = {
                [weak self] in
                guard let `self` = self else {return}
                DispatchQueue.main.async {
                    self.showVolumeSettingView()
                }
            }
            //TODO: Click Thumb 播放按钮
            soundsPreview_T.clickSoundsBtnsUpdateUIBlock = {
                [weak self] in
                guard let `self` = self else {return}
                
                DispatchQueue.main.async {
                    self.currentSoundsItemContentVC?.updateCellStatus(itemList: DSMPPlayerManager.default.audioItemList)
                    self.volumeSettingView?.updateContentStatus()
                }
            }
            soundsPreview_T.clickBtnCloseVolumeSettingBlock = {
                DispatchQueue.main.async {
                    self.hiddenVolumeSettingView()
                    
                }
            }
        }
    }
    
    func hiddenVolumeSettingView() {
        guard let volumeSettingView = volumeSettingView else { return }
        if volumeSettingView.alpha == 1 {
            volumeSettingView.alpha = 0
        }
    }
    
    //TODO: sounds Volume Setting ChangeBlock
    func showVolumeSettingView(itemList: [ContentPlayerItem] = DSMPPlayerManager.default.audioItemList) {
        if volumeSettingView == nil {
            volumeSettingView = DSMPVolumeView.init(frame: bottomBgView.frame)
            volumeSettingView?.alpha = 0
            guard let volumeSettingView = volumeSettingView else { return }
            view.addSubview(volumeSettingView)
            
        }
        guard let volumeSettingView = volumeSettingView else { return }
        if volumeSettingView.alpha == 0 {
            MTEvent.default.tga_eventConsoleVolume()
            volumeSettingView.alpha = 1
            volumeSettingView.updateContentStatus()
        } else {
            volumeSettingView.alpha = 0
        }
         
        volumeSettingView.closeBtnActionBlock = {
            [weak self] in
            guard let `self` = self else {return}
            volumeSettingView.alpha = 0
        }
        
        volumeSettingView.soundsVolumeChangeBlock = { trackIndex, value in
            
//            DSMPPlayerManager.default.changeVolume(value: Float(value), index: trackIndex)
            
            DSMPPlayerManager.default.changeVolume(value: Float(value), index: trackIndex) { [weak self] (isRefreshCollection) in
                guard let `self` = self else {return}
                self.currentSoundsItemContentVC?.updateCellStatus(itemList: DSMPPlayerManager.default.audioItemList)
            }
            self.soundsPreview?.updateSoundsPreviewWith()
            
            
        }
        
        
        
        
    }
    
}

extension JXPagingListContainerView: JXSegmentedViewListContainer {}






extension DSSoundsVC: JXPagingViewDelegate {

    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        return 0
    }

    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        return UIView()
    }

    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        return headerInSectionHeight
    }

    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        return segmentedView
    }

    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return titles.count
    }

    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        
        let bundle = soundsBundleList[index]
        let audioItems = bundle.sounds
        
        
        
        let contentVC = DSSoundsItemContentVC()
        contentVC.currentBundle = bundle
        contentVC.currentContentList = audioItems ?? []
        contentVC.didSelectContentItemBlock = { soundsContentItem, iconImage in
            if bundle.is_free == 1 || PurchaseManager.default.inSubscription {
                
                //TODO: 选择 播放 Sounds Cell
                
                
                
                
                let contentItem_M = DSMPPlayerManager.default.audioItemList.first {
                    $0.audioItem?.name == soundsContentItem.name
                }
                
                if let contentItem = contentItem_M {
                    //TODO: 有
                    switch contentItem.itemStatus {
                    case .playing:
                        DSMPPlayerManager.default.pauseAudioTrack(index: contentItem.index)
                    case .pause:
                        DSMPPlayerManager.default.openAudioTrack(index: contentItem.index)
                    default:
                        break
                    }
                    
                } else {
                    //TODO: 无
                    DSMPPlayerManager.default.addAudioItem(item: soundsContentItem, iconImage: iconImage)
                    DSMPPlayerManager.default.downloadProgressStatusUpdateUIBlock = {
                        [weak self] in
                        debugPrint("*** self.currentSoundsItemContentVC?.updateCellStatus")
                        guard let `self` = self else {return}
                        DispatchQueue.main.async {
                            
                            self.currentSoundsItemContentVC?.updateCellStatus(itemList: DSMPPlayerManager.default.audioItemList)
                        }
                    }
                    
                    MTEvent.default.tga_eventSoundClick(itemName: bundle.tag_name ?? "soundTitleName")
                }
                DispatchQueue.main.async {
                    //TODO: update preview
                    self.currentSoundsItemContentVC?.updateCellStatus()
                    self.soundsPreview?.updateSoundsPreviewWith(itemList: DSMPPlayerManager.default.audioItemList)
                }
                
                
                
            } else {
                AppDelegate.showSubscriptionVC(source: "sound")
            }
            
        }
        
        currentSoundsItemContentVC = contentVC
        
        return contentVC
    } 
    
    
}
//, JXSegmentedViewDataSource
extension DSSoundsVC: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if let listContainer = segmentedView.listContainer as? JXPagingListContainerView , let itemContentVC = listContainer.validListDict[index] as? DSSoundsItemContentVC {
            currentSoundsItemContentVC = itemContentVC
            
            currentSoundsItemContentVC?.updateCellStatus(itemList: DSMPPlayerManager.default.audioItemList)
            
        }
    }
    
    
}


extension DSSoundsVC {
    
    func removeAllCommand() {
//        MPRemoteCommandCenter.shared().playCommand.removeTarget(playCommandTarget)
//        MPRemoteCommandCenter.shared().pauseCommand.removeTarget(pauseCommandTarget)
        
        MPRemoteCommandCenter.shared().playCommand.removeTarget(self)
        MPRemoteCommandCenter.shared().pauseCommand.removeTarget(self)
    }
    
    ////////
    @objc func remoteCommandPlayAction(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if DSMPPlayerManager.default.isPause {
            DSMPPlayerManager.default.changePlayerStatus(isPause: false)
            self.soundsPreview?.changePreviewStatus(isChangeToStart_m: true)
        }
        return .commandFailed
    }
    @objc func remoteCommandPauseAction(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if !DSMPPlayerManager.default.isPause {
            DSMPPlayerManager.default.changePlayerStatus(isPause: true)
            self.soundsPreview?.changePreviewStatus(isChangeToStart_m: false)
            return .success
        }
        return .commandFailed
    }
    
    ///////
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget(self, action: #selector(remoteCommandPlayAction(event:)))
        commandCenter.pauseCommand.addTarget(self, action: #selector(remoteCommandPauseAction(event:)))
        
        
        
        // Add handler for Play Command
//        playCommandTarget = commandCenter.playCommand.addTarget { [unowned self] event in
//
//            if DSMPPlayerManager.default.isPause {
//                DSMPPlayerManager.default.changePlayerStatus(isPause: false)
//                self.soundsPreview?.changePreviewStatus(isChangeToStart_m: true)
//            }
//            return .commandFailed
//        }
        
        
        
        // Add handler for Pause Command
//        pauseCommandTarget = commandCenter.pauseCommand.addTarget { [unowned self] event in
//            if !DSMPPlayerManager.default.isPause {
//                DSMPPlayerManager.default.changePlayerStatus(isPause: true)
//
//                self.soundsPreview?.changePreviewStatus(isChangeToStart_m: false)
//
//                return .success
//            }
//            return .commandFailed
//        }
        
        // Add handler for Next Command
//        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
//            if let itemList = self.currentSoundsItemContentVC?.currentContentList {
//                self.soundsToolRandomAction()
//                return .success
//            }
//            return .success
//        }
//
//        // Add handler for Previous Command
//        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
//            if let itemList = self.currentSoundsItemContentVC?.currentContentList {
//                self.soundsToolRandomAction()
//                return .success
//            }
//            return .success
//        }
    }
    
    func updateNowPlaying(with musicItem: MusicItem?) {
    
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        
        nowPlayingInfo[MPMediaItemPropertyArtist] = UIApplication.shared.displayName ?? "DeepSleep"
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = musicItem?.name ?? "DeepSleep"
        
        if let image = UIImage.named("icon_small") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ -> UIImage in
                return image
            })
        }
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}




extension DSSoundsVC: UITextFieldDelegate {
    
    func setupTextViewNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(textViewNotifitionAction), name: UITextField.textDidChangeNotification, object: nil);
    }
    @objc
    func textViewNotifitionAction(userInfo:NSNotification){
        guard let textView = userInfo.object as? UITextField else { return }
        if textView.text?.count ?? 0 >= maxLableCount {
            let selectRange = textView.markedTextRange
            if let selectRange = selectRange {
                let position =  textView.position(from: (selectRange.start), offset: 0)
                if (position != nil) {
                    // 高亮部分不进行截取，否则中文输入会把高亮区域的拼音强制截取为字母，等高亮取消后再计算字符总数并截取
                    return
                }

            }
            textView.text = String(textView.text?[..<String.Index(encodedOffset: maxLableCount)] ?? "")

            // 对于粘贴文字的case，粘贴结束后若超出字数限制，则让光标移动到末尾处
//            textView.selectedRange = NSRange(location: textView.text?.count ?? 0, length: 0)
            
        }
        
//        contentText = textView.text
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        debugPrint("textFieldDidBeginEditing")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let selectedRange = textField.markedTextRange
        if let selectedRange = selectedRange {
            let position =  textField.position(from: (selectedRange.start), offset: 0)
            if position != nil {
                let startOffset = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
                let endOffset = textField.offset(from: textField.beginningOfDocument, to: selectedRange.end)
                let offsetRange = NSMakeRange(startOffset, endOffset - startOffset) // 高亮部分起始位置
                if offsetRange.location < maxLableCount {
                    // 高亮部分先不进行字数统计
                    return true
                } else {
                    debugPrint("字数已达上限")
                    return false
                }
            }
        }
        
        // 在最末添加
        if range.location >= maxLableCount {
            debugPrint("字数已达上限")
            return false
        }
        
        // 在其他位置添加
        if textField.text?.count ?? 0 >= maxLableCount && range.length <  string.count {
            debugPrint("字数已达上限")
            return false
        }
        
        if (textField.text ?? "" + string).count > maxLableCount {
            
            let finalString = string.prefix(maxLableCount - (textField.text?.count ?? 0))
            textField.text = (textField.text ?? "" + finalString)
        }
        
        return true
    }
    
}









 







