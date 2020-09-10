//
//  DSSencePlayVC.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/15.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import PickerView
import Kingfisher
import MediaPlayer
import SwifterSwift

class DSSencePlayVC: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var topBgImageView: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBAction func backBtnClick(_ sender: UIButton) {
        clearPauseCurrentMusic()
        popVC()
    }
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBAction func playBtnClick(_ sender: UIButton) {
//        if !isNetworkConnect {
//            HUD.error("Network unavailable,please check.")
//            return
//        }
        
        if !DSSencePlayerManager.default.isPause {
            // 当前是 正在 播放状态 ->更改未 暂停
            updatePlayBtnStatus(isPlaying: false)
            DSSencePlayerManager.default.changePlayerStatus(isPause: true)
            DSSencePlayerManager.default.pausePlayerCountDownTimer()
            musicCollection.reloadData()
        } else {
            // 当前是 暂停 播放状态 ->更改未 开始
            
            if DSSencePlayerManager.default.countDownTimer?.secondsToEnd ?? 0 <= 0 {
                resetupCountDownTime(value: "30", isFireNow: false)
//                DSSencePlayerManager.default.resetStartCountDownTimer(countDownValue: 30, isFireNow: false)
            }
            if let _ = DSSencePlayerManager.default.currentMusicItem {
                DSSencePlayerManager.default.changePlayerStatus(isPause: false)
            } else {
                if let currenMusicItem = currenMusicItem {
                    
                    DSSencePlayerManager.default.startPlayerMusicItem(musicItem: currenMusicItem, musicList: musicItemList)
                    
                    let url = DSMeidaLocalCheckManager.checkLocalUrl(music: currenMusicItem, completion: { (musicUrl) in
                        
                        
                    }, progressBlock: { (progressValue) in
                        
                    }) {
                        
                    }
                    
                    
                    if let _ = url {
                        
                        
                    } else {
                        if !isNetworkConnect {
                            
                            return
                        }
                    }
                    
                }
            }
            
            updatePlayBtnStatus(isPlaying: true)
 
            
            musicCollection.reloadData()
        }
        
        
        
        
    }
    @IBOutlet weak var countDownSetBtn: UIControl!
    @IBAction func countDownSetBtnClick(_ sender: UIControl) {
        showCountDownBgViewStatus(isShow: true)
    }
    @IBOutlet weak var countDownTimeLabel: UILabel!
    @IBOutlet weak var musicCollection: UICollectionView!
    
    @IBOutlet weak var timeSettingBgView: UIView!
    @IBOutlet weak var timePickerView: PickerView!
    
    @IBOutlet weak var timeSet15Btn: UIControl!
    @IBAction func timeSet15BtnClick(_ sender: UIControl) {
        let value = 15.string
        let index = DSSencePlayVC.timePickDataList.firstIndex(of: value)
        timePickerView.selectRow(index ?? 0, animated: true)
        currenCountDownTime_Temp = value
    }
    @IBOutlet weak var timeSet30Btn: UIControl!
    @IBAction func timeSet30BtnClick(_ sender: UIControl) {
        let value = 30.string
        let index = DSSencePlayVC.timePickDataList.firstIndex(of: value)
        timePickerView.selectRow(index ?? 0, animated: true)
        currenCountDownTime_Temp = value
    }
    @IBOutlet weak var timeSet60Btn: UIControl!
    @IBAction func timeSet60BtnClick(_ sender: UIControl) {
        let value = 60.string
        let index = DSSencePlayVC.timePickDataList.firstIndex(of: value)
        timePickerView.selectRow(index ?? 0, animated: true)
        currenCountDownTime_Temp = value
    }
    @IBOutlet weak var timeSaveBtn: UIButton!
    @IBAction func timeSaveBtnClick(_ sender: UIButton) {
        //TODO: 每次滑动或更改时间的时候 更改 currenCountDownTime
        currenCountDownTime = currenCountDownTime_Temp
        
        if DSSencePlayerManager.default.isPause {
            resetupCountDownTime(value: currenCountDownTime, isFireNow: false)
        } else {
            resetupCountDownTime(value: currenCountDownTime, isFireNow: true)
        }
        
        showCountDownBgViewStatus(isShow: false)
    }
    @IBOutlet weak var timeSettingCloseBtn: UIButton!
    @IBAction func timeSettingCloseBtnClick(_ sender: UIButton) {
        showCountDownBgViewStatus(isShow: false)
    }
    
    var senceBundle: SceneBundle
    var musicItemList: [MusicItem]
    var currenCountDownTime: String = 30.string
    var currenCountDownTime_Temp: String = 30.string
    var currenMusicItem: MusicItem?
    
    var gesturePopBegin: Bool = false
    
    
    @IBOutlet weak var setTimerLabel: UILabel!
    @IBOutlet weak var setTimerMinLabel: UILabel!
    @IBOutlet weak var setTimerQuickSettingLabel: UILabel!
    
    
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var playLoopTypeBtn: UIButton!
    @IBAction func playLooptypeBtnClick(_ sender: UIButton) {
        switch DSSencePlayerManager.default.playStatus {
        case .single:
            DSSencePlayerManager.default.playStatus = .circulation
        case .circulation:
            DSSencePlayerManager.default.playStatus = .random
        case .random:
            DSSencePlayerManager.default.playStatus = .single
            
        }
        setupSencePlayerLoopType()
    }
    
    init(sence: SceneBundle) {
        senceBundle = sence
        if let musicList = senceBundle.musics {
            musicItemList = musicList
        } else {
            musicItemList = []
        }
        currenMusicItem = musicItemList.first
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if gesturePopBegin {
            clearPauseCurrentMusic()
        }
        gesturePopBegin = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gesturePopBegin = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupRemoteTransportControls()
        initPlayerCountDownTimer()
        setupSencePlayerLoopType()
        countDownTimeLabel.font(16, UIFont.FontNames.Quicksand_Medium)
        topTitleLabel.font(16, UIFont.FontNames.Quicksand_Medium)
        setTimerLabel.font(18, UIFont.FontNames.Quicksand_Medium)
        setTimerMinLabel.font(18, UIFont.FontNames.Quicksand_Bold)
        setTimerQuickSettingLabel.font(18, UIFont.FontNames.Quicksand_Medium)
        timeSaveBtn.font(16, UIFont.FontNames.Quicksand_Bold)
        
        topTitleLabel.text = senceBundle.name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
                        
        //推断是否为第一个view
        if (self.navigationController != nil && self.navigationController?.viewControllers.count == 1) {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        debugPrint("***** gestureRecognizerShouldBegin")
        gesturePopBegin = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            
        }
        return true
    }
     
