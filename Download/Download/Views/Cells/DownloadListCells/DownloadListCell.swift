//
//  DownloadListCell.swift
//  Download
//
//  Created by 徐佳良 on 2020/5/28.
//  Copyright © 2020 zsm. All rights reserved.
//

import UIKit
import XDownload

class DownloadListCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var downloadedInfo: UILabel!
    @IBOutlet weak var lbl_taskStatus: UILabel!
    
    @IBOutlet weak var btnImage: UIImageView!
    
    private var downLoadModel: DownloadModel?
    private lazy var progressView: ProgressView = {
        ProgressView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width , height: 1))
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addSubviews()
    }
    
    func bindData(model: DownloadModel) {
        downLoadModel = model
        self.title.text = downLoadModel?.model.name
        let ext = downLoadModel?.model.name?.components(separatedBy: ".").last
        self.icon.image = iconImage(ext: ext)
        
        if let uid = model.model.uid, let model1 = model.getDownloadModel(uid: uid) {
            progressView.update(model: model1)
            lbl_taskStatus.text = state(state: model1.state)
            let receivedSize = String(format: "%.2f", Float(model1.receivedSize)/1024/1024)
            let totalLength = String(format: "%.2f", Float(model1.totalLength)/1024/1024)
            
            self.downloadedInfo.text = "\(receivedSize) MB / \(totalLength) MB"
        } else {
            progressView.update(model: model.model)
            lbl_taskStatus.text = state(state: model.model.state)
            let receivedSize = String(format: "%.2f", Float(model.model.receivedSize)/1024)
            let totalLength = String(format: "%.2f", Float(model.model.totalLength)/1024)
            
            self.downloadedInfo.text = "\(receivedSize) MB / \(totalLength) MB"
        }
        
        
    }
    
    @IBAction func didClickBtn(_ sender: Any) {
        guard let downloadModel = downLoadModel else {
            return
        }
        DownloadManager.default.download(model: downloadModel)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func state(state: DownloadState) -> String {
        
        switch state {
            case .start:
                self.btnImage.isHighlighted = true
                return "下载中"
            case .completed:
                self.btnImage.isHighlighted = false
                return "完成"
            case .waiting:
                self.btnImage.isHighlighted = true
                return "等待"
            case .suspended:
                self.btnImage.isHighlighted = false
                return "已暂停"
            case .failed:
                self.btnImage.isHighlighted = false
                return "下载失败"
            default:
                self.btnImage.isHighlighted = false
                return "开始"
        }
    }

    private func iconImage(ext: String?) -> UIImage{
        switch ext {
            case "chm", "csv", "number", "onenote", "pdf", "rtf", "txt", "ppt", "css":
                return UIImage(named: "file_" + (ext ?? "unknow"))!
            case "doc", "docx":
                return UIImage(named: "file_word")!
            case "xls", "xlsx":
                return UIImage(named: "file_excel")!
            case "mp3", "ogg":
                return UIImage(named: "file_music")!
            case "jpg", "jpeg", "png":
                return UIImage(named: "file_pic")!
            case "dmg", "exe":
                return UIImage(named: "file_install")!
            case "rar", "zip":
                return UIImage(named: "file_rarzip")!
            case "mp4", "rmvb", "mkv":
                return UIImage(named: "file_video")!
            default:
                return UIImage(named: "file_unknow")!
        }
    }
}

extension DownloadListCell {
    
    private func addSubviews() {
        var hasView = false
        for view in contentView.subviews {
            if view.isKind(of: ProgressView.self) {
                hasView = true
            }
        }
        if(!hasView) {
            contentView.addSubview(progressView)
        }
        progressView.snp.makeConstraints { (make) in
            make.bottom.equalTo(0)
            make.left.equalTo(20)
            make.right.equalTo(0)
            make.height.equalTo(1)
        }
    }
}
