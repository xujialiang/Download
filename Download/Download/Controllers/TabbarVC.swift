//
//  TabbarVC.swift
//  Download
//
//  Created by xujialiang on 2020/5/29.
//  Copyright © 2020 zsm. All rights reserved.
//

import UIKit

class TabbarVC: UITabBarController, FloatDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = CGRect.init(x: self.view.frame.width - 60-30, y: self.view.frame.height - 160, width: 60, height: 60)
        let allbutton = AllFloatButton.init(frame: frame)
        allbutton.bgImage = UIImage(named: "DownloadtoCloud")
        allbutton.delegate = self
        self.view.addSubview(allbutton)

        // Do any additional setup after loading the view.
    }
    
    // 实现代理方法
    func singleClick() {
        print("单击")
        self.performSegue(withIdentifier: "showCreateDownloadTask", sender: self)
    }
    
    func repeatClick() {
        print("双击")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
