//
//  DSMPSoundsPreview.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/8.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import SVGKit
import SEExtensions
import Kingfisher
class DSMPSoundsPreview: UIView {

    let circularTimeSlider = CircularSlider()
    var triangleView: SVGKLayeredImageView!
    let topMusicItemBtn: UIButton = UIButton.init(type: .custom)
    let leftMusicItemBtn: UIButton = UIButton.init(type: .custom)
    let rightMusicItemBtn: UIButton = UIButton.init(type: .custom)
    let settingBtn: UIButton = UIButton.init(type: .custom)
    let timeLabel: UILabel = UILabel.init().font(14, .Quicksand_Regular)
    var settingBtnClickBlock:(()->Void)?
    var clickSoundsBtnsUpdateUIBlock: (()->Void)?
    var clickBtnCloseVolumeSettingBlock: (()->Void)?
    var musicItemBtns: [UIButton] = []
    
    var isStart: Bool = false
    var isFirstInit: Bool = true
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupCircularTimeSlider()
        setupTriangleView()
        setupMusicItemControl()
        setupControlStuffView()
        setupDefaultStatus(audioItems: DSMPPlayerManager.default.audioItemList)
        setupNotificationObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupNotificationObserver() {
        
    }
    

}

extension DSMPSoundsPreview {
    func updateCountDownTimer(secound: Int, isHandMoveToZero: Bool = true) {
        updateTimerLabel(secoundValue: Int(secound), isHandMoveToZero: isHandMoveToZero)
        circularTimeSlider.endPointValue = CGFloat(secound)
    }
    
    func setupDefaultStatus(audioItems:[ContentPlayerItem]) {
        
//        updateSoundsPreviewWith(itemList: audioItems)
        circularTimeSlider.isHidden = true
        settingBtn.isHidden = true
        timeLabel.isHidden = true
        updateCircularThumbStatus(isPlaying: false)
        
        
    }
}


extension DSMPSoundsPreview {
     
    
    func updateCircularThumbStatus(isPlaying: Bool) {
        if isPlaying {
            self.circularTimeSlider.endThumbImage = UIImage.named("mix_pause_ic")
        } else {
            self.circularTimeSlider.endThumbImage = UIImage.named("mix_ic_play")
        }
    }
}

extension DSMPSoundsPreview {
    func setupView() {
        backgroundColor = .clear
        
        musicItemBtns.append(topMusicItemBtn)
        musicItemBtns.append(rightMusicItemBtn)
        musicItemBtns.append(leftMusicItemBtn)
    }
    
    
    func changePreviewStatus(isChangeToStart_m: Bool) {
        
        self.updateCircularThumbStatus(isPlaying: isChangeToStart_m)
        DSMPPlayerManager.default.changePlayerStatus(isPause: !isChangeToStart_m)
        
        if isChangeToStart_m == true {
            DSMPPlayerManager.default.startPlayerCountDownTimer()
        } else {
            DSMPPlayerManager.default.pausePlayerCountDownTimer()
        }
        
        for index in 0...2 {
            let aitem = DSMPPlayerManager.default.audioItemList[index]
            let columeValue:Float = aitem.columeValue ?? 0
            self.updateTriangleViewColor(itemStatus: aitem.itemStatus, progress: columeValue, triangleIndex: index + 1)
        }
        
        self.clickSoundsBtnsUpdateUIBlock?()
        
        self.isStart = isChangeToStart_m
    }
    
