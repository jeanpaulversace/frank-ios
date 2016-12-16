//
//  Utilities.swift
//  frank-ios
//
//  Created by Winston Tri on 12/2/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import Foundation

struct FrankDateFormatter {
    static let formatter : DateFormatter = {
        
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter
    }()
}

func JSONStringify(dict: [String:Any], prettyPrinted:Bool = false) -> String {
    
    let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
    
    
    if JSONSerialization.isValidJSONObject(dict) {
        
        do{
            let data = try JSONSerialization.data(withJSONObject: dict, options: options)
            if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                return string as String
            }
        }catch {
            
            print("error")
            //Access error here
        }
        
    }
    
    return ""

}

func stringWithPercentEscape(jsonString: String) -> String {
    if let percentEscapedJsonString =  jsonString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            return percentEscapedJsonString
    }
    
    return jsonString
}

