//
//  AddFriendService.swift
//  frank-ios
//
//  Created by Winston Tri on 12/7/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

struct FriendService {
    
    static func get(user: User) -> Promise<Any> {
        
        let accessToken = FBSDKAccessToken.current().tokenString!
        
        let accessTokenUrlSnippet = "?access_token=\(accessToken)"
        
        let url = Constants.serverUrl + "/api/users/friends/" + accessTokenUrlSnippet + user.id
        
        return Promise { fulfill, reject in
            Alamofire.request(url, method: .get, parameters : [:], encoding: JSONEncoding.default)
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
    
    static func addFriends(user: User, friend: User) -> Promise<Any> {
        
        let accessToken = FBSDKAccessToken.current().tokenString!
        
        let accessTokenUrlSnippet = "?access_token=\(accessToken)"
        
        let url = Constants.serverUrl + "/api/users/friends/" + accessTokenUrlSnippet + user.id
        
        return Promise { fulfill, reject in
            Alamofire.request(url, method: .patch, parameters : ["friend":friend.id], encoding: JSONEncoding.default)
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
    
    static func removeFriends(user: User, friend: User) -> Promise<Any> {
        
        let accessToken = FBSDKAccessToken.current().tokenString!
        
        let accessTokenUrlSnippet = "?access_token=\(accessToken)"
        
        let url = Constants.serverUrl + "/api/users/friends/" + accessTokenUrlSnippet + user.id
        
        return Promise { fulfill, reject in
            Alamofire.request(url, method: .delete, parameters : ["friend":friend.id], encoding: JSONEncoding.default)
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
