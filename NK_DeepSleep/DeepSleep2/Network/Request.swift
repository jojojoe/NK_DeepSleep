//
//  Request.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/14.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import SEExtensions
import Defaults

struct DeepSleepResource: Codable {
    let scene: [SceneBundle]?
    let sound: [SoundBundle]?
}

struct SceneBundle: Codable {
    let id: Int?
    let name: String?
    let img_cover: String?
    let img_bg: String?
    let is_free: Int?
    let musics: [MusicItem]?
}

struct SoundBundle: Codable {
    let tag_id: Int?
    let tag_name: String?
    let is_free: Int?
    let sounds: [MusicItem]?
}

struct MusicItem: Codable {
    let name: String?
    let duration: Int?
    let media_url: String?
    let icon_url: String?
    let is_free: Int?
}



class Request: NSObject {
    static let `default` = Request()
    override init() {
        super.init()
        loadDefaultLocalResource()
    }
    var resourceModel: DeepSleepResource? = LoadJsonData.default.loadJson(DeepSleepResource.self, name: "testResource")
    
    
    func loadDefaultLocalResource() {
        if let response = Defaults[.requestResourceDataString] {
            if let jsonData = response.data(using: .utf8) {
                do {
                    let model: DeepSleepResource = try JSONDecoder().decode(DeepSleepResource.self, from: jsonData)
                    self.resourceModel = model
                } catch  {
                    
                }
            }
        }
    }
    
    func getDeepSleepResource(completion:((DeepSleepResource)->Void)?, errorBlock: ((_ errorString: String)->Void)?) {
        NetWorkRequest(.deepSleepMusic, completion: {[weak self] (response) -> (Void) in
            guard let `self` = self else {return}
            
            debugPrint(response)
            Defaults[.requestResourceDataString] = response
            
            
            if let jsonData = response.data(using: .utf8) {
                do {
                    let model: DeepSleepResource = try JSONDecoder().decode(DeepSleepResource.self, from: jsonData)
                    self.resourceModel = model
                    completion?(model)
                } catch  {
                    debugPrint(error)
                    errorBlock?(error.localizedDescription)
                }
                
            }
        }, failed: { (failed) -> (Void) in
            errorBlock?(failed)
        }) { () -> (Void) in
            errorBlock?("error")
        }
    }
}



extension Defaults.Keys {
    
    static let requestResourceDataString = Key<String?>("Request.requestResourceDataString")
    static let recentlyRequestResourceDataDate = Key<Date?>("Request.recentlyRequestResourceDataDate")
    static let isHasShowSplash = Key<Bool?>("Main_isHasShowSplash")
    
}


