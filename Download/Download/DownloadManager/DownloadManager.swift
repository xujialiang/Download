//
//  DownloadManager.swift
//  Download
//
//  Created by 张书孟 on 2018/10/10.
//  Copyright © 2018年 zsm. All rights reserved.
//

import UIKit

enum DownloadState: Int, Codable {
    case `default` /// 默认
    case start /// 下载中
    case waiting /// 等待
    case suspended /// 下载暂停
    case completed /// 下载完成
    case failed /// 下载失败
}

/// 缓存主目录
let DownloadHomeDirectory = NSHomeDirectory() + "/Library/Caches/DownloadCache/"
/// 下载文件的路径
let DownloadCachePath = DownloadHomeDirectory + "DownloadCache/"
/// 保存下载的url路径(取模型用)
let DownloadCacheURLPath = DownloadHomeDirectory + "URL.plist"
/// 保存下载文件的model路径
let DownloadCacheModelPath = "DownloadCache/DownloadModelCache"

class DownloadManager: NSObject {

    public static let `default` = DownloadManager()
    
    public var backgroundSessionCompletionHandler: (() -> Void)?
    
    public var maxDownloadCount: Int = 3 /// 最大并发数
    
    public lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "DownloadBackgroundSessionIdentifier")
//        let configuration = URLSessionConfiguration.default
        configuration.sessionSendsLaunchEvents = true
        configuration.isDiscretionary = true
        configuration.timeoutIntervalForRequest = .infinity
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    private var sessionModels: [String: DownloadModel] = [String: DownloadModel]()
    
    private var tasks: [String: URLSessionDownloadTask] = [String: URLSessionDownloadTask]()
    
}

// MARK: public
extension DownloadManager {
    
    /// 开启下载
    public func download(model: DownloadModel) {
        guard let url = model.model.url, url.dw_isURL else { debugPrint("下载链接错误"); return }
        // 如果没有设置UID，使用url的md5作为UID
        // 如果设置了UID，则以设置的UID为准
        var uuid: String! = url.dw_MD5String
        if(model.model.uid != nil) {
            uuid = model.model.uid!
        }else {
            debugPrint("未设置UID,使用URL的MD5作为UID")
        }
        guard let uid = uuid else {
            // 理论上永远不会走到这里
            debugPrint("UID为空")
            return
        }
        
        debugPrint("url && uid", url, uid)
        
        // 如果存在文件，并且是已经下载完的，则直接返回。
        if isExistence(uid: uid), isCompletion(uid: uid) {
            debugPrint("文件已下载完成，无需重复下载")
            return
        }
        
        // 如果存在这个下载任务，不重复创建任务
        if let _ = tasks[uid] {
            debugPrint("已存在的下载任务，进一步处理")
            handle(uid: uid)
            return
        }
        
        // 如果该任务存在临时文件
        if isExistenceTmp(uid: uid) {
            // 创建一个Data任务
            let tmpFilePath = self.path(uid: uid) + ".tmp"
            debugPrint("存在缓存文件", tmpFilePath)
            do {
                
                let resumeData = try Data.init(contentsOf: URL(fileURLWithPath: tmpFilePath))
                let task = session.downloadTask(withResumeData: resumeData)
                // 保存任务
                tasks[uid] = task
                model.states = .waiting
                sessionModels["\(task.taskIdentifier)"] = model
                save(uid: uid)
                start(uid: uid)
            }catch{}
        }else{
            debugPrint("不存在缓存文件, 发起一个新请求，从头开始下载")
            // 创建请求
            var request = URLRequest(url: URL(string: url)!)
            // 忽略本地缓存，代理服务器以及其他中介，直接请求源服务端
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            // 设置请求头
//            request.setValue("bytes=\(getDownloadSize(uid: uid))-", forHTTPHeaderField: "Range")
            // 创建一个Data任务
            let task = session.downloadTask(with: request)
            debugPrint("taskIdentifier", task.taskIdentifier)
            // 保存任务
            tasks[uid] = task
            model.states = .waiting
            // sessionModels 必须使用taskIdentifier
            // 因为在URLSessionTaskDelegate的回调中，返回的是task，要想找到task对应的model，只能用taskIdentifier作为key
            sessionModels["\(task.taskIdentifier)"] = model
            save(uid: uid)
            start(uid: uid)
        }
    }
    
    /// 判断该文件是否下载完成
    public func isCompletion(uid: String) -> Bool {
//        guard url.dw_isURL else { return false }
        if let model = DownloadModel().getDownloadModel(uid: uid),
            model.totalLength == getDownloadSize(uid: uid) {
            return true
        }
        return false
    }
    
