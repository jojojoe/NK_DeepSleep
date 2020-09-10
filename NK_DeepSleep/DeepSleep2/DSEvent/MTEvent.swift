//
//  MTEvent.swift
//  TiktokAnalysis
//
//  Created by JOJO on 2020/6/12.
//  Copyright © 2020 Manager. All rights reserved.
//
import UIKit
import Adjust
import AdSupport
import ThinkingSDK
import Defaults

let adjustAppToken = "82sexj0phgg0"
let ThinkingAnalyticsSDKAppId = "7054bc633e06425eb04dd4aaca4631b5"

class MTEvent: NSObject {
    
    var thinkingAnalytics: ThinkingAnalyticsSDK?
    
    
    @objc
    public static var `default` = MTEvent()

    static func prepare() {
        MTEvent.default.thinkingAnalytics = ThinkingAnalyticsSDK.start(withAppId: ThinkingAnalyticsSDKAppId,
                                   withUrl: "http://analytics.socialcube.me")
        
        MTEvent.default.tga_eventSuperProperties()
        
        MTEvent.default.tga_onceUserProperty(version: UIApplication.shared.version ?? "",
                             createTime: Date().string(withFormat: "yyyy-MM-dd HH:mm"))
        MTEvent.default.tga_eventSession()
        MTEvent.default.adjustPrepare()
    }
}
extension MTEvent: AdjustDelegate {
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        MTEvent.default.tga_userPropertyForChannel(channel: Adjust.attribution()?.trackerName ?? "Organic")
        MTEvent.default.tga_eventSuperProperties()
    }
}

extension MTEvent { // Adjust
    
    func adjustPrepare() {
        #if DEBUG
        let config = ADJConfig(appToken: adjustAppToken, environment: ADJEnvironmentSandbox)
        config?.delegate = self
        config?.defaultTracker = "organic"
        Adjust.appDidLaunch(config)
        #else
        let config = ADJConfig(appToken: adjustAppToken, environment: ADJEnvironmentProduction)
        config?.delegate = self
        config?.defaultTracker = "organic"
        Adjust.appDidLaunch(config)
        #endif
        
        
    }
    
    /// 订阅事件
    /// - Parameters:
    ///   - event: 事件key
    ///   1. 月订阅 Purchased_month ：z0rtvz;
    ///   2. 半年订阅 Purchased_sixmonth：o5rrhd;
    ///   3. 年订阅 Purchased_year：6e43mz
    ///   - price: 订阅价格， 如 23.99
    ///   - currencyCode: 订阅货币类型， 如 USD
    static func adjustTrackRevenue(_ event: String?,
                                   price: Double?,
                                   currencyCode: String?) {
        guard let event = event else { return }
        let adjEvent = ADJEvent(eventToken: event)
        if let price = price {
            adjEvent?.setRevenue(price, currency: currencyCode ?? "USD")
        }
        Adjust.trackEvent(adjEvent)
    }
}

// TT Analysis User
extension MTEvent {
    
    /// 登录成功后调用
    @objc
    public func tga_userPropertyLogin(userID: String) {
        MTEvent.default.thinkingAnalytics?.logout()
        MTEvent.default.thinkingAnalytics?.login(userID)
    }

    /// 登出或切换账户调用
    @objc
    public func tga_userPropertyLogout() {
        MTEvent.default.thinkingAnalytics?.logout()
    }

    /// 标识用户基础属性，登录成功以及重新获取用户信息成功后需要调用
    /// - Parameter userName: 用户名
    /// - Parameter fansingCount: 当前用户被粉过的数量
    /// - Parameter fanserCount: 当前用户粉过的数量
    /// - Parameter postsCount: 当前用户发的帖子数量
    public func tga_userProperty(userName: String, fansingCount: Int, fanserCount: Int, postsCount: Int) {
        MTEvent.default.thinkingAnalytics?.user_set([
            "tta_uname": userName,
            "tta_following": fansingCount,
            "tta_followers": fanserCount,
            "tta_posts": postsCount,
            "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
        ])
    }
    
    /// 标识用户属性，仅记录一次
    /// - Parameter channel: 来源，通过adjust获取
    /// - Parameter version: 当前App版本号
    /// - Parameter createTime: 格式化的当前时间， YYYY-MM-DD HH:mm
    public func tga_onceUserProperty(version: String, createTime: String) {
        MTEvent.default.thinkingAnalytics?.user_setOnce([
            "ds_version": version,
            "ds_create_time": createTime,
        ])
    }
    