//    - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
    
//    - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveEvent:(UIEvent *)event
    
}

extension DSSencePlayVC {
    func initPlayerCountDownTimer() {
        
        DSSencePlayerManager.default.countDownTimerActionBlock = { [weak self] secoudValue, timeString in
            guard let `self` = self else {return}
            DispatchQueue.main.async {
                [weak self] in
                guard let `self` = self else {return}
                
                self.updateCountDownTimeUIStatus(secound: secoudValue)
            }
        }
        
        DSSencePlayerManager.default.autoMusicChangeBlock = {[weak self]
            musicItem in
            guard let `self` = self else {return}
            self.updateNowPlaying(with: musicItem)
        }
        
        DSSencePlayerManager.default.countDownFinishedBlock = {
            [weak self] in
            guard let `self` = self else {return}
            self.updatePlayBtnStatus(isPlaying: false)
            self.musicCollection.reloadData()
        }
        
    }
    
    func updateCountDownTimeUIStatus(secound: Int) {
        let timeString = secound.secondsToTimeString(formatString: "%02lu:%02lu")
        countDownTimeLabel.text = timeString
        
    }
    
    func showCountDownBgViewStatus(isShow: Bool) {
        if isShow {
            UIView.animate(withDuration: 0.3, animations: {
                [weak self] in
                guard let `self` = self else {return}
                self.timeSettingBgView.alpha = 1
            }) { (finished) in
                
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                [weak self] in
                guard let `self` = self else {return}
                self.timeSettingBgView.alpha = 0
            }) { (finished) in
                
            }
        }
    }
    
    func setupSencePlayerLoopType() {
        switch DSSencePlayerManager.default.playStatus {
        case .single:
            playLoopTypeBtn.setImage(UIImage.named("single_cycle_ic"), for: .normal)
        case .circulation:
            playLoopTypeBtn.setImage(UIImage.named("cycle_ic"), for: .normal)
        case .random:
            playLoopTypeBtn.setImage(UIImage.named("random_ic"), for: .normal)
            
        }
        
    }
    
    func clearPauseCurrentMusic() {
        DSSencePlayerManager.default.changePlayerStatus(isPause: true)
        DSSencePlayerManager.default.pausePlayerCountDownTimer()
        DSSencePlayerManager.default.clearCurrentMusicItem()
        topBgImageView.layer.removeAllAnimations()
    }
    
}

