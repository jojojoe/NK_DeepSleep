//
//  MTSystemHelper.swift
//  TiktokAnalysis
//
//  Created by JOJO on 2020/6/12.
//  Copyright © 2020 Manager. All rights reserved.
//


import UIKit

class MTSystemHelper: NSObject {
    static let `default` = MTSystemHelper()
    func saveInstallAppDate() {
        if let installDate = installAppDate() {
            debugPrint("app install date is : \(installDate)")
        } else {
            UserDefaults.standard.set(Date(), forKey: "SYSTEM_APP_INSTALLDATE")
        }
        
    }
    
    func installAppDate() -> Date? {
        let date = UserDefaults.standard.object(forKey: "SYSTEM_APP_INSTALLDATE") as? Date
        return date
    }
    
    func daysFromInstalled() -> Int {
        if let installDate = installAppDate() {
            let now = Date()
            var result = Int(ceil(now.daysSince(installDate)))
            if result <= 1 {
                result = 1
            }
            return result
        } else {
            return 1
        }
    }
 
}
