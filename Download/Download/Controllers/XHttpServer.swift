//
//  TelegraphHttpServer.swift
//  Download
//
//  Created by 徐佳良 on 2020/5/30.
//  Copyright © 2020 zsm. All rights reserved.
//

import Foundation
import XDownload
import Swifter

internal class XHttpServer: NSObject {

    internal static let `default` = XHttpServer()
    
    let server = HttpServer()
    
    override init() {
        super.init()
        
        // 访问路径: http://xxx.xxx.xxx.xxx:9192/files/DownloadCache
        server["/files/:path"] = directoryBrowser(DownloadHomeDirectory)
        server["/files/DownloadCache/:path"] = directoryBrowser(DownloadCachePath)
//        server["/download/:path"] = shareFilesFromDirectory(DownloadCachePath)
        try! server.start(9192, forceIPv4: false, priority: DispatchQoS.QoSClass.background)
        
    }
}