    /// 归因回传
    /// - Parameter channel: 来源，通过adjust获取
    public func tga_userPropertyForChannel(channel: String) {
        MTEvent.default.thinkingAnalytics?.user_set([
            "ds_channel": channel,
        ])
    }
    
    enum tga_userPropertyForPurchaseType: String {
        case active = "active"
        case expired = "expired"
        case cancel = "cancel"
    }
    
    /// 订阅状态更新后需要调用
    /// - Parameter status: 购买状态，active/expired/cancel
    /// - Parameter productId: 购买项：iap id
    public func tga_userPropertyForPurchase(status: tga_userPropertyForPurchaseType, productId: String) {
        MTEvent.default.thinkingAnalytics?.user_set([
            "ds_buy_status": status.rawValue,
            "ds_buy_item": productId,
        ])
    }
    
    /// 用户类型
    /// - Parameter userType: "用户类型
    /// 600：年购买用户
    /// 500：半年购用户
    /// 400：月购买用户；
    /// 300：新用户24h以内或订阅面进入5次以内；
    /// 200：48小时内或进入订阅面次数在5-10次；
    /// 100：超过48小时或进入订阅面次数大于10次；"
    public func tga_userPropertyForUserType(userType: String) {
        MTEvent.default.thinkingAnalytics?.user_set([
            "tta_user_type": userType,
        ])
    }
    
    /// 用户之前的user type
    /// - Parameter userType: type
    public func tga_userPropertyForUserPreType(userType: String) {
        MTEvent.default.thinkingAnalytics?.user_set([
            "tta_prev_usertype": userType,
        ])
    }
    
    /// 累计进入订阅面次数
    public func tga_userPropertyIncreaseEnterPageCount() {
        MTEvent.default.thinkingAnalytics?.user_add([
            "ds_sum_subpage_enter" : 1
        ])
    }

    /// 记录第一次刷新耗时
    /// - Parameter duration: 第一次成功刷新所需时间，秒
    public func tga_userPropertyForFirstRefreshDuration(duration: Int) {
        MTEvent.default.thinkingAnalytics?.user_set([
            "ds_refresh_duration_first": duration,
        ])
    }

    /// 记录刷新耗时
    /// - Parameter duration: 最近一次刷新所需时间，秒
    public func tga_userPropertyForRefreshDuration(duration: Int) {
        MTEvent.default.thinkingAnalytics?.user_set([
            "tta_refresh_duration_current": duration,
        ])
    }

    /// 设置所有事件公用属性
    public func tga_eventSuperProperties() {
        MTEvent.default.thinkingAnalytics?.setSuperProperties([
            "ds_eparam_channel": Adjust.attribution()?.trackerName ?? "Organic",
            "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
        ])
    }
 
}


// DS EVENT

extension MTEvent {
    @objc
    public func tga_eventSoundShow() {
        MTEvent.default.thinkingAnalytics?.track("ds_event_sound_show", properties: [

            "ds_eparam_channel":  Adjust.attribution()?.trackerName ?? "Organic",
            "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
        ])
        
    }

    @objc
       public func tga_eventRandommixClick() {
           MTEvent.default.thinkingAnalytics?.track("ds_event_randommix_click", properties: [

               "ds_eparam_channel":  Adjust.attribution()?.trackerName ?? "Organic",
               "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
           ])
           
       }
    
    @objc
    public func tga_eventSoundClick(itemName: String) {
        MTEvent.default.thinkingAnalytics?.track("ds_event_sound_click", properties: [

            "ds_eparam_channel":  Adjust.attribution()?.trackerName ?? "Organic",
            "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
            "ds_eparam_sounditem_name": itemName,
        ])
    }
    
    
    @objc
    public func tga_eventMeditationShow() {
        MTEvent.default.thinkingAnalytics?.track("ds_event_meditation_show", properties: [
            "ds_eparam_channel":  Adjust.attribution()?.trackerName ?? "Organic",
            "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
        ])
        
    }
    
    @objc
    public func tga_eventMeditationItemClick(itemName: String) {
        MTEvent.default.thinkingAnalytics?.track("ds_event_meditationitem_click", properties: [

            "ds_eparam_channel":  Adjust.attribution()?.trackerName ?? "Organic",
            "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
            "ds_eparam_meditationitem_name": itemName,
        ])
    }
    
    @objc
    public func tga_eventAccountShow() {
        MTEvent.default.thinkingAnalytics?.track("ds_event_account_show", properties: [
            "ds_eparam_channel":  Adjust.attribution()?.trackerName ?? "Organic",
            "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
        ])
        
    }
    
