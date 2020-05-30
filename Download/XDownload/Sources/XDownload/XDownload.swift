//
//  XDownload.swift
//  XDownload
//
//  Created by 徐佳良 on 2020/5/30.
//  Copyright © 2020年 elliott. All rights reserved.
//

import UIKit

/// 进度通知
public let DownloadProgressNotification: Notification.Name = Notification.Name("DownloadProgressNotification")
// 下载状态通知
public let DownloadStatusNotification: Notification.Name = Notification.Name("DownloadStatusNotification")

public class XDownload: NSObject {

    public static let `default` = XDownload()
    
    public var backgroundSessionCompletionHandler: (() -> Void)? {
        didSet {
            DownloadManager.default.backgroundSessionCompletionHandler = backgroundSessionCompletionHandler
        }
    }

}

public extension XDownload {
    /// 获取已经下载完的数据
    func getDownloadFinishModels () -> [XDownloadModel] {
        return XDownloadModel.getDownloadFinishModels()
    }
    
    /// 获取已经下载中的数据
    func getDownloadingModel () -> [XDownloadModel] {
        return XDownloadModel.getDownloadingModel()
    }
    
    /// 获取所有的下载数据
    func getDownloadModels () -> [XDownloadModel] {
        return XDownloadModel.getDownloadModels()
    }
    
    /// 获取文件
    func getFile(uid: String) -> String {
        return DownloadManager.default.getFile(uid: uid)
    }
    
    /// 删除文件
    func deleteFile(uid: String) {
        DownloadManager.default.deleteFile(uid: uid)
    }
    
    /// 删除所有文件
    func deleteAllFile() {
        DownloadManager.default.deleteAllFile()
    }
    
    /// 开启未完成的下载
    func updateDownloading() {
        DownloadManager.default.updateDownloading()
    }
    
    /// 将未完成的下载状态改为.suspended
    func updateDownloadingStateWithSuspended () {
        return XDownloadModel.updateDownloadingStateWithSuspended()
    }
    
    /// 取消所有任务
    func cancelAllTask() {
        DownloadManager.default.cancelAllTask()
    }
    
    /// 创建一个下载任务
    func download(model: XDownloadModel) {
        DownloadManager.default.download(model: model)
    }
    
    func getDownloadModel(uid: String) -> XDownloadDescModel? {
        return XDownloadModel.getDownloadModel(uid: uid)
    }
}
