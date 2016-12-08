//
//  FeelingService.swift
//  frank-ios
//
//  Created by Winston Tri on 12/7/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

struct FeelingService {
    
    static func create(feeling: Feeling) -> Promise<Any> {
        
        let accessToken = FBSDKAccessToken.current().tokenString!
        
        let accessTokenUrlSnippet = "?access_token=\(accessToken)"
        
        let url = Constants.serverUrl + "/api/feelings/" + accessTokenUrlSnippet
        
        return Promise { fulfill, reject in
            Alamofire.request(url, method: .post, parameters: ["feeling":feeling.toJsonWithoutId() ?? [:]], encoding: JSONEncoding.default, headers: nil)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let dict):
                        fulfill(dict)
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
        
    }
    
}
