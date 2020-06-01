//
//  TabbarVC.swift
//  Download
//
//  Created by xujialiang on 2020/5/29.
//  Copyright © 2020 zsm. All rights reserved.
//

import UIKit
import Floaty
import Flutter

class TabbarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let floaty = Floaty()
        floaty.addItem("", icon: UIImage(named: "DownloadtoCloud")!, handler: { item in
//            self.performSegue(withIdentifier: "showCreateDownloadTask", sender: self)
            self.showFlutter()
            
            floaty.close()
        })
        floaty.friendlyTap = false
        floaty.paddingX = 20
        floaty.paddingY = 80
        self.view.addSubview(floaty)
    }
    
    @objc func showFlutter() {
      let flutterEngine = (UIApplication.shared.delegate as! AppDelegate).flutterEngine
      let flutterViewController =
          FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
//
//        flutterViewController.setInitialRoute("/home2")
        flutterViewController.pushRoute("/home2");
      present(flutterViewController, animated: true, completion: nil)
    }
}
