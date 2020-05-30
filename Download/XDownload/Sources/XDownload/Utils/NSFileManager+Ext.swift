//
//  NSFileManager+Ext.swift
//  XDownload
//
//  Created by 徐佳良 on 2020/5/30.
//

import Foundation
extension FileManager{
//    @discardableResult
    func addSkipBackupAttributeToItemAtURL(_ url: URL) -> Bool {
        let url = NSURL.fileURL(withPath: url.path) as NSURL
        do {
            try url.setResourceValue(true, forKey: .isExcludedFromBackupKey)
            try url.setResourceValue(false, forKey: .isUbiquitousItemKey)
            return true
        } catch {
            return false
        }
    }
    
    func addSkipBackupAttributeToItemAtURL(url:NSURL) throws {
        
        try url.setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
    }
}