    func setupCircularTimeSlider() {
        
        
        let width: CGFloat = 150//frame.width * 0.6
        let height = width
        let x = (self.frame.width - width) / 2
        let y = (self.frame.height - height) / 2
        circularTimeSlider.frame = CGRect.init(x: x, y: y, width: width, height: width)
        addSubview(circularTimeSlider)
        
        
        
        circularTimeSlider.singleClickThumbBlock = {
            [weak self] in
            guard let `self` = self else {return}
            debugPrint("*** single click thumb")
            //TODO: circular Thumb Point singleClickThumbBlock
//            self.updateSoundsPreviewWith()
            
            if DSMPPlayerManager.default.countDownTimer?.secondsToEnd ?? 0 <= 0 {
                return
            }
            
            self.changePreviewStatus(isChangeToStart_m: !self.isStart)
            self.clickBtnCloseVolumeSettingBlock?()
            
        }
        
        circularTimeSlider.addTarget(self, action: #selector(circularTimeSliderValueChange(slider:)), for: UIControl.Event.valueChanged)
        circularTimeSlider.addTarget(self, action: #selector(circularTimeSliderEditingDidEnd(slider:)), for: UIControl.Event.editingDidEnd)
        
        circularTimeSlider.backgroundColor = .clear
        circularTimeSlider.endThumbImage = UIImage.named("mix_ic_play")
        circularTimeSlider.backtrackLineWidth = 1
        circularTimeSlider.lineWidth = 2
        circularTimeSlider.trackFillColor = .white
        circularTimeSlider.trackColor = UIColor.white.withAlphaComponent(0.3)
        circularTimeSlider.numberOfRounds = 1
        circularTimeSlider.minimumValue = 0
        circularTimeSlider.maximumValue = 60 * 60
        circularTimeSlider.stopThumbAtMinMax = true
        circularTimeSlider.diskFillColor = .clear
        circularTimeSlider.diskColor = .clear
        circularTimeSlider.endPointValue = 0
        circularTimeSlider.backTrackDashLengths = [2,4]
        circularTimeSlider.frontTrackDashLengths = [1000000,0]
        
    }
    
    @objc func circularTimeSliderValueChange(slider: CircularSlider) {
        updateTimerLabel(secoundValue: Int(circularTimeSlider.endPointValue))
        
        
    }
    @objc func circularTimeSliderEditingDidEnd(slider: CircularSlider) {
        debugPrint("circularTimeSliderEditingDidEnd = \(Int(circularTimeSlider.endPointValue))")
        DSMPPlayerManager.default.countDownTimer?.updateCountDownValue(value: Int(circularTimeSlider.endPointValue))
        
//        DSMPPlayerManager.default.startPlayerCountDownTimer(countDownValue: Int(circularTimeSlider.endPointValue))
    }
    
    
    
    
    func updateTimerLabel(secoundValue: Int, isHandMoveToZero: Bool = true) {
        let timeString = secoundValue.secondsToTimeString(formatString: "%02lu:%02lu")
        if Int(circularTimeSlider.endPointValue) == 60 * 60 {
            timeLabel.text = "∞"
            DSMPPlayerManager.default.pausePlayerCountDownTimer()
        } else {
            timeLabel.text = timeString
        }
        if Int(circularTimeSlider.endPointValue) <= 0 {
            self.circularTimeSlider.endThumbImage = UIImage.named("mix_ic_play")
            DSMPPlayerManager.default.pausePlayerCountDownTimer()
            DSMPPlayerManager.default.changePlayerStatus(isPause: true)
            self.isStart = false
            for index in 0...2 {
                let aitem = DSMPPlayerManager.default.audioItemList[index]
                let columeValue:Float = aitem.columeValue ?? 0
                
                self.updateTriangleViewColor(itemStatus: aitem.itemStatus, progress: columeValue, triangleIndex: index + 1)

            }
            
            self.clickSoundsBtnsUpdateUIBlock?()
        }
        
         
        
    }
    
    func setupTriangleView() {
        
        let originalX = circularTimeSlider.frame.minX
        let originalY = circularTimeSlider.frame.minY - 10
        let width: CGFloat = 150//(circularTimeSlider.frame.width )
        let height: CGFloat = 130//circularTimeSlider.frame.height - 34
        
        triangleView = SVGKLayeredImageView.init(frame: CGRect.init(x: originalX, y: originalY, width: width, height: height))
        triangleView.isUserInteractionEnabled = false
        triangleView.backgroundColor = .clear
        addSubview(triangleView)
        
        if let svgImage = SVGKImage.init(contentsOfFile: Bundle.main.path(forResource: "triangle_ic.svg", ofType: nil)) {
            svgImage.size = CGSize.init(width: width, height: height)
            triangleView.image = svgImage
        }
        
        self.updateTriangleViewColor(itemStatus: nil, progress: 0.2, triangleIndex: 1)
        self.updateTriangleViewColor(itemStatus: nil, progress: 0.2, triangleIndex: 2)
        self.updateTriangleViewColor(itemStatus: nil, progress: 0.2, triangleIndex: 3)
        
//        updateTriangleViewColor(progress: 0.2, triangleIndex: 1)
//        updateTriangleViewColor(progress: 0.2, triangleIndex: 2)
//        updateTriangleViewColor(progress: 0.2, triangleIndex: 3)
        
        
    }
    
    func setupMusicItemControl() {
        let padding: CGFloat = 32
        let width: CGFloat = 20
        let topPoint = CGPoint.init(x: triangleView.frame.midX, y: triangleView.frame.minY - padding)
        let leftPoint = CGPoint.init(x: triangleView.frame.minX - padding, y: triangleView.frame.maxY)
        let rightPoint = CGPoint.init(x: triangleView.frame.maxX + padding, y: triangleView.frame.maxY)
        
        addSubview(topMusicItemBtn)
        addSubview(leftMusicItemBtn)
        addSubview(rightMusicItemBtn)
        
        topMusicItemBtn.backgroundColor = .clear
        leftMusicItemBtn.backgroundColor = .clear
        rightMusicItemBtn.backgroundColor = .clear
        
        topMusicItemBtn.addTarget(self, action: #selector(topMusicItemClickRepeat(sender:)), for: .touchDownRepeat)
        leftMusicItemBtn.addTarget(self, action: #selector(leftMusicItemClickRepeat(sender:)), for: .touchDownRepeat)
        rightMusicItemBtn.addTarget(self, action: #selector(rightMusicItemClickRepeat(sender:)), for: .touchDownRepeat)
        
        topMusicItemBtn.addTarget(self, action: #selector(topMusicItemClick(sender:)), for: .touchUpInside)
        leftMusicItemBtn.addTarget(self, action: #selector(leftMusicItemClick(sender:)), for: .touchUpInside)
        rightMusicItemBtn.addTarget(self, action: #selector(rightMusicItemClick(sender:)), for: .touchUpInside)
        
        
        topMusicItemBtn.frame = CGRect.init(x: 0, y: 0, width: width, height: width)
        topMusicItemBtn.center = topPoint
        leftMusicItemBtn.frame = CGRect.init(x: 0, y: 0, width: width, height: width)
        leftMusicItemBtn.center = leftPoint
        rightMusicItemBtn.frame = CGRect.init(x: 0, y: 0, width: width, height: width)
        rightMusicItemBtn.center = rightPoint
        
    }
    
    func setupControlStuffView() {
        let width: CGFloat = 24
        
        addSubview(settingBtn)
        settingBtn.backgroundColor = .clear
        settingBtn.setImage(UIImage.named("mix_adjust_ic"), for: .normal)
        settingBtn.addTarget(self, action: #selector(settingBtnClick(sender:)), for: .touchUpInside)
        settingBtn.frame = CGRect.init(x: 0, y: 0, width: width, height: width)
        settingBtn.center = CGPoint.init(x: triangleView.frame.midX, y: triangleView.frame.minY + triangleView.frame.height * 0.68)
        
        addSubview(timeLabel)
        timeLabel.frame = CGRect.init(x: 0, y: 0, width: 120, height: 34)
        timeLabel.font = UIFont.custom(14, name: .MontserratMedium)
        timeLabel.textColor = .white
        timeLabel.text = "00:00"
        timeLabel.textAlignment = .center
        timeLabel.center = CGPoint.init(x: triangleView.frame.midX, y: triangleView.frame.maxY + 40)
        
    }
    
}

extension DSMPSoundsPreview {
    func updateSoundsPreviewWith(itemList: [ContentPlayerItem] = DSMPPlayerManager.default.audioItemList) {
        
        var isHasAudioItem: Bool = false
        var isHasOpenPlaying: Bool = false
        debugPrint("*** updateSoundsPreviewWith 1")
        
        itemList.forEach {
            let btn = musicItemBtns[$0.index]
            if $0.audioItem != nil {
                btn.isHidden = false
                isHasAudioItem = true
                if $0.itemStatus == .playing {
                    isHasOpenPlaying = true
                }
                
            } else {
                btn.isHidden = true
            }
            
            if let IconImage = $0.iconImage {
                btn.setImage(IconImage, for: .normal)
                
                if $0.itemStatus == .playing {
                    btn.alpha = 1
                    $0.avPlayer.play()
                } else if $0.itemStatus == .pause {
                    btn.alpha = 0.3
                    $0.avPlayer.pause()
                }
                
            }
            else {
                if let buildinName = DSBuildinManager.default.buildinResourceName(remoteName: $0.audioItem?.icon_url) {
                    btn.setImage(UIImage.named(buildinName), for: .normal)
                    if $0.itemStatus == .playing {
                        btn.alpha = 1
                        $0.avPlayer.play()
                    } else if $0.itemStatus == .pause {
                        btn.alpha = 0.3
                        $0.avPlayer.pause()
                    }
                } else {
                    if let url = URL.init(string: $0.audioItem?.icon_url ?? "") {
                        btn.kf.setImage(with: url, for: .normal, placeholder: nil, options: nil, progressBlock: nil) { (result) in
                            switch result {
                            case let .success(image) :
                                break
                            default :
                                break
                            }
                            
                        }
                    }
                    
                    
                    if $0.itemStatus == .playing {
                        btn.alpha = 1
                        $0.avPlayer.play()
                    } else if $0.itemStatus == .pause {
                        btn.alpha = 0.3
                        $0.avPlayer.pause()
                    }
                    
                }
            }
            
            
            debugPrint("*** updateSoundsPreviewWith updateTriangleViewColor \($0.index)")
            self.updateTriangleViewColor(itemStatus: $0.itemStatus, progress: $0.columeValue ?? 0, triangleIndex: $0.index + 1)
            
            
            
        }
         
        if isHasAudioItem == true {
            circularTimeSlider.isHidden = false
            settingBtn.isHidden = false
            timeLabel.isHidden = false
//            DSMPPlayerManager.default.startPlayerCountDownTimer(countDownValue: Int(circularTimeSlider.endPointValue))
            updateCircularThumbStatus(isPlaying: true)
//            isStart = true
//            debugPrint("isStart == true -- 328")
        } else {
            circularTimeSlider.isHidden = true
            settingBtn.isHidden = true
            timeLabel.isHidden = true
//            isStart = false
//            debugPrint("isStart == false  -- 334")
            updateCircularThumbStatus(isPlaying: false)
        }
         
        if isHasOpenPlaying {
            isStart = true
            updateCircularThumbStatus(isPlaying: true)
            if isFirstInit {
                isFirstInit = false
                setupDefaultCountDownTimerValue()
                
            } else {
                    
//                DSMPPlayerManager.default.startPlayerCountDownTimer()
            }
        } else {
            isStart = false
            updateCircularThumbStatus(isPlaying: false)
            DSMPPlayerManager.default.pausePlayerCountDownTimer()
        }
        
        
        
        clickSoundsBtnsUpdateUIBlock?()
        
        

        
    }
    
    func setupDefaultCountDownTimerValue() {
        let defaultCountDownValue: CGFloat = 30 * 60 + 2
        circularTimeSlider.endPointValue = defaultCountDownValue
        DSMPPlayerManager.default.resetStartCountDownTimer(countDownValue: Int(defaultCountDownValue))
    }
    
}


extension DSMPSoundsPreview {
    // progress 0 - 1
    func updateTriangleViewColor(itemStatus: PlayerItemStatus?, progress: Float, triangleIndex: Int) {
        let max: CGFloat = 0.8
        let min: CGFloat = 0.2
        var progress_m = progress
        if let itemStatus_m = itemStatus, itemStatus_m == .pause {
            progress_m = 0
        }
        
        let btn = musicItemBtns[triangleIndex - 1]
        if progress_m == 0 {
            btn.alpha = 0.3
        } else {
            btn.alpha = 1
        }
        
        
        let maxG = min + (max - min) * CGFloat(progress_m)
        let color = UIColor.white.withAlphaComponent(maxG)
        
        let layer = triangleView.image.layer(withIdentifier: "\(triangleIndex)")
        if let shapeLayer = layer as? CAShapeLayer {
            shapeLayer.fillColor = color.cgColor
            self.layoutIfNeeded()
        } else {
            debugPrint("asdf")
        }
    }
    
    func clickMusicBtnAction(index: Int) {
        
        MTEvent.default.tga_eventConsoleClick(index: index)
        debugPrint("*** clickMusicBtnAction 1")
        let item = DSMPPlayerManager.default.audioItemList.first {
            $0.index == index
        }
        if let item_m = item, let _ = item_m.audioItem {
            
            switch item_m.itemStatus {
            case .playing:
               
                self.isStart = false
                debugPrint("isStart == false -- 379")
                DSMPPlayerManager.default.pauseAudioTrack(index: index)
            case .pause:
                self.isStart = true
                debugPrint("isStart == true -- 383")
                DSMPPlayerManager.default.openAudioTrack(index: index)
            default:
                break
            }
        }
        debugPrint("*** clickMusicBtnAction 2")
        updateSoundsPreviewWith()
        debugPrint("*** clickMusicBtnAction 3")
        self.clickBtnCloseVolumeSettingBlock?()
    }
    
    func doubleClickMusicBtnAction(index: Int) {
        
        MTEvent.default.tga_eventConsoleDelete(index: index)
        
        
        let item = DSMPPlayerManager.default.audioItemList.first {
            $0.index == index
        }
        if let item_m = item {
            isStart = false
            debugPrint("isStart == false -- 398")
            DSMPPlayerManager.default.removeAudioItem(contentItem: item_m)
        }
        
        updateSoundsPreviewWith()
        self.clickBtnCloseVolumeSettingBlock?()
    }
    
    
    @objc func topMusicItemClick(sender: UIButton) {
        clickMusicBtnAction(index: 0)
    }
    
    @objc func leftMusicItemClick(sender: UIButton) {
        clickMusicBtnAction(index: 2)
    }
    
    @objc func rightMusicItemClick(sender: UIButton) {
        clickMusicBtnAction(index: 1)
        
    }
    
    @objc func topMusicItemClickRepeat(sender: UIButton) {
//        clickMusicBtnAction(index: 0)
        doubleClickMusicBtnAction(index: 0)
    }
    
    @objc func leftMusicItemClickRepeat(sender: UIButton) {
//        clickMusicBtnAction(index: 2)
        doubleClickMusicBtnAction(index: 2)
    }
    
    @objc func rightMusicItemClickRepeat(sender: UIButton) {
//        clickMusicBtnAction(index: 1)
        doubleClickMusicBtnAction(index: 1)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    @objc func settingBtnClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        settingBtnClickBlock?()
    }
    
}




