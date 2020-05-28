//
//  DownloadModel.swift
//  Download
//
//  Created by 张书孟 on 2018/10/9.
//  Copyright © 2018年 zsm. All rights reserved.
//

import UIKit

/// 进度通知
public let DownloadProgressNotification: Notification.Name = Notification.Name("DownloadProgressNotification")
// 下载状态通知
public let DownloadStatusNotification: Notification.Name = Notification.Name("DownloadStatusNotification")

public class DownloadModel: NSObject {
    
    public var states: DownloadState = .default {
        didSet {
            model.state = states
            if let uid = model.uid {
                if let proModel = getDownloadModel(uid: uid) {
                    model.progress = proModel.progress
                }
                save(uid: uid, descModel: model)
            }
        }
    }
    
    public var failedReason: String = "" {
        didSet {
            model.failedReason = failedReason
            if let uid = model.uid {
                save(uid: uid, descModel: model)
            }
        }
    }
    
    public var model: DownloadDescModel = DownloadDescModel()
    
    public func getDownloadModel(uid: String) -> DownloadDescModel? {
        return DownloadCache<DownloadDescModel>().object(forKey: uid)
    }
    
    public func save(uid: String, descModel: DownloadDescModel) {
        DownloadCache<DownloadDescModel>().setObject(object: descModel, forKey: uid)
    }
    
    public func delete(uid: String) {
        DownloadCache<DownloadDescModel>().removeObiect(forKey: uid)
    }
}

public class DownloadDescModel: Codable {
    
    /** 必须有的属性 -- 开始 */
    public var uid: String? /// 资源ID，资源唯一标识，UID不同，即使URL相同，也认为是两个资源
    public var url: String? /// 下载地址
    
    public var resumeDataPath: String? /// 恢复下载时的文件路径
    
    public var totalLength: Int64 = 0 /// 获得服务器这次请求 返回数据的总长度
    public var receivedSize: Int64 = 0 /// 已经下载的长度
    
    /// 下载进度
    public var progress: Double = 0.0 {
        didSet {
            NotificationCenter.default.post(name: DownloadProgressNotification, object: self)
        }
    }
    
    public var state: DownloadState = .default {
        didSet {
            NotificationCenter.default.post(name: DownloadStatusNotification, object: self)
        }
    }
    public var failedReason: String?
    /** 必须有的属性 -- 结束 */
    
    /** 可选属性 -- 开始 */
    /// 例如 下载文件的名称、描述、图片 ...
    public var name: String?
    /// 用户自定义信息
    public var userInfo: Dictionary<String, String>?
}

