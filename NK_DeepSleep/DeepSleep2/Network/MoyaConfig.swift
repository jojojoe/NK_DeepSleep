//
/*******************************************************************************
 Copyright © 2019 Adrian. All rights reserved.
 
 File name:     MoyaConfig.swift
 Author:        Adrian
 
 Project name:  WhiteNoise
 
 Description:
 
 
 History:
 2019/7/16: File created.
 
 ********************************************************************************/
import Foundation
/// 定义基础域名
// "http://192.168.1.202:8080/"
let Moya_baseURL = "https://api.funnyplay.me/ds/"

/// 定义返回的JSON数据字段
let RESULT_CODE = "status"      //状态码

let RESULT_MESSAGE = "message"  //错误消息提示


/*  错误情况的提示
 {
 "flag": "0002",
 "msg": "手机号码不能为空",
 "lockerFlag": true
 }
 **/
