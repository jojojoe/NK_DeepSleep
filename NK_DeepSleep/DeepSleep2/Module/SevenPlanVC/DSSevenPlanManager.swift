//
//  DSSevenPlanManager.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/9/8.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import Defaults

class DSSevenPlanManager: NSObject {
    static let `default` = DSSevenPlanManager()
    // 0 1 2 3 4 5 6
    func archivePlanDay() -> [[Int:Date]] {
        if let archivedPlans = Defaults[.archivePlanDay] {
            return archivedPlans
        } else {
            return []
        }
        
    }
    
    func finishedCurrentPlan() {
        if let archivedPlans = Defaults[.archivePlanDay], let lastPlan = archivedPlans.last, let keyInt = lastPlan.keys.first {
            let currentKeyInt = keyInt + 1
            if currentKeyInt <= 6 {
                var archivedPlans_m = archivedPlans
                archivedPlans_m.append([currentKeyInt: Date()])
                Defaults[.archivePlanDay] = archivedPlans_m
            }
        } else {
            let plans = [[0: Date()]]
            Defaults[.archivePlanDay] = plans
        }
        
    }
     
    
}

extension Defaults.Keys {
    
    static let archivePlanDay = Key<[[Int:Date]]?>("archivePlanDay")
     
    
}
 
