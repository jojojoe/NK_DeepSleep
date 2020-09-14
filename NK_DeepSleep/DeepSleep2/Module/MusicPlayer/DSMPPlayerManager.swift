//
//  DSMPPlayerManager.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/7.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import HDSwiftCommonTools

struct AudioSoundsBoundleList: Codable {
    let title: String
    let icon: String
    let audioItems: [AudioItem]
}

struct AudioItem: Codable {
    let name: String
    let url: String
    let icon: String
    let vip: Bool
    let remoteUrl: String?
    let localUrl: String?
}

enum PlayerItemStatus {
    case none
    case pause
    case playing
//    case downloadProgress(value: Float)
}

class ContentPlayerItem {
    var index: Int = 0
    var avPlayer: AVPlayer
    var audioItem: MusicItem?
    var columeValue: Float?
    var itemStatus: PlayerItemStatus = .none
    var isDownloaingProgress: Float = 0
    var iconImage: UIImage?
    
    init(index: Int, avPlayer: AVPlayer, audioItem: MusicItem?, columeValue: Float?, itemStatus: PlayerItemStatus = .none) {
        self.index = index
        self.avPlayer = avPlayer
        self.audioItem = audioItem
        self.columeValue = columeValue
        self.itemStatus = itemStatus
    }
    
}

class DSMPPlayerManager: NSObject {
    static let `default` = DSMPPlayerManager.init(audioTrackCount: 3)
    var audioTrackCount: Int
    let defaultVolumeValue: Float = 0.5
 
    var countDownTimer: ZJKillTimer?
    
    var audioItemList: [ContentPlayerItem] = []
    
    var currentInsertIndex: Int? = 0
//    var duration: Double = Double.infinity
    var isPause: Bool = false
    
    var countDownTimerActionBlock: ((_ secoudValue: Int, _ timeString: String)->Void)?
    
    var downloadProgressStatusUpdateUIBlock: (()->Void)?
    
    var isCountDownTimerRunging: Bool = false
    
    
    init(audioTrackCount: Int) {
        self.audioTrackCount = audioTrackCount
        super.init()
        initAVPlayer()
        initPlayerCountDownTimer()
        
        
    }
    
    deinit {
        
        
    }
    
    func initAVPlayer() {
        for index in 0 ..< audioTrackCount {
            let avPlayer = AVPlayer.init(playerItem: nil)
            
            avPlayer.volume = defaultVolumeValue
            
            let item: ContentPlayerItem = ContentPlayerItem(index: index, avPlayer: avPlayer, audioItem: nil, columeValue: nil)
            audioItemList.append(item)
            
        }
    }
}

extension DSMPPlayerManager {
    
    func setupDefaultCountDowTimerValue() {
        
    }
    
    func initPlayerCountDownTimer() {
        
        countDownTimer = ZJKillTimer(seconds: 30 * 60, callBack: {
            [weak self] (timeValue, text) in
            guard let `self` = self else {return}
            
            debugPrint("")
            if timeValue <= 0 {
                self.pausePlayerCountDownTimer()
                self.changePlayerStatus(isPause: true)
            }
            
            self.countDownTimerActionBlock?(timeValue, text)
            
        })
        
        
         
    }
    
    func resetStartCountDownTimer(countDownValue: Int) {
        countDownTimer?.updateCountDownValue(value: countDownValue)
        countDownTimer?.myTimer.fireDate = Date.distantPast
        countDownTimer?.myTimer.fire()
        isCountDownTimerRunging = true
    }
    
    func startPlayerCountDownTimer() {
        countDownTimer?.updateCountDownValue(value: ((countDownTimer?.secondsToEnd) ?? 0) + 2)
        countDownTimer?.myTimer.fireDate = Date.distantPast
        countDownTimer?.myTimer.fire()
        isCountDownTimerRunging = true
    }
    
    func pausePlayerCountDownTimer() {
        countDownTimer?.myTimer.fireDate = Date.distantFuture
        isCountDownTimerRunging = false
    }
    
}


    
extension DSMPPlayerManager {
    
