//
//  FrankUser.swift
//  frank-ios
//
//  Created by Winston Tri on 11/18/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import Foundation

class FrankUser {
    
    static func loginOrSignUpUserWith(accessToken: FBSDKAccessToken?) {
        if let token = accessToken {
            
            var fbAuthRequest = URLRequest(url: URL(string: "http://10.24.104.171:8080/auth/facebook/token?access_token=\(token.tokenString!)")!)
            fbAuthRequest.httpMethod = "POST"
            
            let task = URLSession.shared.dataTask(with: fbAuthRequest) { data, response, error in
                guard let data = data, error == nil else {
                    // Fundamental Network Error
                    print("Error occurred trying to connect: \(error)")
                    
                    return
                }
                
                // Server error
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("Server encountered error with HTTP Status: \(httpStatus.statusCode)")
                }
                
                // Request returned successfully
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let dictionary = json as? [String: Any] {
                    
                    if dictionary["isNew"] != nil {
                        // New User
                    
                    } else {
                        // Existing User
                        
                    }
                    
                }
                
            }
            
            task.resume()
        }
    }
}
