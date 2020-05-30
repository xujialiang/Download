//
//  DownloadManager.swift
//  Download
//
//  Created by 张书孟 on 2018/10/10.
//  Copyright © 2018年 zsm. All rights reserved.
//

import UIKit

// 创建一个信号量，初始值为0
// App杀进程时，需要取消任务，保存进度。取消任务是异步方法，所以需要信号量，将异步转为同步
let semaphoreSignal = DispatchSemaphore(value: 0)

internal class DownloadManager: NSObject {

    internal static let `default` = DownloadManager()
    
    internal var backgroundSessionCompletionHandler: (() -> Void)?
    
    // 后台下载session，一个App只要维护一个session即可
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "DownloadBackgroundSessionIdentifier")
//        let configuration = URLSessionConfiguration.default
        configuration.sessionSendsLaunchEvents = true
        // 设置以下参数，会导致在真机上无法下载，由系统决定
//        configuration.isDiscretionary = true
        configuration.timeoutIntervalForRequest = .infinity
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
        return session
    }()
    
    private var sessionModels: [String: XDownloadModel] = [String: XDownloadModel]()
    
    private var tasks: [String: URLSessionDownloadTask] = [String: URLSessionDownloadTask]()
    
}

internal extension DownloadManager {
    
    /// 开启下载
    func download(model: XDownloadModel) {
        guard let url = model.model.url, url.dw_isURL else { debugPrint("下载链接错误"); return }
        // 如果没有设置UID，使用url的md5作为UID
        // 如果设置了UID，则以设置的UID为准
        
        if(model.model.uid != nil) {
            debugPrint("已设置UID,使用设置的UID")
        }else {
            debugPrint("未设置UID,使用URL的MD5作为UID")
            let uuid: String! = url.dw_MD5String
            model.model.uid = uuid
        }
        
        guard let uid = model.model.uid else {
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
                sessionModels["\(task.taskIdentifier)"] = model
                task.resume()
                // 保存任务
                tasks[uid] = task
                model.states = .waiting
                
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
            request.setValue("bytes=\(getDownloadSize(uid: uid))-", forHTTPHeaderField: "Range")
            // 创建一个Data任务
            let task = session.downloadTask(with: request)
            // sessionModels 必须使用taskIdentifier
            // 因为在URLSessionTaskDelegate的回调中，返回的是task，要想找到task对应的model，只能用taskIdentifier作为key
            sessionModels["\(task.taskIdentifier)"] = model
            task.resume()
            debugPrint("taskIdentifier", task.taskIdentifier)
            // 保存任务
            tasks[uid] = task
            model.states = .waiting
            
            save(uid: uid)
            start(uid: uid)
        }
    }
    
    /// 根据url取消/暂停任务
    internal func cancelTask(uid: String) {
//        guard url.dw_isURL else { return }
        if let task = getTask(uid: uid) {
            debugPrint("暂停任务", uid)
            task.suspend()
            task.cancel(byProducingResumeData: { data in
                debugPrint("取消下载", uid)
                if let model = self.getSessionModel(taskIdentifier: task.taskIdentifier) {
                    do {
                        model.model.resumeDataPath = self.path(uid: model.model.uid!) + ".tmp"
                        try data?.write(to: URL(fileURLWithPath: model.model.resumeDataPath!))
                        model.states = .suspended
                    }catch {
                        debugPrint("缓存出错", error)
                    }
                    self.sessionModels.removeValue(forKey: "\(task.taskIdentifier)")
                    self.tasks.removeValue(forKey: uid)
                }
                self.waitingTask()
                semaphoreSignal.signal()
            });
            semaphoreSignal.wait()
        }
    }
    
    /// 取消/暂停所有任务
    func cancelAllTask() {
        for (_, sessionModel) in sessionModels.values.enumerated() {
            if let uid = sessionModel.model.uid {
                cancelTask(uid: uid)
            }
        }
        sessionModels.removeAll()
        tasks.removeAll()
    }
    
    /// 根据url删除资源
    func deleteFile(uid: String) {
        cancelTask(uid: uid)
        XDownloadModel.delete(uid: uid)
        do {
            try FileManager.default.removeItem(atPath: DownloadCachePath + uid)
        } catch {}
        
        let uidArr: NSMutableArray = NSMutableArray(contentsOfFile: DownloadCacheURLPath) ?? NSMutableArray()
        guard (uidArr.contains(uid)) else { return }
        uidArr.remove(uid)
        uidArr.write(toFile: DownloadCacheURLPath, atomically: true)
    }
    
    /// 清空所有下载资源
    func deleteAllFile() {
        // 取消所有任务
        cancelAllTask()
        do {
            try FileManager.default.removeItem(atPath: DownloadHomeDirectory)
        } catch {}
    }
    
    /// 将未完成的下载状态改为.suspended
    func updateDownloadingStateWithSuspended() {
        XDownloadModel.updateDownloadingStateWithSuspended()
    }
    
    /// 开启未完成的下载
    func updateDownloading() {
        for model in XDownloadModel.getDownloadingModel() {
            if model.model.state != .start, model.model.state != .waiting {
                DownloadManager.default.download(model: model)
            }
        }
    }
}

internal extension DownloadManager {
    /// 根据url获得对应的下载任务
    func getTask(uid: String) -> URLSessionDownloadTask? {
//        guard url.dw_isURL else { return nil }
        return tasks[uid]
    }
    
    /// 获取对应的下载信息模型
    func getSessionModel(taskIdentifier: Int) -> XDownloadModel? {
        return sessionModels["\(taskIdentifier)"]
    }
    
    func waitingTask() {
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
    
    func handle(uid: String) {
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
    func start(uid: String) {
//        guard url.dw_isURL else { return }
        if let task = getTask(uid: uid) {
            
            let runningModels = sessionModels.filter { (key, value) -> Bool in
                return value.states == .start
            }
            
            if let model = getSessionModel(taskIdentifier: task.taskIdentifier) {
                if runningModels.count < MaxDownloadQueue {
                    model.states = .start
                    task.resume()
                } else {
                    model.states = .waiting
                }
            }
        }
    }
}

extension DownloadManager: URLSessionDelegate {
    /// 应用处于后台，所有下载任务完成及URLSession协议调用之后调用
    internal func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let handler = self.backgroundSessionCompletionHandler {
                debugPrint("backgroundSessionCompletionHandler")
                handler()
            }
        }
    }
}

extension DownloadManager: URLSessionTaskDelegate {
    internal func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
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
            if error?.localizedDescription == "cancelled" {
                debugPrint("下载取消", model.failedReason)
                model.states = .suspended
            } else {
                debugPrint("下载失败", model.failedReason)
                model.states = .failed
            }
            
        }
        
        // 清除任务
        tasks.removeValue(forKey: uid)
        sessionModels.removeValue(forKey: "\(task.taskIdentifier)")
        waitingTask()
    }
}

extension DownloadManager: URLSessionDownloadDelegate {
    
    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
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
            XDownloadModel.save(uid: uid, descModel: model.model)
            
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
    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
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
            let _ = model.model.url else { downloadTask.suspend(); return }
        
        let receivedSize = totalBytesWritten
        let expectedSize = totalBytesExpectedToWrite
        let progress: Double = Double(receivedSize) / Double(expectedSize)
        
        model.model.totalLength = expectedSize
        model.model.progress = progress
        model.model.receivedSize = totalBytesWritten
        XDownloadModel.save(uid: uid, descModel: model.model)
    }
}
