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
        DownloadManager.default.backgroundSessionCompletionHandler = completionHandler
    }
    
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        UIApplication.shared.beginBackgroundTask {}
//        bgTask = [application beginBackgroundTaskWithName:@"MyTask" expirationHandler:^{
//            // Clean up any unfinished task business by marking where you
//            // stopped or ending the task outright.
//            [application endBackgroundTask:bgTask];
//            bgTask = UIBackgroundTaskInvalid;
//        }];
//
//        // Start the long-running task and return immediately.
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//            // Do the work associated with the task, preferably in chunks.
//
//            [application endBackgroundTask:bgTask];
//            bgTask = UIBackgroundTaskInvalid;
//        });
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        debugPrint("杀死程序")
    }
}

