//
//  Api.swift
//  Download
//
//  Created by 徐佳良 on 2020/5/31.
//  Copyright © 2020 zsm. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

class Api {
    
    internal static let `default` = Api()

    func report(link: String?, reason: String?) -> Promise<[String: Any]>{
        return Promise { seal in
            guard let link1 = link, let reason1 = reason else {
                return
            }
            let parameters: [String: String] = [
                "link": link1,
                "reason": reason1
            ]

            // All three of these calls are equivalent
            AF.request("http://ixiazai.dev.xujialiang.net/report", method: .post, parameters: parameters).responseJSON { response in
                debugPrint(response)
                switch response.result {
                    case .success(let json):
                        guard let json = json  as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        seal.fulfill(json)
                    case .failure(let error):
                        seal.reject(error)
                }
            }
        }
    }
    
    func check(link: String?) -> Promise<[String: Any]> {
        return Promise { seal in
            guard let link1 = link else {
                return
            }
            let parameters: [String: String] = [
                "link": link1
            ]

            // All three of these calls are equivalent
            AF.request("http://ixiazai.dev.xujialiang.net/check", method: .post, parameters: parameters).responseJSON { response in
                debugPrint(response)
                switch response.result {
                    case .success(let json):
                        guard let json = json  as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        seal.fulfill(json)
                    case .failure(let error):
                        seal.reject(error)
                }
            }
        }
    }
}