    @objc
    public func tga_eventAccountItemClick(itemName: String) {
        MTEvent.default.thinkingAnalytics?.track("ds_event_accountitem_click", properties: [

            "ds_eparam_channel":  Adjust.attribution()?.trackerName ?? "Organic",
            "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
            "ds_eparam_meditationitem_name": itemName,
        ])
    }
    
    @objc
    public func tga_eventFavoriteShow() {
        MTEvent.default.thinkingAnalytics?.track("ds_event_favorite_show", properties: [
            "ds_eparam_channel":  Adjust.attribution()?.trackerName ?? "Organic",
            "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
        ])
        
    }
    
    @objc
    public func tga_eventConsoleClick(index: Int) {
        MTEvent.default.thinkingAnalytics?.track("ds_event_console_click", properties: [
            "ds_eparam_channel":  Adjust.attribution()?.trackerName ?? "Organic",
            "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
            "ds_eparam_console_poistion": index,
        ])
    }
    
    @objc
       public func tga_eventConsoleDelete(index: Int) {
           MTEvent.default.thinkingAnalytics?.track("ds_event_console_delete", properties: [
               "ds_eparam_channel":  Adjust.attribution()?.trackerName ?? "Organic",
               "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
               "ds_eparam_console_poistion": index,
           ])
       }
    
    @objc
    public func tga_eventConsoleVolume() {
        MTEvent.default.thinkingAnalytics?.track("ds_event_console_volume", properties: [
            "ds_eparam_channel":  Adjust.attribution()?.trackerName ?? "Organic",
            "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
            
        ])
    }
    
    //sound，favorite，topbar，meditation
    @objc
    public func tga_event_purchaseShow(itemName: String) {
        MTEvent.default.thinkingAnalytics?.track("ds_event_purchase_page", properties: [

            "ds_eparam_channel":  Adjust.attribution()?.trackerName ?? "Organic",
            "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
            "ds_eparam_purchase_prepage": itemName,
        ])
    }
    
    
    @objc
    public func tga_eventPurchaseInit(iapItem: String, source: String) {
        MTEvent.default.thinkingAnalytics?.track("ds_event_purchase_init", properties: [
            "ds_eparam_channel":  Adjust.attribution()?.trackerName ?? "Organic",
            "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
            "ds_eparam_purchase_iap": iapItem,
            "ds_eparam_purchase_prepage": source,
        ])
    }
    
    // 0 成功 、 1 失败
    @objc
    public func tga_eventStorePagePurchaseFinish(productId: String, source: String, result: Bool) {
        let installDate = MTSystemHelper.default.installAppDate()?.timeIntervalSince1970 ?? 0

        let timeStamp = Date().timeIntervalSince1970
        let duration = Int(timeStamp) - Int(installDate)
        
        MTEvent.default.thinkingAnalytics?.track("ds_event_purchase_finish", properties: [
            "ds_eparam_channel":  Adjust.attribution()?.trackerName ?? "Organic",
            "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
            "ds_eparam_purchase_iap": productId,
            "ds_eparam_purchase_prepage": source,
            "ds_eparam_purchase_result":  result ? 0 : 1,
            "ds_eparam_purchase_time_from_install":duration,
        ])
    }
    
    
    /// tta_event_purchase_finish
    /// com.xxx.30days etc
    /// 0:成功,1:未查询到用户名,2:其他异常
//    @objc
//    public func tga_eventStorePagePurchaseFinish(productId: String, source: String, result: Bool) {
//        let installDate = MTSystemHelper.default.installAppDate()?.timeIntervalSince1970 ?? 0
//
//        let timeStamp = Date().timeIntervalSince1970
//        let duration = Int(timeStamp) - Int(installDate)
//        MTEvent.default.thinkingAnalytics?.track("tta_event_purchase_finish", properties: [
//            "tta_eparam_purchase_iap": productId,
//            "tta_eparam_purchase_prepage": source,
//            "tta_eparam_purchase_result": result ? 0 : 1,
//            "tta_eparam_purchase_time_from_install": duration
//
//        ])
//    }
    
    
    
    @objc
    public func tga_eventSession() {
        
        let isFirstOpen = Defaults[.isFirstOpenSession] ?? true
        var status = 0 // 0: true 1: false
        if isFirstOpen {
            status = 0
            Defaults[.isFirstOpenSession] = false
        } else {
            status = 1
        }
        MTEvent.default.thinkingAnalytics?.track("ds_event_session", properties: [
            "ds_eparam_channel":  Adjust.attribution()?.trackerName ?? "Organic",
            "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
            "ds_eparam_isfirst_open": status,
        ])
        
    }
    
    
    
