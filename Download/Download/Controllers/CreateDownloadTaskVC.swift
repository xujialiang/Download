//
//  CreateDownloadTaskVC.swift
//  Download
//
//  Created by xujialiang on 2020/5/29.
//  Copyright © 2020 zsm. All rights reserved.
//

import UIKit
import XDownload
import PromiseKit

class CreateDownloadTaskVC: UITableViewController {

    @IBOutlet weak var input_link: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func createTask(_ sender: Any) {
        
        Api.default.check(link: input_link.text!).done { ret in
            print(ret)
            if((ret["code"] as! Int) == 0 && (ret["data"] as! Int) == 0) {
                if let link = self.input_link.text, link.count > 0 {
                    let model = XDownloadModel()
                    model.model.name = self.input_link.text?.components(separatedBy: "/").last
                    model.model.url = self.input_link.text;
                    XDownload.default.download(model: model)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "温馨提示", message: "请输入正确的链接~", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "好吧", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            } else {
                let alert = UIAlertController(title: "温馨提示", message: "非常抱歉，该链接已被举报，暂时无法下载，如是误报，请联系我们。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
        

    }
    @IBAction func cancelAct(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }


}
