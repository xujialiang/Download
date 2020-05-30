//
//  DownloadListCell.swift
//  Download
//
//  Created by 徐佳良 on 2020/5/28.
//  Copyright © 2020 zsm. All rights reserved.
//

import UIKit
import XDownload

class DownloadListDoneCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var downloadedInfo: UILabel!
    
    private var downLoadModel: XDownloadModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func bindData(model: XDownloadModel) {
        downLoadModel = model
        self.title.text = downLoadModel?.model.name
        let ext = downLoadModel?.model.name?.components(separatedBy: ".").last
        self.icon.image = iconImage(ext: ext)
        
        if let uid = model.model.uid, let model1 = XDownload.default.getDownloadModel(uid: uid) {
            let receivedSize = String(format: "%.2f", Float(model1.receivedSize)/1024/1024)
            let totalLength = String(format: "%.2f", Float(model1.totalLength)/1024/1024)
            self.downloadedInfo.text = "\(receivedSize) MB / \(totalLength) MB"
        } else {
            let receivedSize = String(format: "%.2f", Float(model.model.receivedSize)/1024)
            let totalLength = String(format: "%.2f", Float(model.model.totalLength)/1024)
            self.downloadedInfo.text = "\(receivedSize) MB / \(totalLength) MB"
        }
        
        
    }
    
    @IBAction func didClickBtn(_ sender: Any) {
        guard let downloadModel = downLoadModel else {
            return
        }
        XDownload.default.download(model: downloadModel)
    }
    
    @IBAction func shareFileAct(_ sender: Any) {
        guard let name = downLoadModel!.model.name else {
           return
        }
        guard let uid = downLoadModel!.model.uid else {
           return
        }
        let filePath =  DownloadCachePath + uid + "." + (name.components(separatedBy: ".").last ?? "")
        let fileURL = URL.init(fileURLWithPath: filePath)
        let data = NSData.init(contentsOf: fileURL)
        let vc = UIActivityViewController.init(activityItems: [data, fileURL], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

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
