//
//  URL.swift
//  Maguro
//
//  Created by Helloyunho on 2025/10/26.
//
import Foundation
import Network

struct Url {
    let scheme: String
    let host: String
    let path: String
    let port: UInt16?

    var url: URL {
        var urlcomponent = URLComponents()
        urlcomponent.scheme = scheme
        urlcomponent.host = host
        if let port {
            urlcomponent.port = Int(port)
        }
        urlcomponent.path = path
        return urlcomponent.url!
    }

    init(_ string: String) {
        var split = string.split(separator: ":", maxSplits: 1)
        scheme = String(split[0])
        var url = split[1].starts(with: "//") ? split[1][split[1].index(split[1].startIndex, offsetBy: 2)...] : split[1]

        if !url.contains("/") {
            url += "/"
        }

        split = url.split(separator: "/", maxSplits: 1)
        path = "/" + split[1]
        var portString: String?
        if split[0].contains(":") {
            split = split[0].split(separator: ":", maxSplits: 1)
            host = String(split[0])
            portString = String(split[1])
        } else {
            host = String(split[0])
        }

        switch scheme {
        case "http":
            port = 80
        case "https":
            port = 443
        default:
            if let portString {
                port = UInt16(portString)
            } else {
                port = nil
            }
        }
    }
}
