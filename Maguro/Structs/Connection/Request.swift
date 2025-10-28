//
//  Request.swift
//  Maguro
//
//  Created by Helloyunho on 2025/10/26.
//

import Foundation

struct Request {
    var method: RequestMethod = .GET
    var url: Url
    var headers = Headers()
    var data: Data?
    var version: HTTPVersion = .oneOne

    var raw: Data {
        let request = ["GET \(url.path) \(version.rawValue)", "Host: \(url.host)"] + headers.headers.map { "\($0): \($1)" }
        return (request.joined(separator: "\r\n") + "\r\n\r\n").data(using: .utf8)! + (data ?? Data())
    }
}