    //AudioItem
    func addAudioItem(item: MusicItem, iconImage: UIImage?) {
        
        // 判断是否有网 且内置，且下载
        var hasNetWork: Bool = true
        let url = DSMeidaLocalCheckManager.checkLocalUrl(music: item, completion: { [weak self] (musicUrl) in
            guard let `self` = self else {return}
            
            if let musicUrl_m = musicUrl {
                // 内置
            } else {
                //无内置
                if !isNetworkConnect {
                    hasNetWork = false
                    HUD.error("Network unavailable,please check.")
                    return
                }
            }
            }, progressBlock: { (progressValue) in
                
        }) {
            
        }
        
        
         
        
        if let musicUrl = url {
            // 已经下载
        } else {
            // 未下载
            if !isNetworkConnect {
                hasNetWork = false
                HUD.error("Network unavailable,please check.")
                return
            }
        }
        
        
        
        //
        
        
        if let currentInsertIndex_m = currentInsertIndex {
            
            let theItem = audioItemList.first {
                $0.audioItem == nil
            }
            if let theItem_t = theItem {
                currentInsertIndex = theItem_t.index
            } else {
                if currentInsertIndex == audioItemList.count - 1 {
                    currentInsertIndex = 0
                } else {
                    self.currentInsertIndex = currentInsertIndex_m + 1
                }
                
            }
            
        } else {
            currentInsertIndex = 0
        }
        let contentItem = audioItemList[currentInsertIndex ?? 0]
        if contentItem.audioItem != nil {
            if contentItem.isDownloaingProgress != 0 {
                
            }
            contentItem.isDownloaingProgress = 0
            debugPrint("*** DSDownloadHelper.default.cancelDownload")
            if let lastMediaUrl = contentItem.audioItem?.media_url {
                DSDownloadHelper.default.cancelDownload(lastMediaUrl)
            }
            contentItem.avPlayer.replaceCurrentItem(with: nil)
        }
        contentItem.audioItem = item
        contentItem.columeValue = defaultVolumeValue
        contentItem.iconImage = iconImage
        contentItem.itemStatus = .playing
        
        
        
        if countDownTimer?.secondsToEnd ?? 0 <= 0 {
            contentItem.itemStatus = .pause
        } else {
            playMusicActionWith(playItem: contentItem)
            if isPause {
                changePlayerStatus(isPause: false)
            }
            
            //TODO: 如果之前倒计时停止，就重新打开
            
            if isCountDownTimerRunging == false {
                startPlayerCountDownTimer()
            }
        }
        
        
         
    }
    
    func beginPlayItem(playItem: ContentPlayerItem, url: URL) {
        
        
        let playerItem = AVPlayerItem.init(url:url)
        let avPlayer = playItem.avPlayer
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayer.volume = playItem.columeValue ?? 0
        
        if !self.isPause {
            if playItem.itemStatus == .pause {
                avPlayer.pause()
            } else {
                avPlayer.play()
            }
            
        } else {
            avPlayer.pause()
        }
        debugPrint("playMusicActionWith - 4")
        
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayerEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }
    
    func playMusicActionWith(playItem: ContentPlayerItem) {
        guard let musicItem = playItem.audioItem else { return }
        
        debugPrint("playMusicActionWith - 1")
        if let buildinName = DSBuildinManager.default.buildinResourceName(remoteName: musicItem.media_url)  {
            // local music
            if let path = Bundle.main.path(forResource: buildinName, ofType: nil) {
                let mediaURL = URL.init(fileURLWithPath: path)
                beginPlayItem(playItem: playItem, url: mediaURL)
            }
            
            return
        } else {
            
        }
        
        debugPrint("playMusicActionWith - 2")
        
        let url = DSMeidaLocalCheckManager.checkLocalUrl(music: musicItem, completion: { [weak self] (musicUrl) in
            guard let `self` = self else {return}
            
            if let musicUrl_m = musicUrl {
                debugPrint("playMusicActionWith - 3")
                self.beginPlayItem(playItem: playItem, url: musicUrl_m)
            } else {
                if !isNetworkConnect {
                    HUD.error("Network unavailable,please check.")
                    return
                }
            }
            }, progressBlock: { [weak self] (progressValue) in
             guard let `self` = self else {return}

            playItem.isDownloaingProgress = Float(progressValue)
            debugPrint("*** downloadProgressStatusUpdateUIBlock - 1 \(Float(progressValue))")
            self.downloadProgressStatusUpdateUIBlock?()
        }) {
            playItem.isDownloaingProgress = 0.05
        }
        
//        let url = DSMeidaLocalCheckManager.checkLocalUrl(music: musicItem, completion: { [weak self] (musicUrl) in
//            guard let `self` = self else {return}
//
//            if let musicUrl_m = musicUrl {
//                debugPrint("playMusicActionWith - 3")
//                self.beginPlayItem(playItem: playItem, url: musicUrl_m)
//            } else {
//                if !isNetworkConnect {
//                    HUD.error("Network unavailable,please check.")
//                    return
//                }
//            }
//        }) {[weak self] (progressValue) in
//             guard let `self` = self else {return}
//
//            playItem.isDownloaingProgress = Float(progressValue)
//            debugPrint("*** downloadProgressStatusUpdateUIBlock - 1 \(Float(progressValue))")
//            self.downloadProgressStatusUpdateUIBlock?()
//        }
        
        if let musicUrl = url {
            beginPlayItem(playItem: playItem, url: musicUrl)
        }
        
    }
    