    @objc
    public func tga_eventPlan7Day_Click() {
        
        MTEvent.default.thinkingAnalytics?.track("ds_event_7day_click", properties: [
            "ds_eparam_channel":  Adjust.attribution()?.trackerName ?? "Organic",
            "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
            
        ])
        
    }
    
    @objc
    public func tga_eventPlan7Day_Start(day: Int = 1) {
        
        MTEvent.default.thinkingAnalytics?.track("ds_event_7day_start", properties: [
            "ds_eparam_channel":  Adjust.attribution()?.trackerName ?? "Organic",
            "idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
            "ds_eparam_7day_detail": day,
        ])
        
    }
    
    
    
}











// TT Analysis Event
//extension MTEvent {
//    /// tga_eventSearchAccount
//    /// - Parameters:
//    ///   - searchResoult: 0:成功,1:未查询到用户名,2:其他异常
//    ///   - searchSource: initial，switch account
//    @objc
//
//    func tga_eventSearchAccount(searchResoult: Int, searchSource: String) {
//        MTEvent.default.thinkingAnalytics?.track("tta_event_search", properties: [
//
//            "tta_eparam_search_result": searchResoult,
//            "tta_eparam_search_source": searchSource,
//        ])
//    }
//
//    /// 登出事件
//    /// - Parameter userName: 登出用户名
//    @objc
//    public func tga_eventLogout(onlineDuration: Int) {
////        let timeInterval: TimeInterval = Date().timeIntervalSince1970
////        let timeStamp = Int(timeInterval)
////
////        let loginTime = UserDefaults.standard.integer(forKey: "loginTime_enterBackground")
////        let result = timeStamp - loginTime
//        MTEvent.default.thinkingAnalytics?.track("tta_event_logout", properties: [
//            "tta_eparam_logout_onlinetime": onlineDuration,
//        ])
//    }
//
//    /// profile show
//    ///
//    @objc
//    public func tga_eventProfileShow() {
//
//        MTEvent.default.thinkingAnalytics?.track("tta_event_profile_show")
//    }
//
//    /// profile item click
//    /// total_followers,likes,engagements,latest_video,hot_hashtag
//    @objc
//    public func tga_eventProfileItemClick(item: String) {
//
//        MTEvent.default.thinkingAnalytics?.track("tta_event_profileitem_click", properties: [
//            "tta_eparam_profileitem_name": item,
//
//        ])
//    }
//
//    /// tta_event_insights_show
//
//    @objc
//    public func tga_eventInsightsShow() {
//        MTEvent.default.thinkingAnalytics?.track("tta_event_insights_show")
//    }
//
//    /// tta_event_insightsitem_click
//    /// topbar,trending,posts_insights,hashtags_insights
//    @objc
//    public func tga_eventInsightsItemClick(item: String) {
//        MTEvent.default.thinkingAnalytics?.track("tta_event_insightsitem_click", properties: [
//            "tta_eparam_insightitem_name": item,
//        ])
//    }
//
//    /// tta_event_trendingitem_click
//    /// creators,videos,sounds
//    @objc
//    public func tga_eventTrendingItemClick(item: String) {
//        MTEvent.default.thinkingAnalytics?.track("tta_event_trendingitem_click", properties: [
//            "tta_eparam_trendingitem_name": item,
//        ])
//    }
//
//    /// tta_event_hashtagsearch
//    /// success，failed，notfound
//    @objc
//    public func tga_eventHashtagSearch(result: String) {
//        MTEvent.default.thinkingAnalytics?.track("tta_event_hashtagsearch", properties: [
//            "tta_eparam_hashtagsearch_result": result,
//        ])
//    }
//
//    /// tga_eventSetting_show
//    /// success，failed，notfound
//    @objc
//    public func tga_eventSettingShow() {
//        MTEvent.default.thinkingAnalytics?.track("tta_event_setting_show")
//    }
//
//    /// tta_event_settingitem_click
//    /// upgrade,switch_account,restore,rating,privacy
//    @objc
//    public func tga_eventSettingItemClick(item: String) {
//        MTEvent.default.thinkingAnalytics?.track("tta_event_settingitem_click", properties: [
//            "tta_eparam_settingitem_name": item,
//        ])
//    }
//
//    /// tta_event_purchase_page
//    /// account,engagement,topbar,posts_insights,hashtags_insights,upgradge
//
//    public func tga_eventEnterStorePage(source: String) {
//        MTEvent.default.thinkingAnalytics?.track("tta_event_purchase_page", properties: [
//            "tta_eparam_purchase_prepage": source,
//        ])
//    }
//
//    /// tta_event_purchase_page
//    /// com.xxx.30days etc
//    @objc
//    public func tga_eventPurchaseInit(iapItem: String, source: String) {
//        MTEvent.default.thinkingAnalytics?.track("tta_event_purchase_init", properties: [
//            "tta_eparam_purchase_iap": iapItem,
//            "tta_eparam_purchase_prepage": source,
//        ])
//    }
//
//    /// tta_event_purchase_finish
//    /// com.xxx.30days etc
//    /// 0:成功,1:未查询到用户名,2:其他异常
//    @objc
//    public func tga_eventStorePagePurchaseFinish(productId: String, source: String, result: Bool) {
//        let installDate = MTSystemHelper.default.installAppDate()?.timeIntervalSince1970 ?? 0
//
//        let timeStamp = Date().timeIntervalSince1970
//        let duration = Int(timeStamp) - Int(installDate)
//        MTEvent.default.thinkingAnalytics?.track("tta_event_purchase_finish", properties: [
//            "tta_eparam_purchase_iap": productId,
//            "tta_eparam_purchase_prepage": source,
//            "tta_eparam_purchase_result": result ? 0 : 1,
//            "tta_eparam_purchase_time_from_install": duration
//
//        ])
//    }
//
//
//
//    /// tta_event_tterror
//    /// com.xxx.30days etc
//    @objc
//    public func tga_eventTterror(tterror: String) {
//        MTEvent.default.thinkingAnalytics?.track("tta_event_tterror", properties: [
//            "tta_eparam_error": tterror,
//        ])
//    }
//
//    /// tta_event_tterror
//    /// com.xxx.30days etc
//    @objc
//    public func tga_eventSession() {
//        MTEvent.default.thinkingAnalytics?.track("tta_event_session")
//    }
//
//    /// tta_event_profileitem_leave
//    /// com.xxx.30days etc
//    @objc
//    public func tga_eventProfileitemLeave() {
//
//        let timeInterval: TimeInterval = Date().timeIntervalSince1970
//        let timeStamp = Int(timeInterval)
//
//        let loginTime = UserDefaults.standard.integer(forKey: "Duration_ProfileitemStartTime")
//        let duration = timeStamp - loginTime
//
//        MTEvent.default.thinkingAnalytics?.track("tta_event_profileitem_leave", properties: [
//            "tta_eparam_profileitem_duration": duration > 0 ? duration : 1
//        ])
//    }
//
//}