    /// 判断该文件是否存在
    public func isExistence(uid: String) -> Bool {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: DownloadCachePath)
            return files.contains(uid)
        } catch {
            return false
        }
    }
    
    /// 判断该文件是否存在
    public func isExistenceTmp(uid: String) -> Bool {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: DownloadCachePath)
            return files.contains(uid + ".tmp")
        } catch {
            return false
        }
    }
    
    /// 根据url取消/暂停任务
    public func cancelTask(uid: String) {
//        guard url.dw_isURL else { return }
        if let task = getTask(uid: uid) {
            task.suspend()
            task.cancel(byProducingResumeData: { data in
                if let model = self.getSessionModel(taskIdentifier: task.taskIdentifier) {
                    model.states = .suspended
                    model.model.resumeDataPath = self.path(uid: model.model.uid!) + ".tmp"
                    do {
                        try data?.write(to: URL(fileURLWithPath: model.model.resumeDataPath!))
                    }catch {}
                    self.sessionModels.removeValue(forKey: "\(task.taskIdentifier)")
                    self.tasks.removeValue(forKey: uid)
                }
                self.waitingTask()
            });
        }
    }
    
    /// 取消/暂停所有任务
    public func cancelAllTask() {
        for (_, task) in tasks.values.enumerated() {
            task.suspend()
            task.cancel()
        }
        tasks.removeAll()
        for (_, sessionModel) in sessionModels.values.enumerated() {
            sessionModel.states = .suspended
        }
        sessionModels.removeAll()
    }
    
    /// 根据url删除资源
    public func deleteFile(uid: String) {
//        guard url.dw_isURL else { return }
        cancelTask(uid: uid)
        DownloadModel().delete(uid: uid)
        do {
            try FileManager.default.removeItem(atPath: DownloadCachePath + uid)
        } catch {}
        
        let uidArr: NSMutableArray = NSMutableArray(contentsOfFile: DownloadCacheURLPath) ?? NSMutableArray()
        guard (uidArr.contains(uid)) else { return }
        uidArr.remove(uid)
        uidArr.write(toFile: DownloadCacheURLPath, atomically: true)
    }
    
    /// 清空所有下载资源
    public func deleteAllFile() {
        // 取消所有任务
        cancelAllTask()
        
        do {
            try FileManager.default.removeItem(atPath: DownloadHomeDirectory)
        } catch {}
    }
    
    /// 获取下载的数据
    public func getDownloadModels() -> [DownloadModel] {
        let uids: NSMutableArray = NSMutableArray(contentsOfFile: DownloadCacheURLPath) ?? NSMutableArray()
        var models = [DownloadModel]()
        for uid in uids {
            if let uid2 = uid as? String {
                let downloadModel = DownloadModel()
                if let model = downloadModel.getDownloadModel(uid: uid2) {
                    downloadModel.model = model
                    models.append(downloadModel)
                }
            }
        }
        return models
    }
    
    /// 获取下载完成的数据
    public func getDownloadFinishModels() -> [DownloadModel] {
        let models = getDownloadModels().filter {
            return $0.model.state == .completed
        }
        return models
    }
    
    /// 获取未下载完成的数据
    public func getDownloadingModel() -> [DownloadModel] {
        let models = getDownloadModels().filter {
            return $0.model.state != .completed && $0.model.state != .failed
        }
        return models
    }
    
    /// 将未完成的下载状态改为.suspended
    public func updateDownloadingStateWithSuspended() {
        for model in getDownloadingModel() {
            if let uid = model.model.uid {
                model.model.state = .suspended
                DownloadModel().save(uid: uid, descModel: model.model)
            }
        }
    }
    
    /// 开启未完成的下载
    public func updateDownloading() {
        for model in getDownloadingModel() {
            if model.model.state != .start, model.model.state != .waiting {
                DownloadManager.default.download(model: model)
            }
        }
    }
    
    /// 获取下载完成的文件路径
    public func getFile(uid: String) -> String {
        guard isExistence(uid: uid), isCompletion(uid: uid) else { return "" }
        return DownloadCachePath + uid
    }
    
    /// 获取总缓存大小 单位：字节
    public func getCacheSize() -> Double {
        return DownloadHomeDirectory.dw_getCacheSize
    }
}

extension DownloadManager {
    /// 根据url获得对应的下载任务
    private func getTask(uid: String) -> URLSessionDownloadTask? {
//        guard url.dw_isURL else { return nil }
        return tasks[uid]
    }
    
    /// 获取对应的下载信息模型
    private func getSessionModel(taskIdentifier: Int) -> DownloadModel? {
        return sessionModels["\(taskIdentifier)"]
    }
    
    private func waitingTask() {
        debugPrint("waitingTask 继续下一个任务")
        let waitingModel = sessionModels.filter { (key, value) -> Bool in
            return value.states == .waiting
        }
        if let sessionModel = waitingModel.first {
            let model = sessionModel.value
            if let uid = model.model.uid {
                start(uid: uid)
            }
        }
    }
    
    private func handle(uid: String) {
//        guard url.dw_isURL else { return }
        if let task = getTask(uid: uid) {
            if task.state == .running {
                debugPrint("取消下载")
                cancelTask(uid: uid)
            } else {
                if let model = getSessionModel(taskIdentifier: task.taskIdentifier), model.states == .waiting {
                    debugPrint("暂停任务")
                    model.states = .suspended
                } else {
                    debugPrint("开始任务")
                    start(uid: uid)
                }
            }
        }
    }
    
