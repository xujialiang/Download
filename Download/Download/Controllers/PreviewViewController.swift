//
//  PreviewViewController.swift
//  Download
//
//  Created by 徐佳良 on 2020/5/30.
//  Copyright © 2020 zsm. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

    /// Creating UIDocumentInteractionController instance.
    let documentInteractionController = UIDocumentInteractionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Setting UIDocumentInteractionController delegate.
        documentInteractionController.delegate = self
    }
    
    @IBAction func showOptionsTapped(_ sender: UIButton) {
        /// Passing the remote URL of the file, to be stored and then opted with mutliple actions for the user to perform
        storeAndShare(withURLString: "https://images5.alphacoders.com/581/581655.jpg")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}

extension PreviewViewController {
    /// This function will set all the required properties, and then provide a preview for the document
    func share(url: URL) {
        documentInteractionController.url = url
        documentInteractionController.uti = url.typeIdentifier ?? "public.data, public.content"
        documentInteractionController.name = url.localizedName ?? url.lastPathComponent
        documentInteractionController.presentPreview(animated: true)
    }
    
    /// This function will store your document to some temporary URL and then provide sharing, copying, printing, saving options to the user
    func storeAndShare(withURLString: String) {
        guard let url = URL(string: withURLString) else { return }
        /// START YOUR ACTIVITY INDICATOR HERE
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(response?.suggestedFilename ?? "fileName.png")
            do {
                try data.write(to: tmpURL)
            } catch {
                print(error)
            }
            DispatchQueue.main.async {
                /// STOP YOUR ACTIVITY INDICATOR HERE
                self.share(url: tmpURL)
            }
            }.resume()
    }
}

extension PreviewViewController: UIDocumentInteractionControllerDelegate {
    /// If presenting atop a navigation stack, provide the navigation controller in order to animate in a manner consistent with the rest of the platform
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let navVC = self.navigationController else {
            return self
        }
        return navVC
    }
}

extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}
