//
//  PurchaseManager.swift
//  EasyTrack
//
//  Created by Conver on 7/8/2019.
//  Copyright © 2019 Conver. All rights reserved.
//

import Defaults
import Foundation
import NoticeObserveKit
import SwiftyStoreKit
import SwifterSwift

public class PurchaseManager {
    public static var `default` = PurchaseManager()
    var test: Bool = false
    public var receiptInfo: ReceiptInfo? {
        set {
            guard let newValue = newValue else { return }
            if let data = try? JSONSerialization
                .data(withJSONObject: newValue, options: .init(rawValue: 0)) {
                Defaults[.localIAPReceiptInfo] = data
                Notice.Center.default
                    .post(name: Notice.Names.receiptInfoDidChange, with: nil)
            }
        }
        get {
            guard let data = Defaults[.localIAPReceiptInfo] else { return nil }
            let receiptInfo = try? JSONSerialization
                .jsonObject(with: data, options: .init(rawValue: 0)) as? ReceiptInfo
            return receiptInfo
        }
    }

    public enum IAPType: String {
        case month = "com.instory.reports.month"
        case halfYear = "com.instory.reports.sixmonth"
        case year = "com.instory.reports.year2"
        case once = "com.insights.instareport.lifetime"
        //com.instory.reports.year
    }

    public let iapTypeList: [IAPType] = [.month, .halfYear, .year]

    var inSubscription: Bool {
        if UIApplication.shared.inferredEnvironment == .debug {
//            return true
        }
        
        guard let receiptInfo = receiptInfo else { return false }

        let onceInfo = SwiftyStoreKit.verifyPurchase(productId: IAPType.once.rawValue, inReceipt: receiptInfo)
        switch onceInfo {
        case .purchased:
//            LevelManager.default.updatePurchase(type: .once)
            return true
        case .notPurchased:
            break
        }

        let subscriptionIDList = Set([IAPType.month.rawValue, IAPType.year.rawValue, IAPType.halfYear.rawValue])
        let subscriptionInfo = SwiftyStoreKit.verifySubscriptions(productIds: subscriptionIDList, inReceipt: receiptInfo)
        switch subscriptionInfo {
        case let .purchased(expiryDate, items):
            let compare = Date().compare(expiryDate)
            let inPurchase = compare != .orderedDescending
            if inPurchase {
                if items.first?.productId == IAPType.month.rawValue {
//                    LevelManager.default.updatePurchase(type: .month)
                }
                if items.first?.productId == IAPType.year.rawValue {
//                    LevelManager.default.updatePurchase(type: .year)
                }
                if items.first?.productId == IAPType.halfYear.rawValue {
//                    LevelManager.default.updatePurchase(type: .halfYear)
                }
                
                SIEvent.default.tga_userPropertyForPurchase(status: .active,
                                                            productId: items.first?.productId ?? "")
            } else {
                SIEvent.default.tga_userPropertyForPurchase(status: .expired,
                                                            productId: items.first?.productId ?? "")
//                LevelManager.default.updatePurchase(type: .none, toLow: true)
            }
            return inPurchase
        case .expired, .notPurchased:
//            LevelManager.default.updatePurchase(type: .none, toLow: true)
            return false
        }
    }
    
    public func shouldAddStorePaymentHandler() {
        SwiftyStoreKit.shouldAddStorePaymentHandler = { (payment, product) -> Bool in
            UIApplication.rootController?.visibleVC?.present(BoostVC("AppStore"))
            return false
        }
    }

    public func purchaseInfo(block: @escaping (([PurchaseManager.IAPProduct]) -> Void)) {
        let iapList = iapTypeList.map { $0.rawValue }
        retrieveProductsInfo(iapList: iapList) { items in
            block(items)
        }
    }

    public func restore(_ success: (() -> Void)? = nil) {
        HUD.show()
        SwiftyStoreKit.restorePurchases(atomically: true) { [weak self] results in
            guard let `self` = self else { return }
            if results.restoreFailedPurchases.count > 0 {
                Alert.error("Restore Failed")
                debugPrint("Restore Failed: \(results.restoreFailedPurchases)")
            } else if results.restoredPurchases.count > 0 {
                for purchase in results.restoredPurchases {
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                }

                self.verify({ _ in
                    Alert.message("Restore Success", success: {
                        success?()
                        SIEvent.default
                            .tga_userPropertyForPurchase(status: .active,
                                                         productId: results.restoredPurchases.first?.productId ?? "")
                        //                    let iapID = results.restoredPurchases.first?.productId
                    })
//                    let iapType = self.iapTypeList.filter { $0.rawValue == iapID }.first
//                    LevelManager.default.updatePurchase(type: iapType)
                    debugPrint("Restore Success: \(results.restoredPurchases)")
                })
            } else {
                Alert.error("Nothing to Restore")
            }
        }
    }

