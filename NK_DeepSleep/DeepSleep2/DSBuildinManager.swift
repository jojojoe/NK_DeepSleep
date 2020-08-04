//
//  DSBuildinManager.swift
//  DeepSleep2
//
//  Created by Joe on 2020/7/22.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import Foundation
import SEExtensions
class DSBuildinManager {
    static let `default` = DSBuildinManager()
    
    let buildinMap: [String: String] = LoadJsonData.default.loadJson([String: String].self, name: "buildinResourceMap") ?? [:]
    
    func buildinResourceName(remoteName: String?) -> String? {
//        return nil
        if let remoteName_t = remoteName {
//            #if DEBUG
//            
//            let testSoundsList = ["https://source.funnyplay.me/SleepMedia/sound/Nature/cicada.mp3": "test_sound1.wav", "https://source.funnyplay.me/SleepMedia/sound/Nature/ripple.mp3": "test_sound2.wav", "https://source.funnyplay.me/SleepMedia/sound/Nature/tidewater.mp3": "test_sound3.wav",
//                                  "https://source.funnyplay.me/SleepMedia/scene/Afternoon+Tea/Enjoy+the+moment.mp3": "test_sound1.wav",
//                                  "https://source.funnyplay.me/SleepMedia/scene/Afternoon+Tea/In+a+calm.mp3": "test_sound2.wav",
//                                  "https://source.funnyplay.me/SleepMedia/scene/Afternoon+Tea/Leisurely+afternoon.mp3": "test_sound3.wav",
//                                  "https://source.funnyplay.me/SleepMedia/scene/Afternoon+Tea/Start.mp3": "test_sound4.m4a",
//                                  
//            ]
//            
//            if testSoundsList.keys.contains(remoteName_t) {
//                return testSoundsList[remoteName_t]
//            }
//            
//            #endif
            
            return buildinMap[remoteName_t]
        } else {
            return nil
        }
    }
    
}
