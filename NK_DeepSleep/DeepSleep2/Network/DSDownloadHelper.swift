//
/*******************************************************************************
    Copyright © 2020 WhiteNoise. All rights reserved.

    File name:     DSDownloadHelper.swift
    Author:        Adrian

    Project name:  DeepSleep2

    Description:
    

    History:
            2020/7/10: File created.

********************************************************************************/
    

import UIKit
import Tiercel

public class DSDownloadHelper: NSObject {

    static let `default` = DSDownloadHelper()
    //fileprivate
    var sessionManager: SessionManager = {
        var configuration = SessionConfiguration()
        configuration.allowsCellularAccess = true
        configuration.maxConcurrentTasksLimit = Int.max
        let path = Cache.defaultDiskCachePathClosure("DeepSleepSounds")
        let cacahe = Cache("DeepSleepSounds", downloadPath: path)
        let manager = SessionManager("DeepSleepSounds", configuration: configuration, cache: cacahe, operationQueue: DispatchQueue(label: "com.deepsleep2.SessionManager.operationQueue"))
        return manager
    }()
    
    /// 设置下载队列最大数，默认为Int.max
    /// - Parameter limit: 最大下载队列数， 默认为 Int.max
    public func setTaskQueueLimit(_ limit: Int = Int.max) {
        sessionManager.configuration.maxConcurrentTasksLimit = limit
    }
    
    /// 设置是否允许蜂窝网络下载
    /// - Parameter status: Bool
    public func setDownloadCanByCellular(_ status: Bool = true) {
        sessionManager.configuration.allowsCellularAccess = status
    }
    
    /// 清理本地下载缓存
    public func clearAllLocalDiskDatas() {
        sessionManager.cache.clearDiskCache()
    }
    
    /// 清理本地下载缓存
    /// - Parameter url: 下载地址
    public func clearLocalDiskData(_ url: String) {
        guard let targetTask = sessionManager.fetchTask(url) else { return }
        do {
            try FileManager.default.removeItem(atPath: targetTask.filePath)
        } catch {
            debugPrint("Download: remove download file failed.(\(targetTask.filePath)")
        }
    }
    
    /// 下载
    /// - Parameters:
    ///   - url: 资源链接
    ///   - completion: 回调
    public func downloadTask(url: String, fileName: String?, completion: ((DownloadTask?) -> Void)?) {
        
        sessionManager.download(url, fileName: fileName) { (task) in
            debugPrint("Download: current download local path - \(task.filePath)")
            completion?(task)
        }
    }
    
    /// 移除下载
    /// - Parameter url: 资源链接
    public func removeDownloadTask(url: String) {
        let count = sessionManager.tasks.count
        guard count > 0 else { return }
        guard let targetTask = sessionManager.fetchTask(url) else { return }
        sessionManager.remove(targetTask, completely: false) { (task) in
            debugPrint("Download: current deleted download local path - \(task.filePath)")
        }
    }
    
    /// 移除所有下载
    /// - Parameter completion: 回调
    public func removeAllTasks(_ completion: (() -> Void)? = nil) {
        sessionManager.totalRemove(completely: false) { _ in
            completion?()
        }
    }
    
    /// 暂停下载
    /// - Parameters:
    ///   - url: 资源链接
    ///   - completion: 回调
    public func pauseDownload(_ url: String, _ completion: (() -> Void)? = nil) {
        guard let targetTask = sessionManager.fetchTask(url) else { return }
        sessionManager.suspend(targetTask) { _ in
            completion?()
        }
    }
    
    /// 暂停所有下载
    /// - Parameter completion: 回调
    public func pauseAllDownloadTasks(_ completion: (() -> Void)? = nil) {
        sessionManager.totalSuspend() { _ in
            completion?()
        }
    }
    
    /// 取消下载
    /// - Parameters:
    ///   - url: 资源链接
    ///   - completion: 回调
    public func cancelDownload(_ url: String, _ completion: (() -> Void)? = nil) {
        guard let targetTask = sessionManager.fetchTask(url) else { return }
        sessionManager.cancel(targetTask) { _ in
            completion?()
        }
    }
    
    /// 取消所有下载
    /// - Parameter completion: 回调
    public func cancelAllDownloadTasks(_ completion: (() -> Void)? = nil) {
        sessionManager.totalCancel { _ in
            completion?()
        }
    }
    
    /// 开始下载（重新开始）
    /// - Parameters:
    ///   - url: 资源链接
    ///   - completion: 回调
    public func startDownload(_ url: String, _ completion: (() -> Void)? = nil) {
        guard let targetTask = sessionManager.fetchTask(url) else { return }
        sessionManager.start(targetTask) { _ in
            completion?()
        }
    }
    
    /// 开始全部下载（重新开始）
    /// - Parameter completion: 回调
    public func startAllDownloadTasks(_ completion: (() -> Void)? = nil) {
        sessionManager.totalStart { _ in
            completion?()
        }
    }
    
    /// 获取下载任务
    /// - Parameter url: 资源链接
    /// - Returns: 回调
    public func getDownloadTask(url: String) -> DownloadTask? {
        guard let targetTask = sessionManager.fetchTask(url) else { return nil }
        return targetTask
    }
    
