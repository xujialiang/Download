//
//  ViewController.swift
//  Download
//
//  Created by 张书孟 on 2018/10/9.
//  Copyright © 2018年 zsm. All rights reserved.
//

import UIKit
import XDownload

class ViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.register(ViewTableViewCell.self, forCellReuseIdentifier: "ViewTableViewCell")
        return tableView
    }()
    
    private var dataSource: [XDownloadModel] = [XDownloadModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.removeAll()
        loadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        DownloadManager.default.cancelAllTask()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNotification()
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "下载管理", style: .plain, target: self, action: #selector(nextClick))
        navigationItem.title = "i虾仔"
        debugPrint(NSHomeDirectory())
        
        view.addSubview(tableView)
        
        loadData()
    }
    
    private func loadData() {
        let model1 = XDownloadModel()
        model1.model.name = "测试1.pdf"
        model1.model.uid = "1"
        model1.model.url = "http://tya.znzkj.net/touyanshe_web/outImages/20180104/20180104_5642247.pdf"
        
        let model2 = XDownloadModel()
        model2.model.name = "测试2.mp4"
        model2.model.uid = "2"
        model2.model.url = "http://7xqhmn.media1.z0.glb.clouddn.com/femorning-20161106.mp4"
        
        let model3 = XDownloadModel()
        model3.model.name = "测试3.mp4"
        model3.model.uid = "3"
        model3.model.url = "http://file.ubye.cn/UbyeServiceFiles/video/143/YCJS2018082321125/201808231807433820180823180734.mp4"
        
        let model4 = XDownloadModel()
        model4.model.name = "测试4.zip"
        model4.model.uid = "4"
        model4.model.url = "http://www.hangge.com/blog_uploads/201709/2017091219324377713.zip"
        
        let model5 = XDownloadModel()
        model5.model.name = "测试5.rar"
        model5.model.uid = "5"
        model5.model.url = "http://www.runoob.com/try/demo_source/movie.mp4"
        
        let model6 = XDownloadModel()
        model6.model.name = "测试6.dmg"
        model6.model.uid = "6"
        model6.model.url = "https://download.jetbrains.8686c.com/python/pycharm-professional-2017.3.2.dmg"
        
        let model7 = XDownloadModel()
        model7.model.name = "测试7.zip"
        model7.model.uid = "7"
        model7.model.url = "https://download.sketchapp.com/sketch-51.1-57501.zip"
        
        let model8 = XDownloadModel()
        model8.model.name = "测试8.zip"
        model8.model.uid = "8"
        model8.model.url = "http://static.realm.io/downloads/swift/realm-swift-3.4.0.zip"
        
        let model9 = XDownloadModel()
        model9.model.name = "测试9.rar"
        model9.model.uid = "9"
        model9.model.url = "http://qunying.jb51.net:81/201710/books/iOS11Swift4_jb51.rar"
        
        dataSource.append(model1)
        dataSource.append(model2)
        dataSource.append(model3)
        dataSource.append(model4)
        dataSource.append(model5)
        dataSource.append(model6)
        dataSource.append(model7)
        dataSource.append(model8)
        dataSource.append(model9)
//        dataSource.append(model10)
        tableView.reloadData()
    }
    
    private func addNotification() {
        // 进度通知
        NotificationCenter.default.addObserver(self, selector: #selector(downLoadProgress(notification:)), name: DownloadProgressNotification, object: nil)
    }
    
    @objc private func nextClick() {
        navigationController?.pushViewController(DownloadViewController(), animated: true)
    }
    
    @objc private func downLoadProgress(notification: Notification) {
        if let model = notification.object as? XDownloadDescModel {
            for (index, descModel) in dataSource.enumerated() {
                if model.url == descModel.model.url {
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }
                        if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ViewTableViewCell {
                            cell.updateView(model: model)
                        }
                    }
                }
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ViewTableViewCell") as! ViewTableViewCell
        let model = dataSource[indexPath.row]
        cell.update(model: model)
        return cell
    }
}
