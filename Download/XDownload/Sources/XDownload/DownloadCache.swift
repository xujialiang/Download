//
//  DownloadCache.swift
//  Download
//
//  Created by 张书孟 on 2018/10/15.
//  Copyright © 2018年 zsm. All rights reserved.
//

import Cache

public class DownloadCache<T: Codable> {
    
    var storage: Storage<T>?
    
    public init() {
        let diskConfig = DiskConfig(name: DownloadCacheModelPath)
        let memoryConfig = MemoryConfig(expiry: .never)
        do {
            storage = try Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: T.self))
        } catch {}
    }
    
    public func setObject(object: T, forKey: String) {
        do {
            try storage?.setObject(object, forKey: forKey)
        } catch {}
    }
    
    public func object(forKey key: String) -> T? {
        do {
            return try storage?.object(forKey: key) ?? nil
        } catch {
            return nil
        }
    }
    
    public func removeObiect(forKey key: String) {
        do {
            try storage?.removeObject(forKey: key)
        } catch {}
    }
    
    public func removeAll() {
        do {
            try storage?.removeAll()
        } catch {}
    }
}
