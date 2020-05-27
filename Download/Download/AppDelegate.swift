//
//  AppDelegate.swift
//  Download
//
//  Created by 张书孟 on 2018/10/9.
//  Copyright © 2018年 zsm. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroundid: UIBackgroundTaskIdentifier?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = ViewController()
        let nav = UINavigationController(rootViewController: vc)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
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
    }
}

