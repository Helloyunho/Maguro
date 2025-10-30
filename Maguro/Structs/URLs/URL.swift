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
    let queryParams: QueryParams

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
    
    static func getMatchingPort(scheme: String) -> UInt16? {
        switch scheme {
        case "http":
            80
        case "https":
            443
        default:
            nil
        }
    }
    
    init(scheme: String, host: String, path: String, port: UInt16?, queryParams: QueryParams?) {
        self.scheme = scheme
        self.host = host
        self.path = path
        if let port {
            self.port = port
        } else {
            self.port = Url.getMatchingPort(scheme: scheme)
        }
        self.queryParams = queryParams ?? [:]
    }

    init?(_ string: String) {
        var split = string.split(separator: ":", maxSplits: 1)
        if split.count != 2 {
            return nil
        }
        scheme = String(split[0])
        var url = split[1].starts(with: "//") ? split[1][split[1].index(split[1].startIndex, offsetBy: 2)...] : split[1]

        if !url.contains("/") {
            url += "/"
        }

        var portString: String?
        if url.starts(with: "/") {
            path = String(url)
            host = ""
        } else {
            split = url.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: false)
            path = "/" + split[1]
            split = split[0].split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            host = String(split[0])
            if split.count == 2 && (!split[1].isEmpty || split[1].allSatisfy(\.isNumber)) {
                portString = String(split[1])
            }
        }

        if let portString {
            port = UInt16(portString)
        } else {
            port = Url.getMatchingPort(scheme: scheme)
        }
        split = string.split(separator: "?", maxSplits: 1)
        if split.count == 2 && !split[1].isEmpty {
            queryParams = QueryParams(String(split[1]))
        } else {
            queryParams = [:]
        }
    }
}
