//
//  DownloadListVC.swift
//  Download
//
//  Created by 徐佳良 on 2020/5/28.
//  Copyright © 2020 zsm. All rights reserved.
//

import UIKit
import XDownload

class DownloadListDoneVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var dataSource: [DownloadModel] = [DownloadModel]()
    @IBOutlet weak var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.removeAll()
        loadData()
    }

    private func loadData() {
        self.dataSource = DownloadManager.default.getDownloadFinishModels()
        tableView.reloadData()
    }
    
}


extension DownloadListDoneVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.emptyView.isHidden = dataSource.count > 0;
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: DownloadListCell = tableView.dequeueReusableCell(withIdentifier: "cellid") as! DownloadListCell
        let model = dataSource[indexPath.row]
        cell.bindData(model: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let model = dataSource[indexPath.row]
            if let uid = model.model.uid {
                DownloadManager.default.deleteFile(uid: uid)
            }
            dataSource.remove(at: indexPath.row)
            //刷新tableview
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
}
