//
//  FrankUser.swift
//  frank-ios
//
//  Created by Winston Tri on 11/18/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

enum SessionError: Error {
    case NoCurrentUser
}

struct UserService {
    
    static var currentUser : User?
    
    static func login(accessToken: FBSDKAccessToken) -> Promise<Any> {
        
        let url = Constants.serverUrl + "/auth/facebook/token?access_token=\(accessToken.tokenString!)"
        
        return Promise { fulfill, reject in
            Alamofire.request(url, method: .post, parameters: [:])
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
    
    static func update(user: User) -> Promise<Any> {
        
        let accessToken = FBSDKAccessToken.current().tokenString!
    
        let accessTokenUrlSnippet = "?access_token=\(accessToken)"
        
        let url = Constants.serverUrl + "/api/users/" + user.id + accessTokenUrlSnippet
        
        return Promise { fulfill, reject in
            Alamofire.request(url, method: .patch, parameters : ["user":user.toJson() ?? [:]], encoding: JSONEncoding.default)
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
