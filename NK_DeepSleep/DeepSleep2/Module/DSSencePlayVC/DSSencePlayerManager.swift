//
//  DSSencePlayerManager.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/15.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import AVFoundation
import HDSwiftCommonTools
import SwiftAudioPlayer


enum PlayStatus {
    case single
    case circulation
    case random
}

class DSDeepMusicFileManager: NSObject {
    static let `default` = DSDeepMusicFileManager()
    enum MusicFileType: String {
        case sence
        case sound
    }
 
    

    
     
    
}

class DSSencePlayerManager: NSObject {
    static let `default` = DSSencePlayerManager()
    
    var senceMusicList: [MusicItem] = []
    var currentMusicItem: MusicItem?
    
    let defaultVolumeValue: Float = 0.5
    var countDownTimer: ZJKillTimer?
    var isPause: Bool = true
    var countDownTimerActionBlock: ((_ secoudValue: Int, _ timeString: String)->Void)?
    
//    var avPlayer: AVPlayer = AVPlayer.init(playerItem: nil)
    var avPlayer = SAPlayer.shared
    var playStatus: PlayStatus = .circulation
    
    
    var currentSAPlayingStatus: SAPlayingStatus = .ended
    
    var currenCountDownTime: String = ""
    
    var currenPlayStatusBufferingBlock: (()->Void)?
    var currenPlayStatusEndBufferBlock: (()->Void)?
    
    
    
    var autoMusicChangeBlock: ((_ musicItem: MusicItem)->Void)?
    var countDownFinishedBlock: (()->Void)?
    
    override init() {
        super.init()
        
//        let url = URL(string: "https://randomwebsite.com/audio.mp3")!
//        SAPlayer.shared.startRemoteAudio(withRemoteUrl: url)
//        SAPlayer.shared.play()
        
        setupAVPlayer()
        initPlayerCountDownTimer()
    }
    

    func setupAVPlayer() {
        _ = SAPlayer.Updates.PlayingStatus.subscribe { [weak self] (url, playing) in
            guard let self = self else { return }
            //        guard url == self.selectedAudio.url || url == self.savedUrls[self.selectedAudio] else { return }
            
            
            debugPrint("*** setupAVPlayer() PlayingStatus.subscribe playing = \(playing)")
            switch playing {
            case .playing:
                self.currenPlayStatusEndBufferBlock?()
                
                if self.currenCountDownTime == "∞" {
                    
                } else {
//                    self.countDownTimer?.starTimer()
                    DSSencePlayerManager.default.startPlayerCountDownTimer()
                    
                }
                break
            case .paused:
                
                break
            case .buffering:
                self.currenPlayStatusBufferingBlock?()
               self.countDownTimer?.pauseTimer()
                break
            case .ended:
                debugPrint("*** self.currentSAPlayingStatus = \(self.currentSAPlayingStatus)")
                if self.currentSAPlayingStatus == .buffering {
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                        self.avPlayer.play()
                    }
                } else if self.currentSAPlayingStatus == .ended || self.currentSAPlayingStatus == .playing || self.currentSAPlayingStatus == .paused {
                    debugPrint("*** self.playStatus = \(self.playStatus)")
                    
                    switch self.playStatus {
                    case .single:
                        self.singlePlayAction()
                    case .circulation:
                        self.avPlayer.pause()
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                            self.nextMusic()
                        }
                    case .random:
                        self.avPlayer.pause()
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                            self.randomPlayAction()
                        }
                      
                        
                        break
                    }
                }
                
                
            }
            
            self.currentSAPlayingStatus = playing
            
            
            
        }
    }
    
    
}

extension DSSencePlayerManager {
    func startPlayerMusicItem(musicItem: MusicItem, musicList: [MusicItem]) {
        
        
        
        
        debugPrint("*** DSMeidaLocalCheckManager.checkLocalUrl musicItem = \(musicItem.name) -- url: \(musicItem.media_url)")
        
        let url = DSMeidaLocalCheckManager.checkLocalUrl(music: musicItem, completion: { [weak self] (musicUrl) in
            guard let `self` = self else {return}
            //            self.startPlayMusicWithUrl(url: musicUrl)
            }, progressBlock: { (progressValue) in
                
        }) {
            
        }
        
        
        if let musicUrl = url {
//            startPlayMusicWithUrl(url: musicUrl)
            debugPrint("*** startPlayMusicWithUrl(isRemoteUrl: false, musicUrl: url = \(musicUrl)")
            startPlayMusicWithUrl(isRemoteUrl: false, url: musicUrl)
        } else {
            if !isNetworkConnect {
                HUD.error("Network unavailable,please check.")
                return
            }
            if let url = URL.init(string: musicItem.media_url) {
                debugPrint("*** startPlayMusicWithUrl(isRemoteUrl: true, url: url = \(url)")
                startPlayMusicWithUrl(isRemoteUrl: true, url: url)
            }
        }
        
        currentMusicItem = musicItem
        senceMusicList = musicList
        
    }
    func startPlayMusicWithUrl(isRemoteUrl: Bool, url: URL) {
//        let playerItem = AVPlayerItem.init(url:url)
//        avPlayer.replaceCurrentItem(with: playerItem)
        
//        if currentSAPlayingStatus == .playing || currentSAPlayingStatus == .paused  || currentSAPlayingStatus == .paused {
//            debugPrint("*** startPlayMusicWithUrl - stopStreamingRemoteAudio")
//            avPlayer.stopStreamingRemoteAudio()
//        }
        debugPrint("*** startPlayMusicWithUrl - all stop stopStreamingRemoteAudio")
        avPlayer.stopStreamingRemoteAudio()
        if isRemoteUrl {
            avPlayer.startRemoteAudio(withRemoteUrl: url)
        } else {
            avPlayer.startSavedAudio(withSavedUrl: url)
        }
        avPlayer.play()
        isPause = false
//        NotificationCenter.default.addObserver(self, selector: #selector(didPlayerEnd(notification:)),
//        name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
//        object: nil)
    }

}

