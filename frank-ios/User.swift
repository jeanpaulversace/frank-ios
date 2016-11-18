//
//  User.swift
//  frank-ios
//
//  Created by Winston Tri on 11/17/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import Foundation

enum SerializationError: Error {
    case missing(String)
    case invalid(String,Any)
}

class User {
    
    let facebookId : String
    let token : String
    let email : String
    let name : String
    let createdAt : Date
    let updatedAt : Date
    // let friends : Set<User>
    
    // Default initializer
    init(facebookId: String, token: String, email: String, name: String, createdAt: Date, updatedAt: Date) throws {
        self.facebookId = facebookId
        self.token = token
        self.email = email
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // JSON initializer
    init?(json: [String: Any]) throws {
        
        // Extract properties
        guard let facebookId = json["facebookId"] as? String else {
            throw SerializationError.missing("facebookId")
        }
        
        guard let token = json["token"] as? String else {
            throw SerializationError.missing("token")
        }
        
        guard let email = json["email"] as? String else {
            throw SerializationError.missing("email")
        }
        
        guard let name = json["name"] as? String else {
            throw SerializationError.missing("name")
        }
        
        guard let createdAt = json["createdAt"] as? Date else {
            throw SerializationError.missing("createdAt")
        }
        
        guard let updatedAt = json["updatedAt"] as? Date else {
            throw SerializationError.missing("updatedAt")
        }
        
        // Initialize properties
        self.facebookId = facebookId
        self.token = token
        self.email = email
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    
}
