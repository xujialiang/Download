//
//  AppDelegate.swift
//  Download
//
//  Created by 张书孟 on 2018/10/9.
//  Copyright © 2018年 zsm. All rights reserved.
//

import UIKit
import XDownload
import Bugly
import Flutter
// Used to connect plugins (only if you have plugins with iOS platform code).
import FlutterPluginRegistrant

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {

    var backgroundid: UIBackgroundTaskIdentifier?
    
    lazy var flutterEngine = FlutterEngine(name: "my flutter engine")
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Bugly.start(withAppId: "5075f30a8d")
        MTA.start(withAppkey: "I745M6HRTVGT")

        XDownload.default.updateDownloadingStateWithSuspended()
        
        let _ = XHttpServer.default
        
        flutterEngine.run();
        // Used to connect plugins (only if you have plugins with iOS platform code).
        GeneratedPluginRegistrant.register(with: self.flutterEngine);
        
        return true
    }

    override func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        debugPrint("handleEventsForBackgroundURLSession")
        XDownload.default.backgroundSessionCompletionHandler = completionHandler
    }
    
    
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        debugPrint("applicationDidEnterBackground")
        self.backgroundid =  UIApplication.shared.beginBackgroundTask(withName: "DownloadBackgroundSessionIdentifier", expirationHandler: {
            debugPrint("applicationDidEnterBackground expirationHandler")
            UIApplication.shared.endBackgroundTask(self.backgroundid!)
            self.backgroundid = UIBackgroundTaskIdentifier.invalid
        })

    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        debugPrint("杀死程序")
        XDownload.default.cancelAllTask()
        debugPrint("取消了所有任务")
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if MTAAutoTrack.handle(url) {
            return true
        }
        return false
    }
}

