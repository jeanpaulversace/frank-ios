//
//  DictionaryExtension.swift
//  frank-ios
//
//  Created by Winston Tri on 12/15/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import Foundation

extension Dictionary {
    
    /// Build string representation of HTTP parameter dictionary of keys and objects
    ///
    /// This percent escapes in compliance with RFC 3986
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped
    
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).addingPercentEncodingForURLQueryValue()!
            var percentEscapedValue = ""
            if let value = value as? [String:Any] {
                percentEscapedValue = value.stringFromHttpParameters()
            }
            if let value = value as? String {
                percentEscapedValue = value.addingPercentEncodingForURLQueryValue()!
            }
            
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }

}
