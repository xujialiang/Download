//
//  DownloadListVC.swift
//  Download
//
//  Created by 徐佳良 on 2020/5/28.
//  Copyright © 2020 zsm. All rights reserved.
//

import UIKit
import XDownload

class DownloadListVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var dataSource: [DownloadModel] = [DownloadModel]()
    @IBOutlet weak var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotification()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.removeAll()
        loadData()
    }

    private func addNotification() {
        // 进度通知
        NotificationCenter.default.addObserver(self, selector: #selector(downLoadProgress(notification:)), name: DownloadProgressNotification, object: nil)
        
        // 任务状态通知
        NotificationCenter.default.addObserver(self, selector: #selector(downLoadStatus(notification:)), name: DownloadStatusNotification, object: nil)
    }
    
    private func loadData() {
//        let model1 = DownloadModel()
//        model1.model.name = "测试1.pdf"
//        model1.model.uid = "1"
//        model1.model.url = "http://tya.znzkj.net/touyanshe_web/outImages/20180104/20180104_5642247.pdf"
//
//        let model2 = DownloadModel()
//        model2.model.name = "测试2.mp4"
//        model2.model.uid = "2"
//        model2.model.url = "http://7xqhmn.media1.z0.glb.clouddn.com/femorning-20161106.mp4"
//
//        let model3 = DownloadModel()
//        model3.model.name = "测试3.mp4"
//        model3.model.uid = "3"
//        model3.model.url = "http://file.ubye.cn/UbyeServiceFiles/video/143/YCJS2018082321125/201808231807433820180823180734.mp4"
//
//        let model4 = DownloadModel()
//        model4.model.name = "测试4.zip"
//        model4.model.uid = "4"
//        model4.model.url = "http://www.hangge.com/blog_uploads/201709/2017091219324377713.zip"
//
//        let model5 = DownloadModel()
//        model5.model.name = "测试5.mp4"
//        model5.model.uid = "5"
//        model5.model.url = "http://www.runoob.com/try/demo_source/movie.mp4"
//
//        let model6 = DownloadModel()
//        model6.model.name = "Demo.dmg"
//        model6.model.uid = "6"
//        model6.model.url = "https://download.jetbrains.8686c.com/python/pycharm-professional-2017.3.2.dmg"
//
//        let model7 = DownloadModel()
//        model7.model.name = "测试7.zip"
//        model7.model.uid = "7"
//        model7.model.url = "https://download.sketchapp.com/sketch-51.1-57501.zip"
//
//        let model8 = DownloadModel()
//        model8.model.name = "测试8.ara"
//        model8.model.uid = "8"
//        model8.model.url = "http://static.realm.io/downloads/swift/realm-swift-3.4.0.zip"
//
//        let model9 = DownloadModel()
//        model9.model.name = "测试9.rar"
//        model9.model.uid = "9"
//        model9.model.url = "http://qunying.jb51.net:81/201710/books/iOS11Swift4_jb51.rar"
//
//        dataSource.append(model1)
//        dataSource.append(model2)
//        dataSource.append(model3)
//        dataSource.append(model4)
//        dataSource.append(model5)
//        dataSource.append(model6)
//        dataSource.append(model7)
//        dataSource.append(model8)
//        dataSource.append(model9)
////        dataSource.append(model10)
//        tableView.reloadData()
        
        dataSource = DownloadManager.default.getDownloadingModel()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc private func downLoadProgress(notification: Notification) {
        if let model = notification.object as? DownloadDescModel {
            for (index, descModel) in dataSource.enumerated() {
                if model.uid == descModel.model.uid {
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }
                        if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? DownloadListCell {
                            cell.bindData(model: descModel)
                        }
                    }
                }
            }
        }
    }
    
    @objc private func downLoadStatus(notification: Notification) {
        if let model = notification.object as? DownloadDescModel {
            self.loadData()
        }
    }

}


extension DownloadListVC: UITableViewDelegate, UITableViewDataSource {
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

