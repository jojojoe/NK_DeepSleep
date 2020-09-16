//
//  DSSubscriptionVC.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/7.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import SwifterSwift
import PinLayout
import SEExtensions
import Shimmer

struct PurchaseStatusNotificationKeys {
    static let success = "success"
    static let failed = "failed"
}
class DSSubscriptionVC: UIViewController {

    let monthPrice: Double = 4.99
    let yearPrice: Double = 29.99
    let oncePrice: Double = 49.99

    
    let purchaseUrl = "https://ds.funnyplay.me/DS/DeepSleep_Notice_of_Purchase.html"
    let TermsofuseURLStr = "https://ds.funnyplay.me/DS/DeepSleep_Terms_of_use.html"
    let PrivacyPolicyURLStr = "https://ds.funnyplay.me/DS/DeepSleep_Privacy_Policy.html"
    
    
    var source: String?
    var backBtnBlock: (()->Void)?
//    var noticePurchaseInfoBlock: (()->Void)?
    let bottomLinkView = SISupscriptionBottomLinkView.loadFromNib()
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBAction func closeBtnClick(_ sender: UIButton) {
//        backBtnBlock?()
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var titleLabel1: UILabel!
    @IBOutlet weak var titleLabel2: UILabel!
    
    @IBOutlet weak var descripLabel1: UILabel!
    @IBOutlet weak var descripLabel2: UILabel!
    @IBOutlet weak var descripLabel3: UILabel!
    
    
    @IBOutlet weak var monthSubBtn: UIControl!
    @IBAction func monthSubBtnClick(_ sender: UIControl) {
        currentSubType = .month
        
    }
    @IBOutlet weak var monthSubTitleLabel: UILabel!
    @IBOutlet weak var monthSubDesLabel: UILabel!
    @IBOutlet weak var monthSubDesLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var monthSubSelectedView: UIView!
    
    @IBOutlet weak var yearSubBtn: UIControl!
    @IBAction func yearSubBtnClick(_ sender: UIControl) {
        currentSubType = .year
    }
    @IBOutlet weak var yearSubTitleLabel: UILabel!
    @IBOutlet weak var yearSubDesLabel: UILabel!
    @IBOutlet weak var yearSubDesLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var yearSubSelectedView: UIView!
    
    @IBOutlet weak var onceSubBtn: UIControl!
    @IBAction func onceSubBtnClick(_ sender: UIControl) {
        currentSubType = .halfYear
    }
    @IBOutlet weak var onceSubTitleLabel: UILabel!
    @IBOutlet weak var onceSubDesLabel: UILabel!
    @IBOutlet weak var onceSubDesLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var onceSubSelectedView: UIView!
    
    @IBOutlet weak var yearSaveDiscountLabel: UILabel!
    @IBOutlet weak var subscriptionStartBtn: UIButton!
    @IBAction func subscriptionStartBtnClick(_ sender: UIButton) {
        MTEvent.default.tga_eventPurchaseInit(iapItem: currentSubType.rawValue, source: source ?? "unKnown")
        
        submitAction(iapType: currentSubType)
    }
    
    @IBOutlet weak var purchaseBgView: UIView!
    
    
    
    let didApperaOnce = Once()
    
    
    // month year once
    var currentSubType: PurchaseManager.IAPType = .year {
        didSet {
            monthSubSelectedView.isHidden = true
            yearSubSelectedView.isHidden = true
            onceSubSelectedView.isHidden = true
            
            switch currentSubType {
            case .month:
                monthSubSelectedView.isHidden = false
            case .year:
                yearSubSelectedView.isHidden = false
            case .halfYear:
                onceSubSelectedView.isHidden = false
                
            }
            
        }
    }
    
    
    init(source: String = "") {
        self.source = source
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupDefaultPrice()
        loadPurchaseInfo()
        currentSubType = .year
        
        
        titleLabel1.font(24, UIFont.FontNames.Quicksand_Bold)
        titleLabel2.font(14, UIFont.FontNames.Quicksand_Medium)
        descripLabel1.font(16, UIFont.FontNames.Quicksand_Bold)
        descripLabel2.font(16, UIFont.FontNames.Quicksand_Bold)
        descripLabel3.font(16, UIFont.FontNames.Quicksand_Bold)
        
        
        monthSubTitleLabel.font(15, UIFont.FontNames.Quicksand_Medium)
        yearSubTitleLabel.font(15, UIFont.FontNames.Quicksand_Medium)
        onceSubTitleLabel.font(15, UIFont.FontNames.Quicksand_Medium)
        monthSubDesLabel.font(12, UIFont.FontNames.Quicksand_Regular)
        yearSubDesLabel.font(12, UIFont.FontNames.Quicksand_Regular)
        
        yearSaveDiscountLabel.font(13, UIFont.FontNames.Quicksand_Bold)
        subscriptionStartBtn.font(18, UIFont.FontNames.Quicksand_Bold)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MTEvent.default.tga_event_purchaseShow(itemName: source ?? "unKnown")
//        bottomLinkView.pin.bottom(view.safeAreaInsets.bottom + 24)
//        bottomLinkView.pin.hCenter().width(80%).height(30)
        didApperaOnce.run {
            MTEvent.default.tga_userPropertyIncreaseEnterPageCount()
            MTUserTypeHelper.default.saveEnterStorePage()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width: CGFloat = 320
        let height: CGFloat = 34
        let Ox: CGFloat = (UIScreen.width - width) / 2
        let Oy: CGFloat = (UIScreen.height - height - view.safeAreaInsets.bottom)
        bottomLinkView.frame = CGRect.init(x: Ox, y: Oy, width: width, height: height)
//        bottomLinkView.pin.bottom(view.safeAreaInsets.bottom + 24)
//        bottomLinkView.pin.hCenter().width(80%).height(30)
        
    }
    
}





extension DSSubscriptionVC {
    func setupView() {
        view.addSubview(bottomLinkView)
        bottomLinkView.purchaseBtnBlock = {
            [weak self] in
            guard let `self` = self else {return}
            self.openUrl(string: self.purchaseUrl)
        }
        bottomLinkView.termsBtnBlock = {
            [weak self] in
            guard let `self` = self else {return}
            self.openUrl(string: self.TermsofuseURLStr)
        }
        bottomLinkView.privacyBtnBlock = {
            [weak self] in
            guard let `self` = self else {return}
            self.openUrl(string: self.PrivacyPolicyURLStr)
        }
        
        
        
        

        // Setup the view you want shimmered
        
        addShimmerBtn()
        
    }
    
    func addShimmerBtn() {
        
        
        let shimmeringView = FBShimmeringView(frame: CGRect.init(x: 0, y: 0, width: 260, height: 52))
        self.purchaseBgView.addSubview(shimmeringView)
        shimmeringView.isUserInteractionEnabled = true
        shimmeringView.isShimmering = true
        shimmeringView.shimmeringBeginFadeDuration = 0.3
        shimmeringView.shimmeringEndFadeDuration = 0.9
        shimmeringView.shimmeringPauseDuration = 1.0
        
        shimmeringView.layer.cornerRadius = 0;//height / 2;
        // 一次周期的时间间隔
        shimmeringView.shimmeringPauseDuration = 1.0;
        // 0-1之间，闪烁的线条间隔  由于给图片加，那么就要粗一点，好看点
        shimmeringView.shimmeringHighlightLength = 0.5
        
        shimmeringView.shimmeringSpeed = 200;
        shimmeringView.shimmeringOpacity = 1.0;
        shimmeringView.backgroundColor = .white
        shimmeringView.contentView = self.subscriptionStartBtn;
        

    }
    
    
    func openUrl(string: String) {
        guard let url = URL(string: string) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}


extension DSSubscriptionVC {
    func setupDefaultPrice() {
        let monthPriceStr = "$\(monthPrice)"
        let monthTitleStr = "Monthly: XX".localized().replacingOccurrences(of: "XX", with: monthPriceStr)

        let yearPriceStr = "$\(yearPrice)"
        let yearTitleStr = "Yearly: XX".localized().replacingOccurrences(of: "XX", with: yearPriceStr)

        let oncePriceStr = "$\(oncePrice)"
        let onceTitleStr = "Lifetime: XX".localized().replacingOccurrences(of: "XX", with: oncePriceStr)
        
        self.monthSubTitleLabel.text = monthTitleStr
        self.yearSubTitleLabel.text = yearTitleStr
        self.onceSubTitleLabel.text = onceTitleStr
            
        self.monthSubDesLabel.text = ""
        self.yearSubDesLabel.text = ""
        self.onceSubDesLabel.text = ""
        
        self.monthSubDesLabelHeight.constant = 0
        self.yearSubDesLabelHeight.constant = 0
        self.onceSubDesLabelHeight.constant = 0
        
    }
    
    func loadPurchaseInfo() {
        PurchaseManager.default.purchaseInfo { [weak self] items in
            guard let `self` = self else { return }
            
            
            DispatchQueue.main.async {
                [weak self] in
                guard let `self` = self else {return}
                
                let yearItem = items.filter { $0.iapID == PurchaseManager.IAPType.year.rawValue }.first
                let currencyCode = yearItem?.priceLocale.currencySymbol ?? "$"
                
                let monthItem = items.filter { $0.iapID == PurchaseManager.IAPType.month.rawValue }.first
                
                let onceItem = items.filter { $0.iapID == PurchaseManager.IAPType.halfYear.rawValue }.first
                
                #if DEBUG
                //            AppDelegate.fireBaseValue.showSpecial = true
                #endif
                if AppDelegate.fireBaseValue.in_protected == true {
                    
                    let monthPriceStr = "\(currencyCode)\(String(format: "%.2f", monthItem?.price ?? self.monthPrice))"
                    let monthTitleStr = "Monthly: XX".localized().replacingOccurrences(of: "XX", with: monthPriceStr)
                    
                    let yearPriceStr = "\(currencyCode)\(String(format: "%.2f", yearItem?.price ?? self.yearPrice))"
                    let yearTitleStr = "Yearly: XX".localized().replacingOccurrences(of: "XX", with: yearPriceStr)
                    
                    let oncePriceStr = "\(currencyCode)\(String(format: "%.2f", onceItem?.price ?? self.oncePrice))"
                    let onceTitleStr = "Lifetime: XX".localized().replacingOccurrences(of: "XX", with: oncePriceStr)
                    
                    self.monthSubTitleLabel.text = monthTitleStr
                    self.yearSubTitleLabel.text = yearTitleStr
                    self.onceSubTitleLabel.text = onceTitleStr
                    
                    self.monthSubDesLabel.text = ""
                    self.yearSubDesLabel.text = ""
                    self.onceSubDesLabel.text = ""
                    
                    self.monthSubDesLabelHeight.constant = 0
                    self.yearSubDesLabelHeight.constant = 0
                    self.onceSubDesLabelHeight.constant = 0
                    
                } else {
                    let monthPriceStr = "\(currencyCode)\(String(format: "%.2f", monthItem?.price ?? self.monthPrice))"
                    let monthTitleStr = "Monthly: XX".localized().replacingOccurrences(of: "XX", with: monthPriceStr)
                    
                    let yearPriceStr = "\(currencyCode)\(String(format: "%.2f", yearItem?.price ?? self.yearPrice))"
                    let yearTitleStr = "Yearly: XX".localized().replacingOccurrences(of: "XX", with: yearPriceStr)
                    
                    let oncePriceStr = "\(currencyCode)\(String(format: "%.2f", onceItem?.price ?? self.oncePrice))"
                    let onceTitleStr = "Lifetime: XX".localized().replacingOccurrences(of: "XX", with: oncePriceStr)
                    
                    self.monthSubTitleLabel.text = monthTitleStr
                    self.yearSubTitleLabel.text = yearTitleStr
                    self.onceSubTitleLabel.text = onceTitleStr
                    
                    if let monthDiscountPrice = monthItem?.discountsFirstPrice {
                        let monthDiscountPriceStr = "\(currencyCode)\(monthDiscountPrice)"
                        self.monthSubDesLabel.text = "First Month: XX".localized().replacingOccurrences(of: "XX", with: monthDiscountPriceStr)
                    }
                    
                    
                    let yearDesPrice = (((yearItem?.price ?? self.yearPrice) / 12.0) * 100.0).int
                    let yearPerMonthPrice = String(format: "%.2f", yearDesPrice.double / 100.0)
                    let yearDesPriceStr = "\(currencyCode)\(yearPerMonthPrice)"
                    let yearDesStr = "Per Month ≈ XX".localized().replacingOccurrences(of: "XX", with: yearDesPriceStr)
                    
                    self.yearSubDesLabel.text = yearDesStr
                    self.yearSubDesLabel.isHidden = false
                    //                self.monthSubDesLabel.isHidden = false
                    
                    self.onceSubDesLabel.text = ""
                    
                    self.monthSubDesLabelHeight.constant = 0
                    self.yearSubDesLabelHeight.constant = 18
                    self.onceSubDesLabelHeight.constant = 0
                    
                }
                
            }
            
            
        }
    }
    
    
}



extension DSSubscriptionVC {
    func submitAction(iapType: PurchaseManager.IAPType) {
        
        PurchaseManager.default.order(iapType: iapType, source: source ?? "unknown", success: { [weak self] in
            let status = PurchaseManager.default.inSubscription
            print("purchase status : \(status)")
            if status == true {
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: PurchaseStatusNotificationKeys.success),
                    object: nil,
                    userInfo: nil
                )
                self?.dismissVC()
            }
            
            
//            self?.backBtnBlock?()
            
        })
        
        
        
    }
    
    
    
}



