//
//  MTUserTypeHelper.swift
//  TiktokAnalysis
//
//  Created by JOJO on 2020/6/12.
//  Copyright © 2020 Manager. All rights reserved.
//


import UIKit

class MTUserTypeHelper: NSObject {
    static var `default` = MTUserTypeHelper()
    
    var currentUserType: String {
        set {
            UserDefaults.standard.set(object: newValue, forKey: "CurrentUserType")
        }
        
        get {
            if let userType = UserDefaults.standard.string(forKey: "CurrentUserType") {
                return userType
            } else {
                return "300"
            }
        }
    }
    
    var enterStorePage: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: "CurrentUserEnterStoreCount")
        }
        
        get {
            return UserDefaults.standard.integer(forKey: "CurrentUserEnterStoreCount")
        }
    }
    
    func saveEnterStorePage() {
        self.enterStorePage = enterStorePage + 1
        checkCurrentUserType()
    }
    
    func checkCurrentUserType() {
        if !PurchaseManager.default.inSubscription {
            MTEvent.default.tga_userPropertyForUserPreType(userType: self.currentUserType)

            let installDays = MTSystemHelper.default.daysFromInstalled()
            if installDays <= 1 || self.enterStorePage <= 5 {
                self.currentUserType = "300"
            } else if (installDays > 1 && installDays <= 2) || (self.enterStorePage > 5 && self.enterStorePage <= 10) {
                self.currentUserType = "200"
            } else {
                self.currentUserType = "100"
            }
            MTEvent.default.tga_userPropertyForUserType(userType: self.currentUserType)
        }
        
    }
}