class MTEventParaManager: Codable  {
    
    enum ProfileItem: String {
        case totalFollowers = "totalFollowers"
        case likes = "likes"
        case engagements = "engagements"
        case latest_video = "latest_video"
        case hot_hashtag = "hot_hashtag"
    }
    // topbar,trending,posts_insights,hashtags_insights
    enum InsightItem: String {
        case topbar = "topbar"
        case trending = "trending"
        case posts_insights = "posts_insights"
        case hashtags_insights = "hashtags_insights"
        
    }
    
    // creators,videos,sounds
    enum TrendingItem: String {
        case creators = "creators"
        case videos = "videos"
        case sounds = "sounds"
        
    }
    
    // upgrade,switch_account,restore,rating,privacy
    enum SettingItem: String {
        case upgrade = "upgrade"
        case switch_account = "switch_account"
        case restore = "restore"
        case feedback = "feedback"
        case privacy = "privacy"
        case terms = "terms"
    }
    // account,engagement,topbar,posts_insights,hashtags_insights,upgradge
    enum EnterSubscripitonType: String {
        case account = "account"
        case engagement = "engagement"
        case topbar = "topbar"
        case posts_insights = "posts_insights"
        case hashtags_insights = "hashtags_insights"
        case upgradge = "upgradge"
    }
    enum HashTagSearchResultType: String {
        case success = "success"
        case failed = "failed"
        case notFound = "notfound"
    }
    
    
    static let `default` = MTEventParaManager()
    var searchSource: String = "initial"
    var searchResult: Int = 0 // 0:成功,1:未查询到用户名,2:账户需要升级,3:其他异常
    var beconeActiveTime: TimeInterval = 0
}


extension Defaults.Keys {
    
    static let isFirstOpenSession = Key<Bool?>("Event.isFirstOpenSession")
    static let isFirstInstallAdjustEvent = Key<Bool?>("Event.isFirstInstallAdjustEvent")
    
}