extension DSSencePlayerManager {
    
    func initPlayerCountDownTimer() {
        
        countDownTimer = ZJKillTimer(seconds: 0, callBack: {
            [weak self] (timeValue, text) in
            guard let `self` = self else {return}
            debugPrint("")
            self.countDownTimerActionBlock?(timeValue, text)
            if timeValue <= 0 {
                self.pausePlayerCountDownTimer()
                self.changePlayerStatus(isPause: true)
                self.countDownFinishedBlock?()
            }
        })
        
    }
    
    func resetStartCountDownTimer(countDownValue: Int, isFireNow: Bool) {
        countDownTimer?.updateCountDownValue(value: countDownValue)
        if isFireNow {
            countDownTimer?.myTimer.fireDate = Date.distantPast
            countDownTimer?.myTimer.fire()
        }
        
    }
    
    func resetCountDownTimerInfinity() {
        pausePlayerCountDownTimer()
        
    }
    
    func startPlayerCountDownTimer() {
         
        countDownTimer?.updateCountDownValue(value: ((countDownTimer?.secondsToEnd) ?? 0) + 1)
        countDownTimer?.myTimer.fireDate = Date.distantPast
        countDownTimer?.myTimer.fire()
    }
    
    func pausePlayerCountDownTimer() {
        countDownTimer?.myTimer.fireDate = Date.distantFuture
        
    }
    
    func clearCurrentMusicItem() {
        currentMusicItem = nil
    }
    
}

extension DSSencePlayerManager {
    func changePlayerStatus(isPause: Bool) {
        self.isPause = isPause
        
        if isPause {
            avPlayer.pause()
        } else {
            avPlayer.play()
        }
    }
    
    func nextMusic() {
        guard let musicItem = currentMusicItem else { return }
        let index = senceMusicList.firstIndex {
            $0.name == musicItem.name
        }
        
        var nextIndex: Int = Int((index ?? 0) + 1)
        
        if nextIndex >= senceMusicList.count {
            nextIndex = 0
        }
        
        debugPrint("*** nextMusicAction: inde = \(index ?? 000), nextIndex = \(nextIndex)")
        
        
        
        startPlayerMusicItem(musicItem: senceMusicList[nextIndex], musicList: senceMusicList)
        
        autoMusicChangeBlock?(musicItem)
    }
    
    func previousMusic() {
        guard let musicItem = currentMusicItem else { return }
        let index = senceMusicList.firstIndex {
            $0.name == musicItem.name
        }
        var nextIndex: Int = Int(index ?? 0 - 1)
        
        if nextIndex < 0 {
            nextIndex = senceMusicList.count - 1
        }
        
        startPlayerMusicItem(musicItem: senceMusicList[nextIndex], musicList: senceMusicList)
        
        autoMusicChangeBlock?(musicItem)
    }
    
    func randomPlayAction() {
        guard let musicItem = currentMusicItem else { return }
        let index = senceMusicList.firstIndex {
            $0.name == musicItem.name
        }
        
        var randomIndex: Int = Int(arc4random() % UInt32(senceMusicList.count))
        if randomIndex == index {
            randomIndex += 1
        }
        if randomIndex >= senceMusicList.count {
            randomIndex = 0
        }
        debugPrint("randomIndex = \(randomIndex)")
        startPlayerMusicItem(musicItem: senceMusicList[randomIndex], musicList: senceMusicList)
        autoMusicChangeBlock?(musicItem)
    }
    
    func singlePlayAction() {
        avPlayer.seekTo(seconds: 0)
        avPlayer.play()
//        avPlayer.seek(to: CMTime.zero) {[weak self] (success) in
//            guard let `self` = self else {return}
//            self.avPlayer.play()
//        }
        
    }
    
}

extension DSSencePlayerManager {
//    @objc func didPlayerEnd(notification: Notification) {
//        DispatchQueue.main.async {
//            if let item = notification.object as? AVPlayerItem {
//                debugPrint(item.className)
//                switch self.playStatus {
//                case .single:
//                    self.singlePlayAction()
//                case .circulation:
//                    self.nextMusic()
//                case .random:
//                    self.randomPlayAction()
//                default:
//                    self.singlePlayAction()
//                }
//
//                debugPrint("didPlayerEnd  item = \(item)")
//
//            }
//        }
//    }
    
    
    
    
}