extension DSSencePlayVC {
    func setupBgKeyAnimation() {
        
        
        topBgImageView.layer.add(createAnimation(keyPath: "transform.scale", toValue: 1.5), forKey: nil)
    }
    
    func createAnimation (keyPath: String, toValue: CGFloat) -> CABasicAnimation {
        //创建动画对象
        let scaleAni = CABasicAnimation()
        //设置动画属性
        scaleAni.keyPath = keyPath
        
        //设置动画的起始位置。也就是动画从哪里到哪里。不指定起点，默认就从positoin开始
        scaleAni.toValue = toValue
        
        //动画持续时间
        scaleAni.duration = 20;
        
        //动画重复次数
        scaleAni.repeatCount = Float(CGFloat.infinity)
        
        scaleAni.autoreverses = true
        
        return scaleAni;
    }
}

extension DSSencePlayVC {
    
    
    
    
    func setupView() {
        timePickerView.delegate = self
        timePickerView.dataSource = self
        loadingIndicatorView.isHidden = true
        setupSettingBlurView()
        setupCollectionCell()
        setupDefaultCountDownTime()
        
        //
        setupBgKeyAnimation()
        
        //
        
        
        
        if let buildinName = DSBuildinManager.default.buildinResourceName(remoteName: senceBundle.img_bg)  {
            topBgImageView.image = UIImage.init(named: buildinName)
        } else {
            topBgImageView.url(senceBundle.img_bg)
        }
        
        DSSencePlayerManager.default.currenPlayStatusBufferingBlock = {
            [weak self] in
            guard let `self` = self else {return}
//            self.countDownSetBtn.isHidden = true
            self.loadingIndicatorView.isHidden = false
            self.loadingIndicatorView.startAnimating()
        }
        DSSencePlayerManager.default.currenPlayStatusEndBufferBlock = {
//            self.countDownSetBtn.isHidden = false
            
            self.loadingIndicatorView.isHidden = true
            self.loadingIndicatorView.stopAnimating()
        }
        
    }
    
    func setupSettingBlurView() {
        let timeSettingBgBlurView = APCustomBlurView(withRadius: 10)
        timeSettingBgView.addSubview(timeSettingBgBlurView)
        timeSettingBgBlurView.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.left.top.right.bottom.equalToSuperview()
        }
        timeSettingBgView.sendSubviewToBack(timeSettingBgBlurView)
    }
    
    func setupCollectionCell() {
        musicCollection.register(nibWithCellClass: DSSencePlayCell.self)
        
    }
    
    func setupDefaultCountDownTime() {
        
        resetupCountDownTime(value: currenCountDownTime, isFireNow: false)
        
         
    }
    
    
    
}

extension DSSencePlayVC {
    func didSelectMusicItem(item: MusicItem) {
        
        DSSencePlayerManager.default.startPlayerMusicItem(musicItem: item, musicList: musicItemList)
        
        let url = DSMeidaLocalCheckManager.checkLocalUrl(music: item, completion: { (musicUrl) in
            
        }, progressBlock: { (progressValue) in
            
        }) {
            
        }
         
        
        if let _ = url {
            
            
        } else {
            if !isNetworkConnect {
                
                return
            }
        }
        
        currenMusicItem = item
        
        updateNowPlaying(with: item)
        
        updatePlayBtnStatus(isPlaying: true)
        
        if DSSencePlayerManager.default.countDownTimer?.secondsToEnd ?? 0 <= 0 {
            resetupCountDownTime(value: "30", isFireNow: false)
        }
        
//        if currenCountDownTime == "∞" {
//            
//        } else {
//            DSSencePlayerManager.default.startPlayerCountDownTimer()
//            
//        }
        musicCollection.reloadData()
    }
    
    func updatePlayBtnStatus(isPlaying: Bool) {
        if isPlaying {
            playBtn.setImage(UIImage.named("pause_ic"), for: .normal)
        } else {
            playBtn.setImage(UIImage.named("play_ic"), for: .normal)
        }
    }
    
    func resetupCountDownTime(value: String, isFireNow: Bool) {
        currenCountDownTime = value
        DSSencePlayerManager.default.currenCountDownTime = value
        if currenCountDownTime == "∞" {
            countDownTimeLabel.text = "∞"
            DSSencePlayerManager.default.resetCountDownTimerInfinity()
            
        } else {
            let value = (currenCountDownTime.int ?? 30) * 60
            updateCountDownTimeUIStatus(secound: value)
            DSSencePlayerManager.default.resetStartCountDownTimer(countDownValue: value, isFireNow: isFireNow)
            
        }
        
    }
}

