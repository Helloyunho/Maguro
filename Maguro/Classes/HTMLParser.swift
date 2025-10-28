//
//  HTMLParser.swift
//  Maguro
//
//  Created by Helloyunho on 2025/10/28.
//

class HTMLParser {
    var html: String
    var parsedText: String = "" // later it will be changed to node ig

    init(_ html: String) {
        self.html = html
    }
    
    func parse() {
        var inTag = false
        for c in html {
            switch c {
            case "<":
                inTag = true
            case ">":
                inTag = false
            default:
                if !inTag {
                    parsedText += String(c)
                }
            }
        }
    }
}
