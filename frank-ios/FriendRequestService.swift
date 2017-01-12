//
//  FriendRequestService.swift
//  frank-ios
//
//  Created by Winston Tri on 12/2/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

struct FriendRequestService {
    
    
    static func get() -> Promise<Any> {
        
        let accessToken = FBSDKAccessToken.current().tokenString!
        
        let accessTokenUrlSnippet = "?access_token=\(accessToken)"
        
        let url = Constants.serverUrl + "/api/friend-requests/" + accessTokenUrlSnippet
        
        return Promise { fulfill, reject in
            Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: nil)
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
    
    static func create(friendRequests: [FriendRequest]) -> Promise<Any> {
        
        let accessToken = FBSDKAccessToken.current().tokenString!
        
        let accessTokenUrlSnippet = "?access_token=\(accessToken)"
        
        let url = Constants.serverUrl + "/api/friend-requests/" + accessTokenUrlSnippet
        
        var friendRequestJSONArray = [[String:Any]]()
        
        for friendRequest in friendRequests {
            friendRequestJSONArray.append(friendRequest.toJsonWithoutId() ?? [:])
        }
        
        return Promise { fulfill, reject in
            Alamofire.request(url, method: .post, parameters: ["friendRequests":friendRequestJSONArray], encoding: JSONEncoding.default, headers: nil)
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
    
    static func delete(friendRequest: FriendRequest) -> Promise<Any> {
        
        let accessToken = FBSDKAccessToken.current().tokenString!
        
        let accessTokenUrlSnippet = "?access_token=\(accessToken)"
        
        let url = Constants.serverUrl + "/api/friend-requests/" + friendRequest.id + accessTokenUrlSnippet
        return Promise { fulfill, reject in
            Alamofire.request(url, method: .delete, parameters: [:], encoding: JSONEncoding.default, headers: nil)
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
