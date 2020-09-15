//
/*******************************************************************************
 Copyright © 2019 Adrian. All rights reserved.
 
 File name:     API.swift
 Author:        Adrian
 
 Project name:  WhiteNoise
 
 Description:
 
 
 History:
 2019/7/16: File created.
 
 ********************************************************************************/


import Foundation
import Moya
import AdSupport

enum API{

    case deepSleepMusic  // 获取资源
     
    
}

extension API:TargetType{
    var baseURL: URL {
        return URL.init(string:(Moya_baseURL))!
    }
    
    var path: String {
        switch self {
        case .deepSleepMusic:
            return "cfg"
        }
        
    }
    
    var method: Moya.Method {
        switch self {
        case .deepSleepMusic:
            return .post
        default:
            return .post
        }
    }

    //    这个是做单元测试模拟的数据，必须要实现，只在单元测试文件中有作用
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }

    //    该条请API求的方式,把参数之类的传进来
    var task: Task {
//        return .requestParameters(parameters: nil, encoding: JSONArrayEncoding.default)
        switch self {
        case .deepSleepMusic:
            var productID = Bundle.main.bundleIdentifier ?? ""
            
            #if DEBUG
            productID = "com.deepsleep.sounds"
            #endif
            
            var productID_reverse = productID
            let version = Bundle.main.shortVersion
            let time = CLongLong(round(Date().unixTimestamp*1000))
            
            let gsid_o: String = productID + productID_reverse.reverse() + version + "\(time)"
            let gsid = gsid_o.md5.lowercased()
            return .requestParameters(parameters: ["product_id": productID, "version" : version, "time" : time, "gsid" : gsid], encoding: JSONEncoding.default)
        
//
//
//        case let .register(email, password):
//            return .requestParameters(parameters: ["email": email, "password": password], encoding: JSONEncoding.default)
//        case .easyRequset:
//            return .requestPlain
//        case let .updateAPi(parameters):
//            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
//        //图片上传
//        case .uploadHeadImage(let parameters, let imageDate):
//            ///name 和fileName 看后台怎么说，   mineType根据文件类型上百度查对应的mineType
//            let formData = MultipartFormData(provider: .data(imageDate), name: "file",
//                                              fileName: "hangge.png", mimeType: "image/png")
//            return .uploadCompositeMultipart([formData], urlParameters: parameters)
//        case .registerMobile(let mobile):
//            return .requestParameters(parameters: ["idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString, "number": mobile], encoding: JSONEncoding.default)
//        case .recordList(let mobile):
//            return .requestParameters(parameters: ["idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString, "number": mobile], encoding: JSONEncoding.default)

        }
        
        
        //可选参数https://github.com/Moya/Moya/blob/master/docs_CN/Examples/OptionalParameters.md
//        case .users(let limit):
//        var params: [String: Any] = [:]
//        params["limit"] = limit
//        return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }
 
    
    
    var headers: [String : String]? {
        return ["Content-Type" : "application/json; charset=UTF-8"]
    }
 
}
