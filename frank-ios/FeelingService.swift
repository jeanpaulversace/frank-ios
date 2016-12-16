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
    
    static func get() -> Promise<Any> {
        
        let accessToken = FBSDKAccessToken.current().tokenString!
        
        let accessTokenUrlSnippet = "?access_token=\(accessToken)"
        
        var parameters = [String:Any]()
        
        parameters["creator"] = ["$in":UserService.currentUser?.friends]
        
        parameters["createdAt"] = ["$gte": FrankDateFormatter.formatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)]
        
        let url = Constants.serverUrl + "/api/feelings/search" + accessTokenUrlSnippet
        
        return Promise { fulfill, reject in
            Alamofire.request(url, method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil)
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
    
    static func getCreatedByCurrentUserInPastDay() -> Promise<Any> {
        
        let accessToken = FBSDKAccessToken.current().tokenString!
        
        let accessTokenUrlSnippet = "?access_token=\(accessToken)"
        
        var parameters = [String:Any]()
        
        parameters["creator"] = UserService.currentUser?.id
        
        parameters["createdAt"] = ["$gte": FrankDateFormatter.formatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)]
        
        let url = Constants.serverUrl + "/api/feelings/search" + accessTokenUrlSnippet
        
        return Promise { fulfill, reject in
            Alamofire.request(url, method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil)
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
