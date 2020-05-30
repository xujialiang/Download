//
//  DownloadModel.swift
//  Download
//
//  Created by 张书孟 on 2018/10/9.
//  Copyright © 2018年 zsm. All rights reserved.
//

import UIKit

public enum XDownloadState: Int, Codable {
    case `default` /// 默认
    case start /// 下载中
    case waiting /// 等待
    case suspended /// 下载暂停
    case completed /// 下载完成
    case failed /// 下载失败
}

public class XDownloadModel: NSObject {
    
    public var states: XDownloadState = .default {
        didSet {
            model.state = states
            if let uid = model.uid {
                if let proModel = XDownloadModel.getDownloadModel(uid: uid) {
                    model.progress = proModel.progress
                }
                XDownloadModel.save(uid: uid, descModel: model)
            }
        }
    }
    
    public var failedReason: String = "" {
        didSet {
            model.failedReason = failedReason
            if let uid = model.uid {
                XDownloadModel.save(uid: uid, descModel: model)
            }
        }
    }
    
    public var model: XDownloadDescModel = XDownloadDescModel()
}

public class XDownloadDescModel: Codable {
    
    /** 必须有的属性 -- 开始 */
    public var uid: String? /// 资源ID，资源唯一标识，UID不同，即使URL相同，也认为是两个资源
    public var url: String? /// 下载地址
    public var createdTime: Date = Date()//创建时间
    public var resumeDataPath: String? /// 恢复下载时的文件路径
    
    public var totalLength: Int64 = 0 /// 获得服务器这次请求 返回数据的总长度
    public var receivedSize: Int64 = 0 /// 已经下载的长度
    
    /// 下载进度
    public var progress: Double = 0.0 {
        didSet {
            NotificationCenter.default.post(name: DownloadProgressNotification, object: self)
        }
    }
    
    public var state: XDownloadState = .default {
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

extension XDownloadModel {
    /// 获取下载的数据
    static func getDownloadModels() -> [XDownloadModel] {
        let uids: NSMutableArray = NSMutableArray(contentsOfFile: DownloadCacheURLPath) ?? NSMutableArray()
        var models = [XDownloadModel]()
        for uid in uids {
            if let uid2 = uid as? String {
                let downloadModel = XDownloadModel()
                if let model = XDownloadModel.getDownloadModel(uid: uid2) {
                    downloadModel.model = model
                    models.append(downloadModel)
                }
            }
        }
        return models
    }
    
    /// 获取下载完成的数据
    static func getDownloadFinishModels() -> [XDownloadModel] {
        let models = XDownloadModel.getDownloadModels().filter {
            return $0.model.state == .completed
        }
        return models
    }
    
    /// 获取未下载完成的数据
    static func getDownloadingModel() -> [XDownloadModel] {
        let models = XDownloadModel.getDownloadModels().filter {
            return $0.model.state != .completed
        }
        return models
    }
    
    /// 将未完成的下载状态改为.suspended
    static func updateDownloadingStateWithSuspended() {
        for model in XDownloadModel.getDownloadingModel() {
            if let uid = model.model.uid {
                model.model.state = .suspended
                XDownloadModel.save(uid: uid, descModel: model.model)
            }
        }
    }
    
    static func save(uid: String, descModel: XDownloadDescModel) {
        DownloadCache<XDownloadDescModel>().setObject(object: descModel, forKey: uid)
    }
    
    static func delete(uid: String) {
        DownloadCache<XDownloadDescModel>().removeObiect(forKey: uid)
    }
    
    static func getDownloadModel(uid: String) -> XDownloadDescModel? {
        return DownloadCache<XDownloadDescModel>().object(forKey: uid)
    }
}