    public func order(iapType: IAPType, source: String, success: (() -> Void)? = nil) {
        
        SIEvent.default.tga_eventStorePagePurchaseInit(productId: iapType.rawValue, source: source)
        HUD.show()
        SwiftyStoreKit.purchaseProduct(iapType.rawValue) { purchaseResult in
            switch purchaseResult {
            case let .success(purchaseDetail):
                self.verify { _ in
                    HUD.hide()
                    
                    var eventString: String
                    switch iapType {
                    case .month:
                        eventString = "h3aq15"
                    case .year:
                        eventString = "weptgn"
                    case .halfYear:
                        eventString = "weptgn"
                    case .once:
                        eventString = ""
                    }
                    SIEvent.default.tga_eventStorePagePurchaseFinish(productId: iapType.rawValue, source: source, result: true)
                    SIEvent.default.tga_userPropertyForPurchase(status: .active,
                                                                productId: purchaseDetail.productId)
                    
                    SIEvent.adjustTrack(eventString,
                                        price: purchaseDetail.product.price.doubleValue,
                                        currencyCode: purchaseDetail.product.priceLocale.currencyCode)
                    success?()
                }
                
//                Event.track(iapType,
//                            price: purchaseDetail.product.price.doubleValue,
//                            currencyCode: purchaseDetail.product.priceLocale.currencyCode)

            case let .error(error):
                SIEvent.default.tga_eventStorePagePurchaseFinish(productId: iapType.rawValue, source: source, result: false)
                Alert.error(error.localizedDescription)
            }
        }
    }

    public func verify(_ success: ((ReceiptInfo) -> Void)? = nil) {
        // need change new secret key
        let receiptValidator = AppleReceiptValidator(service: .production, sharedSecret: "edfde5fb05654b20895deca36deb0c41")
        SwiftyStoreKit.verifyReceipt(using: receiptValidator) { verifyResult in
            switch verifyResult {
            case let .success(receipt):
                self.receiptInfo = receipt
                success?(receipt)
            case let .error(error):
                Alert.error(error.localizedDescription)
                debugPrint("Verify Error", error.localizedDescription)
            }
        }
    }
}

public extension PurchaseManager {
    struct IAPProduct: Codable {
        public var iapID: String
        public var price: Double
        public var priceLocale: Locale
        public var localizedPrice: String?
        public var currencyCode: String?
    }

    static var localIAPProducts: [IAPProduct]? = Defaults[.localIAPProducts] {
        didSet { Defaults[.localIAPProducts] = localIAPProducts }
    }

    static var localIAPCacheTime: TimeInterval? = Defaults[.localIAPCacheTime] {
        didSet { Defaults[.localIAPCacheTime] = localIAPCacheTime }
    }

    /// 获取多项价格(maybe sync)
    func retrieveProductsInfo(iapList: [String],
                              completion: @escaping (([IAPProduct]) -> Void)) {
        let oldLocalList = PurchaseManager.localIAPProducts ?? []
        let localIAPIDList = oldLocalList.compactMap { $0.iapID }
        if localIAPIDList.contains(iapList) {
            completion(oldLocalList)
            if let cacheTime = PurchaseManager.localIAPCacheTime,
                Date().unixTimestamp - cacheTime < 1.0.hour  {
                return
            }
        }
        SwiftyStoreKit.retrieveProductsInfo(Set(iapList)) { result in
            let priceList = result.retrievedProducts.compactMap { $0 }
            let localList = priceList.compactMap { PurchaseManager.IAPProduct(iapID: $0.productIdentifier, price: $0.price.doubleValue, priceLocale: $0.priceLocale, localizedPrice: $0.localizedPrice, currencyCode: $0.priceLocale.currencyCode) }

            var tempItems = localList
            for iapItem in oldLocalList {
                let identicalItems = localList.filter { $0.iapID == iapItem.iapID }
                if identicalItems.isEmpty {
                    tempItems.append(iapItem)
                }
            }
            PurchaseManager.localIAPProducts = tempItems
            PurchaseManager.localIAPCacheTime = Date().unixTimestamp
            completion(tempItems)
        }
    }

    /// 获取单项价格(maybe sync)
    func retrieveProductsInfo(iapID: String,
                              completion: @escaping ((IAPProduct?) -> Void)) {
        retrieveProductsInfo(iapList: [iapID]) { result in
            completion(result.filter { $0.iapID == iapID }.first)
        }
    }
}

extension Defaults.Keys {
    static let localIAPReceiptInfo = OptionalKey<Data>("PurchaseManager.localIAPReceiptInfo")
    static let localIAPProducts = OptionalKey<[PurchaseManager.IAPProduct]>("PurchaseManager.LocalIAPProducts")
    static let localIAPCacheTime = OptionalKey<TimeInterval>("PurchaseManager.localIAPCacheTime")
}

extension Notice.Names {
    static let receiptInfoDidChange =
        Notice.Name<Any?>(name: "ReceiptInfoDidChange")
}
