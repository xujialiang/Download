//
//  Config.swift
//  XDownload
//
//  Created by 徐佳良 on 2020/5/30.
//

import UIKit

/// 缓存主目录
let DownloadHomeDirectory = NSHomeDirectory() + "/Documents/XDownload/"
/// 下载文件的路径
public let DownloadCachePath = DownloadHomeDirectory + "DownloadCache/"
/// 保存下载的url路径(取模型用)
let ApplicationSupportDirectory = NSHomeDirectory() + "/Library/Application Support/XDownload/"
let DownloadCacheURLPath = ApplicationSupportDirectory + "URL.plist"
/// 保存下载文件的model路径
let DownloadCacheModelPath = "DownloadCache/DownloadModelCache"

// 最大任务数量
let MaxDownloadQueue = 10