extension DSSencePlayVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: DSSencePlayCell.self, for: indexPath)
        let item = musicItemList[indexPath.item]
        cell.coverImageView.url(item.icon_url, placeholderImage: UIImage.named("Bedtime"))
        cell.nameLabel.text = item.name
        cell.playingStatusBgView.isHidden = true
        cell.animationView.stop()
        if let currentItem = DSSencePlayerManager.default.currentMusicItem, currentItem.name == item.name {
            cell.playingStatusBgView.isHidden = false
            if !DSSencePlayerManager.default.isPause {
                cell.animationView.play()
            } else {
                cell.animationView.pause()
            }
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return musicItemList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

extension DSSencePlayVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 76
        let height: CGFloat = 80
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}

extension DSSencePlayVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        didSelectMusicItem(item: musicItemList[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}



extension DSSencePlayVC: PickerViewDelegate, PickerViewDataSource {
    
    static var timePickDataList: [String] = {
        var currentTime: Int = 15
        var countList: [String] = []
        
        while currentTime <= 60 {
            countList.append(currentTime.string)
            currentTime += (5)
        }
        countList.append("∞")
        #if DEBUG
//        countList.append("1")
        #endif
        return countList
    }()
    
    func pickerViewNumberOfRows(_ pickerView: PickerView) -> Int {
        return DSSencePlayVC.timePickDataList.count
    }
    func pickerView(_ pickerView: PickerView, titleForRow row: Int) -> String {
        return DSSencePlayVC.timePickDataList[row]
    }
    func pickerViewHeightForRows(_ pickerView: PickerView) -> CGFloat {
        return 40
    }
    func pickerView(_ pickerView: PickerView, didSelectRow row: Int) {
        let value = DSSencePlayVC.timePickDataList[row]
        currenCountDownTime_Temp = value
    }
    func pickerView(_ pickerView: PickerView, didTapRow row: Int) {
        
    }
    func pickerView(_ pickerView: PickerView, styleForLabel label: UILabel, highlighted: Bool) {
        
    }
    func pickerView(_ pickerView: PickerView, viewForRow row: Int, highlighted: Bool, reusingView view: UIView?) -> UIView? {
        if view == nil {
            let titleLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: pickerView.frame.width, height: 40))
            titleLabel.textAlignment = .center
            titleLabel.text = DSSencePlayVC.timePickDataList[row]
            titleLabel.textColor = .white
            titleLabel.font = UIFont.custom(20, name: .AvenirNextBold)
            
            if highlighted {
                titleLabel.font = UIFont.custom(24, name: .AvenirNextBold)
                titleLabel.textColor = .white
            } else {
                titleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
                titleLabel.font = UIFont.custom(20, name: .AvenirNextBold)
            }
            
            return titleLabel
        } else {
            if let titleLabel = view as? UILabel {
                titleLabel.text = DSSencePlayVC.timePickDataList[row]
                if highlighted {
                    titleLabel.font = UIFont.custom(24, name: .AvenirNextBold)
                    titleLabel.textColor = .white
                } else {
                    titleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
                    titleLabel.font = UIFont.custom(20, name: .AvenirNextBold)
                }
                return titleLabel
            } else {
                return nil
            }
        }
        
        
    }
}


extension DSSencePlayVC {
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            
            DSSencePlayerManager.default.changePlayerStatus(isPause: false)
            return .success
            
//            if DSSencePlayerManager.default.avPlayer.rate == 0.0 {
//                DSSencePlayerManager.default.changePlayerStatus(isPause: false)
//                return .success
//            }
//            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            DSSencePlayerManager.default.changePlayerStatus(isPause: true)
            return .success
            
//            if DSSencePlayerManager.default.avPlayer.rate == 1.0 {
//                DSSencePlayerManager.default.changePlayerStatus(isPause: true)
//                return .success
//            }
//            return .commandFailed
        }
        
        // Add handler for Next Command
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            DSSencePlayerManager.default.nextMusic()
            return .success
        }
        
        // Add handler for Previous Command
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            DSSencePlayerManager.default.previousMusic()
            return .success
        }
    }
    
    func updateNowPlaying(with musicItem: MusicItem?) {
    
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        
        nowPlayingInfo[MPMediaItemPropertyArtist] = UIApplication.shared.displayName ?? "DeepSleep"
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = musicItem?.name ?? "DeepSleep"
        
        if let image = UIImage.named("Bedtime") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ -> UIImage in
                return image
            })
        }
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        musicCollection.reloadData()
        
    }
}



