//
//  DownloadListVC.swift
//  Download
//
//  Created by 徐佳良 on 2020/5/28.
//  Copyright © 2020 zsm. All rights reserved.
//

import UIKit
import XDownload
import GSImageViewerController
import AVKit

class DownloadListDoneVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var dataSource: [XDownloadModel] = [XDownloadModel]()
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
        self.dataSource = XDownload.default.getDownloadFinishModels()
        tableView.reloadData()
    }
    
}


extension DownloadListDoneVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.emptyView.isHidden = dataSource.count > 0;
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: DownloadListDoneCell = tableView.dequeueReusableCell(withIdentifier: "cellid") as! DownloadListDoneCell
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
                XDownload.default.deleteFile(uid: uid)
            }
            dataSource.remove(at: indexPath.row)
            //刷新tableview
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let reportAction = UIAlertAction(title: "查看", style: .default) { (action) in
            let model = self.dataSource[indexPath.row]
            if let name = model.model.name {
                guard let uid = model.model.uid else {
                    return
                }
                let filePath =  DownloadCachePath + uid + "." + (name.components(separatedBy: ".").last ?? "")
                
                if name.contains("jpg") || name.contains("png") || name.contains("jpeg"){
                    guard let uid = model.model.uid else {
                        return
                    }
                    let filePath =  DownloadCachePath + uid + "." + (name.components(separatedBy: ".").last ?? "")
                    let img = UIImage(contentsOfFile: filePath)
                    guard let image = img else {
                        return
                    }
                    let imageInfo = GSImageInfo(image: image, imageMode: .aspectFit)
                    let imageViewer = GSImageViewerController(imageInfo: imageInfo)
                    imageViewer.title = name
                    self.navigationController?.pushViewController(imageViewer, animated: true)
                }else if name.contains("mp4") || name.contains("mp3") || name.contains("mov") {
                    let player = AVPlayer(url: NSURL(fileURLWithPath: filePath) as URL)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    playerViewController.player?.play()
                    self.present(playerViewController, animated:true, completion: nil)
                }
            }
        }

        let blockAction = UIAlertAction(title: "举报", style: .destructive) { (action) in
            //1. Create the alert controller.
            let alert = UIAlertController(title: "举报(版权问题)", message: "举报后，该链接会被立即屏蔽，如果需要恢复，请提供相关文件证明。", preferredStyle: .alert)

            //2. Add the text field. You can configure it however you need.
            alert.addTextField { (textField) in
                textField.text = "输入原因"
            }

            // 3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "提交", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                print("Text field: \(textField?.text)")
            }))

            // 4. Present the alert.
            self.present(alert, animated: true, completion: nil)
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            print("didPress cancel")
        }

        actionSheet.addAction(reportAction)
        actionSheet.addAction(blockAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
}

