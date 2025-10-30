//
//  DataURL.swift
//  Maguro
//
//  Created by Helloyunho on 2025/10/30.
//

import Foundation

struct DataURL {
    let scheme = "data"
    var mimeType: String?
    var isBase64Encoded: Bool = false
    var dataString: String
    
    var data: Data? {
        if isBase64Encoded {
            Data(base64Encoded: dataString)
        } else {
            dataString.data(using: .utf8)
        }
    }
    
    var text: String? {
        if isBase64Encoded {
            guard let data = Data(base64Encoded: dataString) else {
                return nil
            }
            return String(data: data, encoding: .utf8)
        } else {
            return dataString
        }
    }
    
    init?(_ string: String) {
        var split = string.split(separator: ":", maxSplits: 1)
        if split[0] != scheme {
            return nil
        }
        
        split = split[1].split(separator: ",", maxSplits: 1, omittingEmptySubsequences: false)
        if !split[0].isEmpty {
            mimeType = String(split[0])
        }
        dataString = String(split[1])
        
        split = split[0].split(separator: ";")
        isBase64Encoded = split.last == "base64"
    }
}
