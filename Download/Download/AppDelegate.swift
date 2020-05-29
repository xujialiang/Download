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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroundid: UIBackgroundTaskIdentifier?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Bugly.start(withAppId: "5075f30a8d")
        MTA.start(withAppkey: "I745M6HRTVGT")
//        window = UIWindow(frame: UIScreen.main.bounds)
//        let vc = ViewController()
//        let nav = UINavigationController(rootViewController: vc)
//        window?.rootViewController = nav
//        window?.makeKeyAndVisible()
        
        DownloadManager.default.maxDownloadCount = 3
        DownloadManager.default.updateDownloadingStateWithSuspended()
        
        return true
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        debugPrint("handleEventsForBackgroundURLSession")
        DownloadManager.default.backgroundSessionCompletionHandler = completionHandler
    }
    
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        debugPrint("applicationDidEnterBackground")
        self.backgroundid =  UIApplication.shared.beginBackgroundTask(withName: "DownloadBackgroundSessionIdentifier", expirationHandler: {
            debugPrint("applicationDidEnterBackground expirationHandler")
            UIApplication.shared.endBackgroundTask(self.backgroundid!)
            self.backgroundid = UIBackgroundTaskIdentifier.invalid
        })

    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        debugPrint("杀死程序")
        DownloadManager.default.cancelAllTask()
        debugPrint("取消了所有任务")
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if MTAAutoTrack.handle(url) {
            return true
        }
        return false
    }
}

