//
//  CreateDownloadTaskVC.swift
//  Download
//
//  Created by xujialiang on 2020/5/29.
//  Copyright © 2020 zsm. All rights reserved.
//

import UIKit
import XDownload

class CreateDownloadTaskVC: UITableViewController {

    @IBOutlet weak var input_link: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func createTask(_ sender: Any) {
        
        if let link = input_link.text, link.count > 0, link.contains("https://"), link.contains("http://") {
            let model = DownloadModel()
            model.model.name = self.input_link.text?.components(separatedBy: "/").last
            model.model.url = self.input_link.text;
            DownloadManager.default.download(model: model)
            self.dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "温馨提示", message: "请输入正确的链接~", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好吧", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
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
