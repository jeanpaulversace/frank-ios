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