    func removeAudioItem(contentItem: ContentPlayerItem) {
 
        currentInsertIndex = contentItem.index
        contentItem.avPlayer.replaceCurrentItem(with: nil)
        contentItem.avPlayer.pause()
        contentItem.audioItem = nil
        contentItem.columeValue = nil
        contentItem.itemStatus = .none
        
    }
    
    func pauseAudioTrack(index: Int) {
        let contentItem_T = audioItemList.first {
            $0.index == index
        }
        if let contentItem = contentItem_T {
            contentItem.avPlayer.pause()
            contentItem.itemStatus = .pause
//            contentItem.columeValue = 0
        }
    }

    func openAudioTrack(index: Int) {
         
        if countDownTimer?.secondsToEnd ?? 0 <= 0 {
            return
        } else {
            //TODO: 如果之前倒计时停止，就重新打开
            if isCountDownTimerRunging == false {
                startPlayerCountDownTimer()
            }
        }
        
        let contentItem_T = audioItemList.first {
            $0.index == index
        }
        if let contentItem = contentItem_T {
            contentItem.avPlayer.play()
            contentItem.itemStatus = .playing
            if contentItem.columeValue == 0 {
                contentItem.avPlayer.volume = defaultVolumeValue
                contentItem.columeValue = defaultVolumeValue
                
            }
//            contentItem.columeValue = defaultVolumeValue
        }
    }
    
    func changeVolume(value: Float, index: Int, reOpenCompletion:((_ isChangeStatus: Bool)->Void)) {
        let contentItem_T = audioItemList.first {
            $0.index == index
        }
        if let contentItem = contentItem_T {
            
            var isPauseing: Bool = false
            switch contentItem.itemStatus {
            case .pause:
                isPauseing = true
            default:
                isPauseing = false
            }
            if value > 0 && isPauseing {
                openAudioTrack(index: index)
                reOpenCompletion(true)
            } else {
                reOpenCompletion(false)
            }
            contentItem.columeValue = value
            contentItem.avPlayer.volume = value
        }
    }
    
    func changePlayerStatus(isPause: Bool) {
        
        
        
        self.isPause = isPause
        
        if isPause {
            audioItemList.forEach {
                $0.avPlayer.pause()
                $0.itemStatus = .pause
//                $0.columeValue = 0
            }
        } else {
            audioItemList.forEach {
                $0.avPlayer.play()
                $0.itemStatus = .playing
//                $0.columeValue = defaultVolumeValue
            }
        }
    }
    
    
    @objc func didPlayerEnd(notification: Notification) {
        DispatchQueue.main.async {
            if let item = notification.object as? AVPlayerItem {
                
                let contentItem_T = self.audioItemList.first {
                    $0.avPlayer.currentItem == item
                }
                debugPrint("didPlayerEnd  item = \(item)")
                if let contentItem = contentItem_T {
                    debugPrint("didPlayerEnd  avPlayer_m = \(String(describing: contentItem))")
                    contentItem.avPlayer.seek(to: CMTime.zero) { (success) in
                        contentItem.avPlayer.play()
                        debugPrint("didPlayerEnd avPlayer.seek")
                    }
                }
            }
        }
    }
}


