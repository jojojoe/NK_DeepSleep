//
//  DSSevenPlanPlayerVC.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/9/9.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import PickerView
import Kingfisher
import MediaPlayer
import SwifterSwift
import AVFoundation
import ZKProgressHUD

class DSSevenPlanPlayerVC: UIViewController {
    
    var currenCountDownTime: String = 30.string
    var currenCountDownTime_Temp: String = 30.string
    
    var musicItemList: [MusicItem] = []
    var currenMusicItem: MusicItem?
    
    var player : AVPlayer!
    var playerLayer : AVPlayerLayer!
    
    
    @IBOutlet weak var backBtn: UIButton!
    @IBAction func backBtnClick(_ sender: UIButton) {
        clearPauseCurrentMusic()
        popVC()
    }
    @IBOutlet weak var topTitleLabel: UILabel!
    
    @IBOutlet weak var bgVideoView: UIView!
    @IBOutlet weak var bgVideoPlacehoderImageView: UIImageView!
    
    @IBOutlet weak var playBtn: UIButton!
    @IBAction func playControlBtnClick(_ sender: UIButton) {
        //        if !isNetworkConnect {
        //            HUD.error("Network unavailable,please check.")
        //            return
        //        }
        
        if !DSSencePlayerManager.default.isPause {
            // 当前是 正在 播放状态 ->更改未 暂停
            updatePlayBtnStatus(isPlaying: false)
            DSSencePlayerManager.default.changePlayerStatus(isPause: true)
            DSSencePlayerManager.default.pausePlayerCountDownTimer()
            
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
   
            
            
        }
        
        
        
        
    }
    
    @IBOutlet weak var countDownTimeLabel: UILabel!
    @IBOutlet weak var countDownSetBtn: UIControl!
    @IBAction func countDownSetBtnClick(_ sender: UIControl) {
        showCountDownBgViewStatus(isShow: true)
    }
    
    // setting time
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
    
    
    var planItem: SevenPlanItem
    var bgPlaceholder: String
    var gesturePopBegin: Bool = false
    
    init(planItem: SevenPlanItem, bgPlaceholder: String) {
        self.bgPlaceholder = bgPlaceholder
        self.planItem = planItem
        super.init(nibName: "DSSevenPlanPlayerVC", bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTitleLabel.text = "Day \(planItem.day ?? 0)"
        timePickerView.delegate = self
        timePickerView.dataSource = self
        
        initPlayerCountDownTimer()
        setupDefaultCountDownTime()
        setupPlayerManager()
        startPlayer()
        setupBgVideo()
        
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
     

}

extension DSSevenPlanPlayerVC {
    
    func setupPlayerManager() {
        DSSencePlayerManager.default.currenPlayStatusBufferingBlock = {
            [weak self] in
            guard let `self` = self else {return}
            //            self.countDownSetBtn.isHidden = true
//            self.loadingIndicatorView.isHidden = false
//            self.loadingIndicatorView.startAnimating()
            
            ZKProgressHUD.setMaskStyle(.visible)
            ZKProgressHUD.setEffectAlpha(0)
            ZKProgressHUD.show()
        }
        DSSencePlayerManager.default.currenPlayStatusEndBufferBlock = {
            //            self.countDownSetBtn.isHidden = false
            
//            self.loadingIndicatorView.isHidden = true
//            self.loadingIndicatorView.stopAnimating()
            ZKProgressHUD.dismiss()
        }
    }
    func startPlayer() {
        
        // test
//        https://source.funnyplay.me/SleepMedia/sound/Nature/cicada.mp3
        if planItem.music_url == nil {
            planItem.music_url = "https://source.funnyplay.me/SleepMedia/sound/Nature/cicada.mp3"
        }
//        planItem.music_url = "https://source.funnyplay.me/SleepMedia/sound/Nature/cicada.mp3"
        
        let musicItem = MusicItem.init(name: planItem.dayDesc()?["title"] ?? "Day1", duration: 0, media_url: planItem.music_url, icon_url: nil, is_free: 0)
        musicItemList = [musicItem]
        currenMusicItem = musicItem
        
        DSSencePlayerManager.default.startPlayerMusicItem(musicItem: musicItem, musicList: musicItemList)
        
        let url = DSMeidaLocalCheckManager.checkLocalUrl(music: musicItem, completion: { (musicUrl) in
            
            
        }, progressBlock: { (progressValue) in
            
        }) {
            
        }
        
        
        if let _ = url {
            
            
        } else {
            if !isNetworkConnect {
                
                return
            }
        }
        
        
        updateNowPlaying(with: musicItem)
        
        updatePlayBtnStatus(isPlaying: true)
        
        
        
    }
    
    func setupDefaultCountDownTime() {
        
        resetupCountDownTime(value: currenCountDownTime, isFireNow: false)
        
         
    }
    
  
    
    func setupBgVideo() {
        
        bgVideoPlacehoderImageView.image = UIImage.named(self.bgPlaceholder)
        
        let url = DSMeidaLocalCheckManager.checkBgVideoLocalUrl(planItem: planItem, completion: {[weak self] (url) in
            guard let `self` = self else {return}
            
            self.setupBgVideoWithURL(videoUrl: url)
        }, progressBlock: { (porogress) in
            
        }) {
            // begin download
        }
        
       
        setupBgVideoWithURL(videoUrl: url)
         
 
        
    }
    
    func setupBgVideoWithURL(videoUrl: URL?) {
        
        if let url = videoUrl {
            let playerItem = AVPlayerItem.init(url: url)
            
            player = AVPlayer.init(playerItem: playerItem)
            playerLayer = AVPlayerLayer.init(player: player)
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            playerLayer.frame = CGRect.init(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height)
            
            bgVideoView.layer.addSublayer(playerLayer)
            
            player.play()
            
            
            player?.actionAtItemEnd = .none
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
            
            bgVideoPlacehoderImageView.isHidden = false
        } else {
            bgVideoPlacehoderImageView.isHidden = false
        }
        
        
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {

        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)

        }

    }
    
}


extension DSSevenPlanPlayerVC {
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
//            self.musicCollection.reloadData()
        }
        
    }
    
//    func updateCountDownTimeUIStatus(secound: Int) {
//        let timeString = secound.secondsToTimeString(formatString: "%02lu:%02lu")
//        countDownTimeLabel.text = timeString
//
//    }
    
     
    
    
    
    func clearPauseCurrentMusic() {
        DSSencePlayerManager.default.changePlayerStatus(isPause: true)
        DSSencePlayerManager.default.pausePlayerCountDownTimer()
        DSSencePlayerManager.default.clearCurrentMusicItem()
    }
    
}


extension DSSevenPlanPlayerVC {
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
    
    func updateCountDownTimeUIStatus(secound: Int) {
        let timeString = secound.secondsToTimeString(formatString: "%02lu:%02lu")
        countDownTimeLabel.text = timeString
        
    }
    
    func updatePlayBtnStatus(isPlaying: Bool) {
        if isPlaying {
            playBtn.setImage(UIImage.named("pause_ic"), for: .normal)
        } else {
            playBtn.setImage(UIImage.named("play_ic"), for: .normal)
        }
    }
    
}

extension DSSevenPlanPlayerVC {
    
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
        
        
        
    }
}




extension DSSevenPlanPlayerVC: PickerViewDelegate, PickerViewDataSource {
     
    
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
