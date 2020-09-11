//
//  DSMainVC.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/7.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import SEExtensions
import SnapKit
import Defaults
import DeviceKit
import AVFoundation


class DSMainVC: UIViewController {

    @IBOutlet weak var bottomBlurBgView: UIView!
    
    @IBOutlet var bottomActionBtns: [UIButton]!
    var contentViews: [UIView] = []
    var meditationVC: DSSenceVC = DSSenceVC()
    var soundsVC: DSSoundsVC = DSSoundsVC()
    var accountVC: DSAccountVC = DSAccountVC()
    var meditationView: UIView?
    var soundsView: UIView?
    var accountView: UIView?
    var currentVC: UIViewController?
    
    var viewWillAppearOnce: Once = Once()
    var viewDidAppearOnce: Once = Once()
    
    var splashList = ["8_helper_ic_1", "8_helper_ic_2", "8_helper_ic_3", "8_helper_ic_4", "8_helper_ic_5"]
    @IBOutlet weak var splashBgView: UIControl!
    @IBAction func splashBgViewClick(_ sender: UIControl) {
        currentSplashIndex += 1
        if currentSplashIndex == splashList.count {
            splashBgView.isHidden = true
            Defaults[.isHasShowSplash] = true
        } else {
            splashContentImageView.image = UIImage.named(splashList[currentSplashIndex])
        }
    }
    @IBOutlet weak var splashContentImageView: UIImageView!
    var currentSplashIndex: Int = 0
    
    @IBOutlet weak var meditationBtn: UIButton!
    @IBAction func meditationBtnClick(_ sender: UIButton) {
        guard let meditationView = meditationView else { return }
        showContent(vc: meditationVC, contentView: meditationView, actionBtn: meditationBtn)
        
        soundsVC.hiddenVolumeSettingView()
    }
    @IBOutlet weak var soundBtn: UIButton!
    @IBAction func soundBtnClick(_ sender: UIButton) {
        guard let soundsView = soundsView else { return }
        showSplash()
        showContent(vc: soundsVC, contentView: soundsView, actionBtn: soundBtn)
    }
    @IBOutlet weak var accountBtn: UIButton!
    @IBAction func accountBtnClick(_ sender: UIButton) {
        guard let accountView = accountView else { return }
        showContent(vc: accountVC, contentView: accountView, actionBtn: accountBtn)
        
        soundsVC.hiddenVolumeSettingView()
    }
    
    @IBOutlet weak var canvasBgView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        loadData()
        setupCanvasView()
        showDefaultStatus()
        setupFont()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch  {
            print(error.localizedDescription)
        }
        
        
    }
 
}

extension DSMainVC {
    func setupFont() {
        
    }
    
    
}


extension DSMainVC {
    
    func showSplash() {
        
        if let isHasShowSplash = Defaults[.isHasShowSplash], isHasShowSplash == true {
            splashBgView.isHidden = true
        } else {
            //TODO: 展示Splash
            splashBgView.isHidden = false
            

            if Device.allDevicesWithSensorHousing.contains(Device.current) || Device.allSimulatorDevicesWithSensorHousing.contains(Device.current) {
                splashList = splashList.map {
                    let string = $0.replacingOccurrences(of: "8", with: "x")
                    debugPrint("splash = \(string)")
                    return string
                }
            }
            
            splashContentImageView.image = UIImage.named(splashList[currentSplashIndex])
            
        }
    }
    
    
    func loadData() {

        var isShouldRequest: Bool = true
        if let lastDate = Defaults[.recentlyRequestResourceDataDate] {
            let hours = Date().hoursSince(lastDate)
            if hours < 24 {
                isShouldRequest = false
            }
        }
        
        if UIApplication.shared.inferredEnvironment == .debug  {
            isShouldRequest = true
        }
        
        if isShouldRequest {
            Defaults[.recentlyRequestResourceDataDate] = Date()
            Request.default.getDeepSleepResource(completion: { (resource) in
                NotificationCenter.default.post(name: Notification.Name("getDeepSleepResource"), object: nil)
            }) { (error) in
                HUD.error(error)
            }
        }
    }
    
    func setupCanvasView() {
        addMeditationVC()
        addSoundsVC()
        addAccountVC()

        let blur = APCustomBlurView.init(withRadius: 2)
        bottomBlurBgView.addSubview(blur)
        blur.snp.makeConstraints {
            $0.left.right.bottom.top.equalToSuperview()
        }
        
    }
    
    func addMeditationVC() {
        
        addChild(meditationVC)
        meditationVC.montherVC = self
        meditationVC.didMove(toParent: self)
        meditationView = meditationVC.view
        canvasBgView.addSubview(meditationVC.view)
        meditationVC.view.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.top.left.right.bottom.equalToSuperview()
        }
        contentViews.append(meditationVC.view)
    }
    
    func addSoundsVC() {
        
        addChild(soundsVC)
        soundsVC.montherVC = self
        soundsVC.didMove(toParent: self)
        soundsView = soundsVC.view
        canvasBgView.addSubview(soundsVC.view)
        soundsVC.view.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.top.left.right.bottom.equalToSuperview()
        }
        contentViews.append(soundsVC.view)
    }
    
    func addAccountVC() {
        
        addChild(accountVC)
        accountVC.montherVC = self
        accountVC.didMove(toParent: self)
        accountView = accountVC.view
        canvasBgView.addSubview(accountVC.view)
        accountVC.view.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.top.left.right.bottom.equalToSuperview()
        }
        contentViews.append(accountVC.view)
        
    }
    
    func showContent(vc: UIViewController, contentView: UIView, actionBtn: UIButton) {
        currentVC = vc
        
        var lastVC: UIViewController?
        for view in contentViews {
            if view.isHidden == false, view != contentView {
                if view == meditationView {
                    lastVC = meditationVC
                } else if view == soundsView {
                    lastVC = soundsVC
                } else if view == accountView {
                    lastVC = accountVC
                }
            }
            view.isHidden = !(view == contentView)
        }
        for btn in bottomActionBtns {
            btn.isSelected = (btn == actionBtn)
        }
        
        if vc == meditationVC {
            MTEvent.default.tga_eventMeditationShow()
        } else if vc == soundsVC {
            MTEvent.default.tga_eventSoundShow()
        } else if vc == accountVC {
            MTEvent.default.tga_eventAccountShow()
        }
        
        if let lastV = lastVC {
            lastV.viewDidDisappear(true)
        }
        vc.viewDidAppear(true)
        
    }
    
    func showDefaultStatus() {
        
        guard let meditationView = meditationView else { return }
//        showContent(vc: soundsVC, contentView: soundsView, actionBtn: soundBtn)
        
        showContent(vc: meditationVC, contentView: meditationView, actionBtn: meditationBtn)
    }
    
}


