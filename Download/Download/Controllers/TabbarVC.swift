//
//  TabbarVC.swift
//  Download
//
//  Created by xujialiang on 2020/5/29.
//  Copyright © 2020 zsm. All rights reserved.
//

import UIKit
import Floaty

class TabbarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let floaty = Floaty()
        floaty.addItem("", icon: UIImage(named: "DownloadtoCloud")!, handler: { item in
            self.performSegue(withIdentifier: "showCreateDownloadTask", sender: self)
            floaty.close()
        })
        floaty.paddingX = 20
        floaty.paddingY = 80
        self.view.addSubview(floaty)
    }

}