extension DSMPPlayerManager {
    func randomAudioItems(audoItemList: [MusicItem], completion:(()->Void)) {
        
        var audoItemIndexList_m: [Int] = []
        for index in 0..<audoItemList.count {
            audoItemIndexList_m.append(index)
        }
        
        func randomItem() -> Int {
            let index = audoItemIndexList_m.randomElement() ?? 0
            audoItemIndexList_m.removeAll(index)
            
            return index
            
        }
         
        isPause = false
        
        for index in 0...2 {
            let random = randomItem()
            let randomitem = audoItemList.safeObject(at: random)
            
            let item = audioItemList[index]
             
            if item.audioItem != nil {
                if item.isDownloaingProgress != 0 {
                    
                }
                item.isDownloaingProgress = 0
                if let lastMediaUrl = item.audioItem?.media_url {
                    DSDownloadHelper.default.cancelDownload(lastMediaUrl)
                }
                debugPrint("*** DSDownloadHelper.default.cancelDownload")
                item.avPlayer.replaceCurrentItem(with: nil)
                
            }
            item.audioItem = randomitem
            item.columeValue = defaultVolumeValue
            item.itemStatus = .playing
            item.iconImage = nil
            playMusicActionWith(playItem: item)
             
            
        }
        if isCountDownTimerRunging == false {
            startPlayerCountDownTimer()
        }
        completion()
        
    }
    
    func playFavoriteAudioItems(favoriteItemList: [DSFavoriteModel.FavoriteSound], completion:(()->Void)) {
        
        var favoriteMusicItemList: [MusicItem] = []
        var volumeValueList: [Float] = []
        for item in favoriteItemList {
            
            let musicItem: MusicItem = MusicItem.init(name: item.name, duration: 0, media_url: item.remoteUrl, icon_url: item.icon, is_free: 1)
            
            favoriteMusicItemList.append(musicItem)
            volumeValueList.append(Float(item.volume))
        }
        
        
        for index in 0...2 {
            pauseAudioTrack(index: index)
            let item = audioItemList[index]
            item.audioItem = favoriteMusicItemList.safeObject(at: index)
            item.columeValue = volumeValueList.safeObject(at: index)
            item.itemStatus = .playing
            item.iconImage = nil
            playMusicActionWith(playItem: item)
             
            
        }
        
        if isCountDownTimerRunging == false {
            startPlayerCountDownTimer()
        }
        completion()
    }
    
    func addFavoriteAction(favoriteName: String, completion:(()->Void)) {
        
        var soundsList: [DSFavoriteModel.FavoriteSound] = []
        
        for index in 0..<audioItemList.count {
            let item = audioItemList[index]
            if let audioItem = item.audioItem {
                let sound = DSFavoriteModel.FavoriteSound.init(faovriteId: Int64(Date().timeIntervalSince1970.int), name: audioItem.name ?? "1", icon: audioItem.icon_url ?? "", remoteUrl: audioItem.media_url ?? "", localUrl: audioItem.media_url ?? "", volume: Double(item.columeValue ?? defaultVolumeValue))
                soundsList.append(sound)
            }
        }
        
        let favoriteItem = DSFavoriteModel.init(id: Int64(Date().timeIntervalSince1970.int), name: favoriteName, updateTime: Int64(Date().timeIntervalSince1970.int), sounds: soundsList)
        
        DSDBHelper.default.addNewFavorite(favorite: favoriteItem)
        
        completion()
    }
    
    func addLastHistorySoundsAction(completion:(()->Void)) {
        
        var soundsList: [DSFavoriteModel.FavoriteSound] = []
        
        for index in 0..<audioItemList.count {
            let item = audioItemList[index]
            if let audioItem = item.audioItem {
                let sound = DSFavoriteModel.FavoriteSound.init(faovriteId: Int64(DSDBHelper.default.historyId), name: audioItem.name ?? "1", icon: audioItem.icon_url ?? "", remoteUrl: audioItem.media_url ?? "", localUrl: audioItem.media_url ?? "", volume: Double(item.columeValue ?? defaultVolumeValue))
                soundsList.append(sound)
            }
        }
        
        let favoriteItem = DSFavoriteModel.init(id: Int64(DSDBHelper.default.historyId), name: "\(DSDBHelper.default.historyId)", updateTime: Int64(Date().timeIntervalSince1970.int), sounds: soundsList)
        
        DSDBHelper.default.recordLastHistorySounds(favorite: favoriteItem)
        
        completion()
    }
    
    
    
    
}










