//
//  DownloadManager+Extension.swift
//  XDownload
//
//  Created by 徐佳良 on 2020/5/30.
//

import Foundation
import Cache

// 文件类操作
extension DownloadManager {
    /// 判断该文件是否下载完成
    public func isCompletion(uid: String) -> Bool {
        if let model = XDownloadModel.getDownloadModel(uid: uid),
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
    
    /// 创建缓存路径
    internal func path(uid: String) -> String {
        do {
            try FileManager.default.createDirectory(atPath: DownloadCachePath, withIntermediateDirectories: true, attributes: nil)
            return DownloadCachePath + uid
        } catch {
            return DownloadCachePath
        }
    }
    
    /// 保存下载的url(取 model 用)
    internal func save(uid: String) {
        let uidArr: NSMutableArray = NSMutableArray(contentsOfFile: DownloadCacheURLPath) ?? NSMutableArray()
        guard !(uidArr.contains(uid)) else { return }
        uidArr.add(uid)
        uidArr.write(toFile: DownloadCacheURLPath, atomically: true)
    }
    
    /// 获取已下载文件的大小
    internal func getDownloadSize(uid: String) -> Int {
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
    
    /// 获取总缓存大小 单位：字节
    internal func getCacheSize() -> Double {
        return DownloadHomeDirectory.dw_getCacheSize
    }
    
    /// 获取下载完成的文件路径
    internal func getFile(uid: String) -> String {
        guard isExistence(uid: uid), isCompletion(uid: uid) else { return "" }
        return DownloadCachePath + uid
    }
}

internal extension String {
    var dw_MD5String: String {
        return MD5(self)
    }
}

internal extension String {
    
    var dw_getFileName: String {
        return self.dw_MD5String + self.dw_pathExtension
    }
    
    /// 从url中获取后缀
    var dw_pathExtension: String {
        if let url = URL(string: self) {
            return url.pathExtension.isEmpty ? "" : ".\(url.pathExtension)"
        }
        return ""
    }
}

internal extension String {
    var dw_isURL: Bool {
        let url = "[a-zA-z]+://[^\\s]*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", url)
        return predicate.evaluate(with: self)
    }
}

internal extension String {
    
    /// 遍历所有子目录， 并计算文件大小 单位：字节
    var dw_getCacheSize: Double {
        var fileSize: Double = 0.0
        if let childFilePath = FileManager.default.subpaths(atPath: self) {
            for path in childFilePath {
                let fileAbsoluePath = self + path
                fileSize += fileAbsoluePath.dw_fileSize
            }
        }
        return fileSize
    }
    
    /// 计算单个文件的大小 单位：字节
    var dw_fileSize: Double {
        let manager = FileManager.default
        var fileSize: Double = 0.0
        if manager.fileExists(atPath: self) {
            do {
                let attributes = try manager.attributesOfItem(atPath: self)
                if !attributes.isEmpty, let size = attributes[FileAttributeKey.size] as? Double {
                    fileSize = size
                }
            } catch {}
        }
        return fileSize
    }
}
