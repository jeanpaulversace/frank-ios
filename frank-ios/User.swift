//
//  User.swift
//  frank-ios
//
//  Created by Winston Tri on 11/17/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

enum SerializationError: Error {
    case Missing(String)
    case Invalid(String,Any)
}

class User {
    
    let id : String
    let facebookId : String
    let accessToken : String
    let email : String
    let name : String
    let phoneNumber : String
    let createdAt : Date
    let updatedAt : Date
    let friends : [String]
    
    // Default initializer
    init(id: String, facebookId: String, accessToken: String, email: String, name: String, phoneNumber: String, createdAt: String, updatedAt: String, friends: [String]) throws {
        
        self.id = id
        self.facebookId = facebookId
        self.accessToken = accessToken
        self.email = email
        self.name = name
        self.phoneNumber = phoneNumber
        self.createdAt = FrankDateFormatter.formatter.date(from: createdAt)!
        self.updatedAt = FrankDateFormatter.formatter.date(from: updatedAt)!
        self.friends = friends
    }
    
    // JSON initializer
    init?(json: [String: Any]) throws {
        
        // Extract properties
        guard let id = json["_id"] as? String else {
            throw SerializationError.Missing("_id")
        }
        
        guard let facebookId = json["facebookId"] as? String else {
            throw SerializationError.Missing("facebookId")
        }
        
        guard let accessToken = json["accessToken"] as? String else {
            throw SerializationError.Missing("accessToken")
        }
        
        guard let email = json["email"] as? String else {
            throw SerializationError.Missing("email")
        }
        
        guard let name = json["name"] as? String else {
            throw SerializationError.Missing("name")
        }
        
        guard let phoneNumber = json["phoneNumber"] as? String else {
            throw SerializationError.Missing("phoneNumber")
        }
        
        guard let createdAt = json["createdAt"] as? String else {
            throw SerializationError.Missing("createdAt")
        }
        
        guard let updatedAt = json["updatedAt"] as? String else {
            throw SerializationError.Missing("updatedAt")
        }
        
        guard let friends = json["friends"] as? [String] else {
            throw SerializationError.Missing("friends")
        }
        
        // Initialize properties
        self.id = id
        self.facebookId = facebookId
        self.accessToken = accessToken
        self.email = email
        self.name = name
        self.phoneNumber = phoneNumber
        self.createdAt = FrankDateFormatter.formatter.date(from: createdAt)!
        self.updatedAt = FrankDateFormatter.formatter.date(from: updatedAt)!
        self.friends = friends
        
    }
    
    func toJsonWithoutId() -> [String:Any]? {
        return toJson(withId: false)
    }
    
    func toJson() -> [String:Any]? {
        return toJson(withId: true)
    }
    
    private func toJson(withId: Bool) -> [String:Any]? {
        
        let mirroredObject = Mirror(reflecting:self)
        
        var resultDictionary = [String:Any]()
        
        for (_, attr) in mirroredObject.children.enumerated() {
            if let property_name = attr.label as String! {
                if !withId {
                    continue
                }
                switch attr.value {
                case let date as Date:
                    resultDictionary[property_name] = FrankDateFormatter.formatter.string(from: date)
                default:
                    if property_name == "id" {
                        resultDictionary["_id"] = attr.value
                    } else {
                        resultDictionary[property_name] = attr.value
                    }
                }
            }
        }
        return resultDictionary
    }
    
    
}
