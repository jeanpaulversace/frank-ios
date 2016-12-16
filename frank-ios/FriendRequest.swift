//
//  FriendRequest.swift
//  frank-ios
//
//  Created by Winston Tri on 12/1/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import Foundation

class FriendRequest {
    
    let id : String
    let fromUser : User
    let toUser : User
    let createdAt: Date
    let updatedAt: Date
    
    // Default initializaer
    init(id: String, fromUser: User, toUser: User, createdAt: String, updatedAt: String) throws {
        
        self.id = id
        self.fromUser = fromUser
        self.toUser = toUser
        self.createdAt = FrankDateFormatter.formatter.date(from: createdAt)!
        self.updatedAt = FrankDateFormatter.formatter.date(from: updatedAt)!
    }
    
    // JSON initializer
    init?(json: [String: Any]) throws {
        
        // Extract properties
        guard let id = json["_id"] as? String else {
            throw SerializationError.Missing("_id")
        }
        
        guard let fromUserJson = json["fromUser"] as? [String:Any] else {
            throw SerializationError.Missing("fromUserJson")
        }

        guard let fromUser = try User.init(json: fromUserJson) else {
            throw SerializationError.Missing("fromUser")
        }
        
        guard let toUserJson = json["toUser"] as? [String:Any] else {
            throw SerializationError.Missing("toUserJson")
        }
        
        guard let toUser = try User.init(json: toUserJson) else {
            throw SerializationError.Missing("toUser")
        }
        
        guard let createdAt = json["createdAt"] as? String else {
            throw SerializationError.Missing("createdAt")
        }
        
        guard let updatedAt = json["updatedAt"] as? String else {
            throw SerializationError.Missing("updatedAt")
        }
        
        // Initialize properties
        self.id = id
        self.fromUser = fromUser
        self.toUser = toUser
        self.createdAt = FrankDateFormatter.formatter.date(from: createdAt)!
        self.updatedAt = FrankDateFormatter.formatter.date(from: updatedAt)!
    }
    
    func toJsonWithoutId() -> [String:Any]? {
        return toJson(withId: false)
    }
    
    func toJson() -> [String:Any]? {
        return toJson(withId: true)
    }

    
    private func toJson(withId: Bool) -> [String:Any]? {
        
        let mirroredObject = Mirror(reflecting: self)
        
        var resultDictionary = [String:Any]()
        
        for (_, attr) in mirroredObject.children.enumerated() {
            if let property_name = attr.label as String! {
                if !withId && property_name == "id" {
                    continue
                }
                switch attr.value {
                case let user as User:
                    resultDictionary[property_name] = user.id
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