    /// 开始下载
    private func start(uid: String) {
//        guard url.dw_isURL else { return }
        if let task = getTask(uid: uid) {
            
            let runningModels = sessionModels.filter { (key, value) -> Bool in
                return value.states == .start
            }
            
            if let model = getSessionModel(taskIdentifier: task.taskIdentifier) {
                if runningModels.count < maxDownloadCount {
                    model.states = .start
                    task.resume()
                } else {
                    model.states = .waiting
                }
            }
        }
    }
    
    /// 创建缓存路径
    private func path(uid: String) -> String {
//        guard url.dw_isURL else { return DownloadCachePath }
        do {
            try FileManager.default.createDirectory(atPath: DownloadCachePath, withIntermediateDirectories: true, attributes: nil)
            return DownloadCachePath + uid
        } catch {
            return DownloadCachePath
        }
    }
    
    /// 保存下载的url(取 model 用)
    private func save(uid: String) {
//        guard url.dw_isURL else { return }
        let uidArr: NSMutableArray = NSMutableArray(contentsOfFile: DownloadCacheURLPath) ?? NSMutableArray()
        guard !(uidArr.contains(uid)) else { return }
        uidArr.add(uid)
        uidArr.write(toFile: DownloadCacheURLPath, atomically: true)
    }
    
    /// 获取已下载文件的大小
    private func getDownloadSize(uid: String) -> Int {
//        guard url.dw_isURL else { return 0 }
        do {
            if let size = try FileManager.default.attributesOfItem(atPath: path(uid: uid) + ".tmp")[FileAttributeKey.size] as? Int {
                return size
            } else {
                return 0
            }
        } catch {
            return 0
        }
    }
}

extension DownloadManager: URLSessionDelegate {
    /// 应用处于后台，所有下载任务完成及URLSession协议调用之后调用
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let handler = self.backgroundSessionCompletionHandler {
                debugPrint("backgroundSessionCompletionHandler")
                handler()
            }
        }
    }
}

extension DownloadManager: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        guard let model = sessionModels["\(task.taskIdentifier)"],
            let url = model.model.url,
            let uid = model.model.uid,
            url.dw_isURL else { return }
        
        var hasError = false
        if error != nil {
            model.failedReason = error!.localizedDescription
            hasError = true
        }
        if let response = task.response as? HTTPURLResponse {
            let status = response.statusCode
            if status != 200 && status != 206 {
                model.failedReason = "\(status)"
                hasError = true
            }
        }
        
        if !hasError {
            debugPrint("下载完成")
            model.states = .completed
        }else {
            debugPrint("下载失败", model.failedReason)
            model.states = .failed
        }
        
        // 清除任务
        tasks.removeValue(forKey: uid)
        sessionModels.removeValue(forKey: "\(task.taskIdentifier)")
        waitingTask()
    }
}

extension DownloadManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("下载结束")
        guard let response = downloadTask.response as? HTTPURLResponse else {
            return //something went wrong
        }

        let status = response.statusCode
//        let completeHeader = response.allHeaderFields
        if(status != 200 && status != 206) {
            debugPrint("下载错误")
        }else {
            // 移动文件到指定目录
            debugPrint("开始移动文件")
            guard let model = sessionModels["\(downloadTask.taskIdentifier)"],
                let uid = model.model.uid,
            let url = model.model.url else { return }
            
            model.model.progress = 1.0
            model.model.receivedSize = model.model.totalLength
            model.save(uid: uid, descModel: model.model)
            
            let toUrl = DownloadCachePath + uid + url.dw_pathExtension
            let destUrl = URL(fileURLWithPath: toUrl)
            do {
                let isExist = FileManager.default.fileExists(atPath: toUrl)
                if isExist {
                    debugPrint("已存在文件，执行删除")
                    try FileManager.default.removeItem(at: destUrl)
                }
                // 创建目录
                let _ = self.path(uid: "")
                try FileManager.default.copyItem(at: location, to: destUrl)
                debugPrint("copy文件到", destUrl)
            } catch {
                debugPrint("出错啦", error)
            }
        }
    }
    // 下载代理方法，监听下载进度
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let response = downloadTask.response as? HTTPURLResponse else {
            return //something went wrong
        }
        debugPrint("response status code, %@", response.statusCode, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
        let status = response.statusCode
        if(status != 200 && status != 206) {
            return
        }
//        debugPrint("response, %@", response)
        
        guard let model = sessionModels["\(downloadTask.taskIdentifier)"],
            let uid = model.model.uid,
        let _ = model.model.url else { return }
        
        let receivedSize = totalBytesWritten
        let expectedSize = totalBytesExpectedToWrite
        let progress: Double = Double(receivedSize) / Double(expectedSize)
        
        model.model.totalLength = expectedSize
        model.model.progress = progress
        model.model.receivedSize = totalBytesWritten
        model.save(uid: uid, descModel: model.model)
    }
    
    // 下载代理方法，下载偏移
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("下载偏移")
        // 下载偏移，主要用于暂停续传
    }
}
