
import Defaults
import Foundation
import NoticeObserveKit
import SwiftyStoreKit
import StoreKit
import ZKProgressHUD
import Alertift
import Adjust
import TPInAppReceipt

public class PurchaseManager {
    public static var `default` = PurchaseManager()
    


    let verifyProductSharedSecret = "c9a0987b700742b1aba330b650312e4b"
    let adjust_Month = "spat82"
    let adjust_Year = "1375o9"
    let adjust_halfYear = "qa2hab"
    
    
    var test: Bool = true
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
        case year = "com.deepsleep.sounds.yearnew"
        case month = "com.deepsleep.sounds.monthnew"
        case halfYear = "com.deepsleep.sounds.lifetimenew"
    }
    
    
    
    public enum VerifyLocalReceiptResult {
        case success(receipt: InAppReceipt)
        case error(error: IARError)
    }

    public enum VerifyLocalSubscriptionResult {
        case purchased(expiryDate: Date, items: [InAppReceipt])
        case expired(expiryDate: Date, items: [InAppReceipt])
        case purchasedOnceTime
        case notPurchased
    }
    public let iapTypeList: [IAPType] = [.year, .month, .halfYear]

    var _inSubscription: Bool = false
    var inSubscription: Bool {
        set {
            _inSubscription = newValue
        }
        get {
//            if UIApplication.shared.inferredEnvironment == .debug && test {
//                return false
//                return true
//            }
            if AppDelegate.fireBaseValue.in_protected == true {
                return _inSubscription
            } else {
                
                guard let receiptInfo = receiptInfo else { return false }
                
                let subscriptionIDList = Set([IAPType.year.rawValue, IAPType.month.rawValue, IAPType.halfYear.rawValue])
                let purchaseInfo = SwiftyStoreKit.verifyPurchase(productId: IAPType.halfYear.rawValue, inReceipt: receiptInfo)
                switch purchaseInfo {
                case let .purchased(item):
                    return true
                    
                default:
                    break
                }
                
                
                let subscriptionInfo = SwiftyStoreKit.verifySubscriptions(productIds: subscriptionIDList, inReceipt: receiptInfo)
                switch subscriptionInfo {
                    
                case let .purchased(expiryDate, items):
                    var inPurchase = false
                    let isOncePurchase = items.filter { $0.productId == IAPType.halfYear.rawValue }
                    if isOncePurchase.count >= 1 {
                        inPurchase = true
                    } else {
                        let compare = Date().compare(expiryDate)
                        inPurchase = compare != .orderedDescending
                        if inPurchase {
                            if items.first?.productId == IAPType.year.rawValue {
                            } else  if items.first?.productId == IAPType.month.rawValue {
                            } else  if items.first?.productId == IAPType.halfYear.rawValue {
                            }
                        } else {
                            
                        }
                    }
                    
                    if inPurchase {
                        if items.first?.productId == IAPType.year.rawValue {
                            MTEvent.default.tga_userPropertyForUserPreType(userType: MTUserTypeHelper.default.currentUserType)
                            MTEvent.default.tga_userPropertyForUserType(userType: "600")
                            MTUserTypeHelper.default.currentUserType = "600"
                        } else  if items.first?.productId == IAPType.month.rawValue {
                            MTEvent.default.tga_userPropertyForUserPreType(userType: MTUserTypeHelper.default.currentUserType)
                            MTEvent.default.tga_userPropertyForUserType(userType: "400")
                            MTUserTypeHelper.default.currentUserType = "400"
                        } else  if items.first?.productId == IAPType.halfYear.rawValue {
                            MTEvent.default.tga_userPropertyForUserPreType(userType: MTUserTypeHelper.default.currentUserType)
                            MTEvent.default.tga_userPropertyForUserType(userType: "500")
                            MTUserTypeHelper.default.currentUserType = "500"
                        }
                        
                        MTEvent.default.tga_userPropertyForPurchase(status: .active,
                                                                    productId: items.first?.productId ?? "")

                    } else {
                        MTEvent.default.tga_userPropertyForPurchase(status: .expired,
                                                                    productId: items.first?.productId ?? "")

                    }

                    
                    
                    return inPurchase
                case .expired, .notPurchased:
                    return false
                }
            }
        }
    }
    
    public func shouldAddStorePaymentHandler() {
        SwiftyStoreKit.shouldAddStorePaymentHandler = { (payment, product) -> Bool in
            UIApplication.rootController?.visibleVC?.present(DSSubscriptionVC(source: "AppStore"), animated: true)
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
                
                if AppDelegate.fireBaseValue.in_protected == true {
                    
                    self.refreshReceipt { (_, _) in
                        self.isPurchased { (status) in
                            self.inSubscription = status
                            HUD.hide()
                            if status {
                                Alert.message("Restore Success", success: {
                                    success?()
                                    
                                })
                                debugPrint("Restore Success: \(results.restoredPurchases)")
                            } else {
                                Alert.error("Nothing to Restore")
                            }
                        }
                    }
                } else {
                    
                    self.verify({ receipt in
                        let status = self.inSubscription
                        if status {
                            Alert.message("Restore Success", success: {
                                success?()
                                
                            })
                            debugPrint("Restore Success: \(results.restoredPurchases)")
                            MTEvent.default
                            .tga_userPropertyForPurchase(status: .active,
                                                         productId: results.restoredPurchases.first?.productId ?? "")
                        } else {
                            Alert.error("Nothing to Restore")
                        }
                    })
                }
            } else {
                HUD.hide()
                Alert.error("Nothing to Restore")
            }
        }
    }

    public func order(iapType: IAPType, source: String, success: (() -> Void)? = nil) {
        MTEvent.default.tga_eventPurchaseInit(iapItem: iapType.rawValue, source: source)
        HUD.show()
        SwiftyStoreKit.purchaseProduct(iapType.rawValue) { purchaseResult in
            switch purchaseResult {
            case let .success(purchaseDetail):
                
                if AppDelegate.fireBaseValue.in_protected == true {
                    self.refreshReceipt { (_, _) in
                        self.isPurchased { (status) in
                            self.inSubscription = status
                            HUD.hide()
                            // TODO: Month halfyear adjust token
                            var eventString: String
                            switch iapType {
                            case .year:
                                eventString = self.adjust_Year
                                MTEvent.default.tga_userPropertyForUserPreType(userType: MTUserTypeHelper.default.currentUserType)
                                MTEvent.default.tga_userPropertyForUserType(userType: "600")
                                MTUserTypeHelper.default.currentUserType = "600"
                            case .month:
                                eventString = self.adjust_Month
                                MTEvent.default.tga_userPropertyForUserPreType(userType: MTUserTypeHelper.default.currentUserType)
                                MTEvent.default.tga_userPropertyForUserType(userType: "400")
                                MTUserTypeHelper.default.currentUserType = "400"
                            case .halfYear:
                                eventString = self.adjust_halfYear
                                MTEvent.default.tga_userPropertyForUserPreType(userType: MTUserTypeHelper.default.currentUserType)
                                MTEvent.default.tga_userPropertyForUserType(userType: "500")
                                MTUserTypeHelper.default.currentUserType = "500"
                            }

                            let price = purchaseDetail.product.price.doubleValue
                            
                            MTEvent.default.tga_eventStorePagePurchaseFinish(productId: iapType.rawValue, source: source, result: true)
                            MTEvent.default.tga_userPropertyForPurchase(status: .active,
                                                                        productId: purchaseDetail.productId)

                            MTEvent.adjustTrackRevenue(eventString, price: price, currencyCode: purchaseDetail.product.priceLocale.currencyCode ?? "USD")
                            success?()
                        }
                        
                    }
                } else {
                    self.verify({ receipt in
                        let status = self.inSubscription
                        debugPrint("purchase status: \(status)")
                        HUD.hide()
                        
                        //
                        var eventString: String
                        switch iapType {
                        case .year:
                            eventString = self.adjust_Year
                            MTEvent.default.tga_userPropertyForUserPreType(userType: MTUserTypeHelper.default.currentUserType)
                            MTEvent.default.tga_userPropertyForUserType(userType: "600")
                            MTUserTypeHelper.default.currentUserType = "600"
                        case .month:
                            eventString = self.adjust_Month
                            MTEvent.default.tga_userPropertyForUserPreType(userType: MTUserTypeHelper.default.currentUserType)
                            MTEvent.default.tga_userPropertyForUserType(userType: "400")
                            MTUserTypeHelper.default.currentUserType = "400"
                        case .halfYear:
                            eventString = self.adjust_halfYear
                            MTEvent.default.tga_userPropertyForUserPreType(userType: MTUserTypeHelper.default.currentUserType)
                            MTEvent.default.tga_userPropertyForUserType(userType: "500")
                            MTUserTypeHelper.default.currentUserType = "500"
                        }

                        let price = purchaseDetail.product.price.doubleValue

                        MTEvent.default.tga_eventStorePagePurchaseFinish(productId: iapType.rawValue, source: source, result: true)
                        MTEvent.default.tga_userPropertyForPurchase(status: .active,
                                                                    productId: purchaseDetail.productId)

                        MTEvent.adjustTrackRevenue(eventString, price: price, currencyCode: purchaseDetail.product.priceLocale.currencyCode ?? "USD")
                        
                        //
                        
                        success?()
                    })
                }
                
            case let .error(error):
                var errorStr = error.localizedDescription
                switch error.code {
                case .unknown: errorStr = "Unknown error. Please contact support. If you are sure you have purchased it, please click the \"Restore\" button."
                case .clientInvalid: errorStr = "Not allowed to make the payment"
                case .paymentCancelled: errorStr = "Payment cancelled"
                case .paymentInvalid: errorStr = "The purchase identifier was invalid"
                case .paymentNotAllowed: errorStr = "The device is not allowed to make the payment"
                case .storeProductNotAvailable: errorStr = "The product is not available in the current storefront"
                case .cloudServicePermissionDenied: errorStr = "Access to cloud service information is not allowed"
                case .cloudServiceNetworkConnectionFailed: errorStr = "Could not connect to the network"
                case .cloudServiceRevoked: errorStr = "User has revoked permission to use this cloud service"
                default: errorStr = (error as NSError).localizedDescription
                }
                
                MTEvent.default.tga_eventStorePagePurchaseFinish(productId: iapType.rawValue, source: source, result: false)
                
                Alert.error(errorStr)
            }
        }
    }

    public func verify(_ success: ((ReceiptInfo) -> Void)? = nil) {
        // need change new secret key
        #if DEBUG
        let receiptValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: verifyProductSharedSecret)
        #else
        let receiptValidator = AppleReceiptValidator(service: .production, sharedSecret: verifyProductSharedSecret)
        #endif
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
    // main method to check if purchased anything
    func isPurchased(completion: @escaping (_ purchased: Bool) -> Void) {
       
        let dispatchGroup = DispatchGroup()
        let purchases: [IAPType] = [IAPType.halfYear, IAPType.month, IAPType.year]
        var validPurchases: [String: VerifyLocalSubscriptionResult] = [:]
        var errors: [String: Error] = [:]

        
        
        func finishCheck() {
            
            let inSubscri: Bool = !validPurchases.isEmpty
            PurchaseManager.default.inSubscription = inSubscri
            completion(inSubscri)
        }
        
        
        for key in purchases {
            dispatchGroup.enter()
            
            verifyPurchase(key) { (purchaseResult, error) in
                if let err = error {
                    errors[key.rawValue] = err
                    dispatchGroup.leave()
                    return
                }
                guard let purchase = purchaseResult else {
                    dispatchGroup.leave()
                    return
                }
                
                
                switch purchase {
                case .purchasedOnceTime:
                    validPurchases[key.rawValue] = purchase
                    dispatchGroup.leave()
                case .purchased(let expiryDate, _):
                    let now = Date()
                    if now < expiryDate {
                        validPurchases[key.rawValue] = purchase
                    }
                    dispatchGroup.leave()
                case .expired(let expiryDate, _):
                    print("Product is expired since \(expiryDate)")
                    DispatchQueue.main.async {
                        let format = DateFormatter()
                        // 2) Set the current timezone to .current, or America/Chicago.
                        format.timeZone = .current
                        // 3) Set the format of the altered date.
                        // format is: Friday, Jul 5, 2019 12:21 AM
                        format.dateFormat = "EEEE, MMM d, yyyy h:mm a"
                        // 4) Set the current date, altered by timezone.
                        let dateString = format.string(from: expiryDate)
                        debugPrint(dateString)
                        dispatchGroup.leave()
                    }
                case .notPurchased:
                    dispatchGroup.leave()
                    
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            finishCheck()
        }
    }
    
    
    func verifyPurchase(
        _ purchase: IAPType,
        completion: @escaping(VerifyLocalSubscriptionResult?, Error?) -> Void
    ) {
        verifyReceipt { (receiptResult, validationError) in

            if let error = validationError {
                completion(nil, error)
                return
            }
            
            guard let result = receiptResult else {
                completion(nil, nil)
                return
            }
            
            switch result {
            // receipt is validated
            case .success(let receipt):
                
                let oneTimePurchase = IAPType.halfYear.rawValue
                let item = receipt.purchases.first {
                    return $0.productIdentifier == oneTimePurchase
                }
                
//                // check there is a subscription first
//                //TODO: 判断是否是 一次性购买
//                if productId == IAPType.halfYear.rawValue {
//                    completion(.purchasedOnceTime, nil)
//                    return
//                }
                
                if let _ = item {
                    completion(.purchasedOnceTime, nil)
                    return
                }
                
                //////////////////////////////
                let productId = purchase.rawValue
                
                if let subscription = receipt.activeAutoRenewableSubscriptionPurchases(
                    ofProductIdentifier: productId,
                    forDate: Date()
                ) {
                    if let expiryDate = subscription.subscriptionExpirationDate {
                        completion(
                            .purchased(
                                expiryDate: expiryDate,
                                items: [receipt]
                            ),
                            nil
                        )
                        return
                    }
                    
                    // no expiry date?
                    completion(.notPurchased, nil)
                }
                let purchases = receipt.purchases(
                    ofProductIdentifier: productId
                ) { (InAppPurchase, InAppPurchase2) -> Bool in
                    return InAppPurchase.purchaseDate > InAppPurchase2.purchaseDate
                }
                if purchases.isEmpty {
                    completion(.notPurchased, nil)
                }
                else {
                    // get last purchase
                    let lastSubscription = purchases[0]
                    completion(
                        .expired(
                            expiryDate: lastSubscription.subscriptionExpirationDate ?? Date(),
                            items: [receipt]
                        ),
                        nil
                    )
                }
            // validation error
            case .error(let error):
                completion(nil, error)
            }
            
        }
    }
    
    func verifyReceipt(
        completion: @escaping(VerifyLocalReceiptResult?, Error?) -> Void
    ) {
        do {
            let receipt = try InAppReceipt.localReceipt()
            do {
                try receipt.verifyHash()
                completion(.success(receipt: receipt), nil)
            } catch IARError.initializationFailed(let reason) {
                completion(.error(error: .initializationFailed(reason: reason)),nil)
            } catch IARError.validationFailed(let reason) {
                completion(.error(error: IARError.validationFailed(reason: reason)), nil)
            } catch IARError.purchaseExpired {
                completion(.error(error: .purchaseExpired), nil)
            } catch {
                // unknown error
                completion(nil, error)
            }
        } catch {
            completion(
                .error(error: .initializationFailed(reason: .appStoreReceiptNotFound)),
                error
            )
        }
    }
    
    func refreshReceipt(completion: @escaping(FetchReceiptResult?, Error?) -> Void) {
        SwiftyStoreKit.fetchReceipt(forceRefresh: true, completion: { result in
            switch result {
            case .success:
               completion(result, nil)
            case .error(let error):
                completion(nil, error)
            }
        })
    }
}

public extension PurchaseManager {
    struct IAPProduct: Codable {
        public var iapID: String
        public var price: Double
        public var priceLocale: Locale
        public var localizedPrice: String?
        public var currencyCode: String?
        public var discountsFirstPrice: Double?
    }
    
    struct IAPProductDiscount: Codable {
        public var iapID: String
        public var price: Double
        public var priceLocale: Locale
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
            let localList = priceList.compactMap { PurchaseManager.IAPProduct(iapID: $0.productIdentifier, price: $0.price.doubleValue, priceLocale: $0.priceLocale, localizedPrice: $0.localizedPrice, currencyCode: $0.priceLocale.currencyCode, discountsFirstPrice:$0.price.doubleValue)}

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
    
    static let localIAPReceiptInfo = Key<Data?>("PurchaseManager.localIAPReceiptInfo")
    static let localIAPProducts = Key<[PurchaseManager.IAPProduct]?>("PurchaseManager.LocalIAPProducts")
    static let localIAPCacheTime = Key<TimeInterval?>("PurchaseManager.LocalIAPCacheTime")
    
}

extension Notice.Names {
    static let receiptInfoDidChange =
        Notice.Name<Any?>(name: "ReceiptInfoDidChange")
}