    /// 获取下载进度
    /// - Parameter url: 资源链接
    /// - Returns: 回调
    public func getDownloadTaskProgress(url: String) -> Double {
        guard let targetTask = sessionManager.fetchTask(url) else { return 0.0 }
        return targetTask.progress.fractionCompleted
    }
    
    /// 监听下载进度
    /// - Parameters:
    ///   - url: 资源链接
    ///   - progress: 进度
    ///   - success: 成功
    ///   - failure: 失败
    public func taskProgressObserver(url: String, progress: ((Double) -> Void)?, success: ((String) -> Void)?, failure: ((Status) -> Void)?) {
        guard let targetTask = sessionManager.fetchTask(url) else { return }
        targetTask.progress { (task) in
            debugPrint("Download: task - (\(task.url.absoluteString)), progress \(task.progress.fractionCompleted)")
            progress?(task.progress.fractionCompleted)
        }
        .success {  (task) in
            // 下载任务成功了
            debugPrint("Download: task - (\(task.url.absoluteString)), localPath \(task.filePath)")
            success?(task.filePath)
        }
        .failure { (task) in
            switch task.status {
            
            case .waiting:
                debugPrint("waiting")
            case .running:
                debugPrint("running")
            case .suspended:
                debugPrint("suspended")
            case .canceled:
                debugPrint("canceled")
            case .failed:
                debugPrint("failed")
            case .removed:
                debugPrint("removed")
            case .succeeded:
                debugPrint("succeeded")
            case .willSuspend:
                debugPrint("willSuspend")
            case .willCancel:
                debugPrint("willCancel")
            case .willRemove:
                debugPrint("willRemove")
            }
            failure?(task.status)
        }
    }
    
}


extension DSMeidaLocalCheckManager {
    static func checkBgVideoLocalUrl(planItem: SevenPlanItem, completion: @escaping ((URL?)->Void), progressBlock: @escaping ((Double)->Void), beginDownloadBlock: @escaping (()->Void)) -> URL? {
        let type = planItem.bg_video_url?.suffix(3) ?? "mp4"
        let fileName = "plan7_\(planItem.day ?? 1).\(type)"
        let path = DSDownloadHelper.default.sessionManager.cache.downloadFilePath.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: path) {
            return URL.init(fileURLWithPath: path)
        } else {
            
            if !isNetworkConnect {
                completion(nil)
                return nil
            }
            if let videoUrl = planItem.bg_video_url {
                beginDownloadBlock()
                DSDownloadHelper.default.downloadTask(url: videoUrl, fileName: fileName) { task in
                    
                    debugPrint("download filePath = \(String(describing: task?.filePath))")
                    debugPrint("download fileName = \(String(describing: task?.fileName))")
                    
                }
                
                DSDownloadHelper.default.taskProgressObserver(url: videoUrl, progress: {  (progressValue) in
                    
                    
                    debugPrint("progress value: \(progressValue)")
                    debugPrint("*** DSDownloadHelper.default.taskProgressObserver \(progressValue)")
                    progressBlock(progressValue)
                }, success: { (successString) in
                    completion(URL.init(fileURLWithPath: successString))
                }) { (status) in
                    
                }
                
                
            }
            return nil
        }
    }
}

class DSMeidaLocalCheckManager: NSObject {
    static func checkLocalUrl(music: MusicItem,  completion: @escaping ((URL?)->Void), progressBlock: @escaping ((Double)->Void), beginDownloadBlock: @escaping (()->Void)) -> URL? {
        
        
        if let buildinName = DSBuildinManager.default.buildinResourceName(remoteName: music.media_url)  {
            // local music
            if let path = Bundle.main.path(forResource: buildinName, ofType: nil) {
                let mediaURL = URL.init(fileURLWithPath: path)
                return mediaURL
            }
            
        }
        
        
        let type = music.media_url?.suffix(3) ?? "mp3"
        let fileName = "\(music.name ?? "1").\(type)"
        let path = DSDownloadHelper.default.sessionManager.cache.downloadFilePath.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: path) {
            return URL.init(fileURLWithPath: path)
        } else {
            
            if !isNetworkConnect {
                completion(nil)
                return nil
            }
            if let musicUrl = music.media_url {
                beginDownloadBlock()
                DSDownloadHelper.default.downloadTask(url: musicUrl, fileName: fileName) { task in
                    
                    debugPrint("download filePath = \(String(describing: task?.filePath))")
                    debugPrint("download fileName = \(String(describing: task?.fileName))")
                    
                }
                
                DSDownloadHelper.default.taskProgressObserver(url: musicUrl, progress: {  (progressValue) in
                    
//                    guard let `self` = self else {return}
                    debugPrint("progress value: \(progressValue)")
                    debugPrint("*** DSDownloadHelper.default.taskProgressObserver \(progressValue)")
                    progressBlock(progressValue)
                }, success: { (successString) in
                    completion(URL.init(fileURLWithPath: successString))
                }) { (status) in
                    
                }
                
//                DSDownloadHelper.default.taskProgressObserver(url: musicUrl, progress: progressValue, success: { (success) in
//
//                }) { (errorStatus) in
//
//                }
                
                
                
            }
            return nil
        }
    }
}




