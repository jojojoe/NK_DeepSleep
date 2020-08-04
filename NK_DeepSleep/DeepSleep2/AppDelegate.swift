//
/*******************************************************************************
    Copyright © 2020 WhiteNoise. All rights reserved.

    File name:     AppDelegate.swift
    Author:        Adrian

    Project name:  DeepSleep2

    Description:
    

    History:
            2020/7/6: File created.

********************************************************************************/
    

import UIKit
import Firebase
import FirebaseRemoteConfig
import FirebaseMessaging
import FirebaseInstanceID
import SwiftyStoreKit
import SEExtensions


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var mainVC = DSMainVC()
    var window: UIWindow?
    static var fireBaseValue = FireBaseValue()
    var remoteConfig: RemoteConfig?
    static var uuidString = ""
    
    func initMainVC() {
            
            let nav = UINavigationController.init(rootViewController: mainVC)
            nav.isNavigationBarHidden = true
            window?.rootViewController = nav
            window?.makeKeyAndVisible()
            
            #if DEBUG
    //        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
    //            DoraemonManager.shareInstance().install()
    //        }
            #endif
            #if DEBUG
            for fy in UIFont.familyNames {
                let fts = UIFont.fontNames(forFamilyName: fy)
                for ft in fts {
                    debugPrint("***fontName = \(ft)")
                }
            }
            #endif
        }
    
    func initDatabase() {
//        DatabaseHelper.default.prepareCommentUserListDatabase()
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        initMainVC()
        setupIAP()
        setupFireBaseConfig()
        MTEvent.prepare()
//        registerAPNS(application: application)
        DSDBHelper.default.prepareDB()
        MTSystemHelper.default.saveInstallAppDate()
        
        
        
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


extension AppDelegate {
    func setupIAP() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break
                }
            }
            let _ = PurchaseManager.default.inSubscription
        }

        checkSubscription()

//        PurchaseManager.default.shouldAddStorePaymentHandler()
//
//        SwiftyStoreKit.shouldAddStorePaymentHandler = { (payment, product) -> Bool in
//            AppDelegate.showSubscriptionVC(source: "AppStore")
////            UIApplication.rootController?.visibleVC?.present(TASubscriptionVC(source: "AppStore"), animated: true)
//            return false
//        }
        
        PurchaseManager.default.purchaseInfo { (results) in
            
        }
    }
    
    func checkSubscription() {
        if AppDelegate.fireBaseValue.in_protected ?? true {

            PurchaseManager.default.refreshReceipt { (_, _) in
                PurchaseManager.default.isPurchased { (status) in
                    debugPrint("current is in purchased \(status)")
                    PurchaseManager.default.inSubscription = status
                    NotificationCenter.default.post(
                        name: NSNotification.Name(rawValue: PurchaseStatusNotificationKeys.success),
                        object: nil,
                        userInfo: nil
                    )
                }
            }
        } else {
            if PurchaseManager.default.inSubscription {
                PurchaseManager.default.verify { receiptInfo in
                    
                }
            }
        }
    }
}


extension AppDelegate: MessagingDelegate {
    
    struct FireBaseValue: Codable {
        
        init() {

        }
        
        init(remoteConfig: RemoteConfig) {
            in_protected = remoteConfig["iOS_in_protected"].boolValue

            firebaseFinish = true
        }
        var firebaseFinish = false
        /// 是否in_protected状态，true——是，false——否
        var in_protected: Bool? = true
    }
    func setupFireBaseConfig() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
        
        remoteConfig = RemoteConfig.remoteConfig()
        
        let setting = RemoteConfigSettings()
        setting.minimumFetchInterval = 0
        
        remoteConfig?.configSettings = setting
        
        remoteConfig?.fetchAndActivate { [weak self] (status, error) in
            guard let `self` = self else { return }
            guard let remoteConfig = self.remoteConfig else{ return }
            switch status {
            case .successFetchedFromRemote, .successUsingPreFetchedData:
                AppDelegate.fireBaseValue = FireBaseValue(remoteConfig: remoteConfig)
                self.checkSubscription()
                debugPrint("allKeys", AppDelegate.fireBaseValue)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NOT_LOADFIREBASESUCCESS"), object: [:], userInfo: nil)
            case .error:
                AppDelegate.fireBaseValue = FireBaseValue()
                break
            @unknown default:
                break
            }
        }
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}


extension AppDelegate {
    static func generateUUIDString() -> String {
        let uuid_ref = CFUUIDCreate(nil)
        let uuid_string_ref = CFUUIDCreateString(nil, uuid_ref)
        let uuid = uuid_string_ref! as String
        return uuid.lowercased()
    }
    
    static func updateLocalUUIDString() {
        AppDelegate.uuidString = AppDelegate.generateUUIDString()
    }
}

extension AppDelegate {
    static func showSubscriptionVC(source: String) {
        let subscriptinoVC = DSSubscriptionVC.init(source: source)
//        subscriptinoVC.backBtnBlock = {
//            subscriptinoVC.view.removeFromSuperview()
//            subscriptinoVC.removeFromParent()
//        }
        
        
//        if let visibleVC = UIApplication.rootController?.visibleVC, !visibleVC.className.contains("alert") {
//            visibleVC.addChild(subscriptinoVC)
//            subscriptinoVC.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height)
//            visibleVC.view.addSubview(subscriptinoVC.view)
//        }
        subscriptinoVC.modalPresentationStyle = .fullScreen
        UIApplication.rootController?.visibleVC?.present(subscriptinoVC, animated: true)
        
        
    }
    
    
    
}



extension AppDelegate: UNUserNotificationCenterDelegate {
    func registerAPNS(application: UIApplication) {
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
    }
}

