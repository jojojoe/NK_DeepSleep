//
//  DSAccountVC.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/7.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit


class DSAccountVC: UIViewController {
    
    
    let appId: String = "1524453296"

    let FeedbackEmail = "xiangmu4732@163.com"
    let TermsofuseURLStr = "https://ds.funnyplay.me/DS/DeepSleep_Terms_of_use.html"
    let PrivacyPolicyURLStr = "https://ds.funnyplay.me/DS/DeepSleep_Privacy_Policy.html"

    
    
    var montherVC: UIViewController?
    @IBOutlet weak var topTitleLabe: UILabel!
    @IBOutlet weak var subscriptionBtn: UIControl!
    @IBOutlet weak var subscriptionTitleLabel: UILabel!
    @IBOutlet weak var subDesLabel: UILabel!
    @IBAction func subscriptionBtnClick(_ sender: UIControl) {
        proAction()
    }
    
    @IBOutlet weak var settingControlBgView: UIView!
    @IBOutlet weak var settingControlBgViewTopToTop: NSLayoutConstraint!
    
    @IBAction func feedbackBtnClick(_ sender: UIControl) {
        //,,
        MTEvent.default.tga_eventAccountItemClick(itemName: "contact")
        feedbackAction()
    }
    @IBAction func rateusBtnClick(_ sender: UIControl) {
        MTEvent.default.tga_eventAccountItemClick(itemName: "rating")
        rateusAction()
    }
    @IBAction func restoreBtnClick(_ sender: UIControl) {
        MTEvent.default.tga_eventAccountItemClick(itemName: "restore")
        restoreAction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTitleLabe.font(30, UIFont.FontNames.Quicksand_Bold)
        subscriptionTitleLabel.font(15, UIFont.FontNames.Quicksand_Bold)
        subDesLabel.font(12, UIFont.FontNames.Quicksand_Bold)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        updateUIStatus()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUIStatus()
    }

    func updateUIStatus() {
        if PurchaseManager.default.inSubscription {
            settingControlBgViewTopToTop.constant = 0
            subscriptionBtn.isHidden = true
        } else {
            settingControlBgViewTopToTop.constant = 90
            subscriptionBtn.isHidden = false
        }
    }

}

extension DSAccountVC {
     func feedbackAction() {
//         MTEvent.default.tga_eventSettingItemClick(item: MTEventParaManager.SettingItem.feedback.rawValue)
         feedback()
     }
     
//     func privacyPolicyAction() {
//         debugPrint("need show term of use")
//         MTEvent.default.tga_eventSettingItemClick(item: MTEventParaManager.SettingItem.privacy.rawValue)
//
//         guard let url = URL(string: PrivacyPolicyURLStr) else { return }
//         UIApplication.shared.open(url, options: [:], completionHandler: nil)
//     }
//
//     func termsofuseAction() {
//         debugPrint("need show term of use")
//         MTEvent.default.tga_eventSettingItemClick(item: MTEventParaManager.SettingItem.terms.rawValue)
//         guard let url = URL(string: TermsofuseURLStr) else { return }
//         UIApplication.shared.open(url, options: [:], completionHandler: nil)
//     }
//
     
     func proAction() {
        
        
         
         AppDelegate.showSubscriptionVC(source: "topbar")
     }
    
    
    func rateusAction() {
        
        let productUrlStr: String = "https://itunes.apple.com/app/id\(appId)?action=write-review";
        if let rateLink = URL.init(string: productUrlStr) {
            UIApplication.shared.openURL(url: rateLink)
        }
         
        
    }
    
    func restoreAction() {
        HUD.show()
        PurchaseManager.default.restore {
            HUD.hide()
        }
    }
    
    
    
    
    
    
}


extension DSAccountVC: MFMailComposeViewControllerDelegate {
    func feedback() {
        //首先要判断设备具不具备发送邮件功能
        if MFMailComposeViewController.canSendMail(){
            //获取系统版本号
            let systemVersion = UIDevice.current.systemVersion
            let modelName = UIDevice.current.modelName

            let infoDic = Bundle.main.infoDictionary
            // 获取App的版本号
            let appVersion = infoDic?["CFBundleShortVersionString"]
            // 获取App的名称
            let appName = infoDic?["CFBundleDisplayName"] ?? "TT Analysis"

            
            let controller = MFMailComposeViewController()
            //设置代理
            controller.mailComposeDelegate = self
            //设置主题
            controller.setSubject("\(appName) Feedback")
            //设置收件人
            controller.setToRecipients([FeedbackEmail])
            //设置邮件正文内容（支持html）
            controller.setMessageBody("\n\n\nSystem Version：\(systemVersion)\n Device Name：\(modelName)\n App Name：\(appName)\n App Version：\(appVersion ?? "1.0")", isHTML: false)
            
            //打开界面
            self.present(controller, animated: true, completion: nil)
        }else{
            HUD.error("The device doesn't support email")
        }
    }
    
    //发送邮件代理方法
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension UIDevice {
   
    ///The device model name, e.g. "iPhone 6s", "iPhone SE", etc
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
       
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
       
        switch identifier {
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iphone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
            case "AppleTV5,3":                              return "Apple TV"
            case "i386", "x86_64":                          return "Simulator"
            default:                                        return identifier
        }
    }
}











