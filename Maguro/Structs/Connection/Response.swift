//
//  Response.swift
//  Maguro
//
//  Created by Helloyunho on 2025/10/27.
//

import Foundation
import Network

struct Response {
    let MAX_DATA_LEN = 65536
    let version: HTTPVersion
    let status: UInt16
    let statusText: String
    let headers: Headers
    let body: Data
    var ok: Bool { self.status >= 200 && self.status <= 299 }

    init(version: HTTPVersion, status: UInt16, statusText: String, headers: Headers, body: Data) {
        self.version = version
        self.status = status
        self.statusText = statusText
        self.headers = headers
        self.body = body
    }
    
    static func read(conn: Connection) async throws -> Response? {
        var data = Data()
        while !data.contains("\r\n".data(using: .utf8)!) {
            data += try await conn.receive(len: 16) ?? Data()
        }
        guard let range = data.range(of: "\r\n".data(using: .utf8)!),
            let statusLine = String(data: data[..<range.lowerBound], encoding: .utf8)?.split(
                separator: " ",
                maxSplits: 2
            )
        else {
            return nil
        }
        data.removeSubrange(..<range.upperBound)

        guard let version = HTTPVersion(rawValue: String(statusLine[0])) else {
            return nil
        }
        let status = UInt16(statusLine[1])!
        let statusText = String(statusLine[2])

        var headers: Headers = [:]
        while !data.contains("\r\n\r\n".data(using: .utf8)!) {
            data += try await conn.receive(len: 16)!
        }
        while let range = data.range(of: "\r\n".data(using: .utf8)!),
            let line = String(data: data[..<range.upperBound], encoding: .utf8)
        {
            data.removeSubrange(..<range.upperBound)
            if line == "\r\n" {
                break
            }
            let split = line.split(separator: ":", maxSplits: 1)
            headers[String(split[0])] = String(split[1][split[1].index(split[1].startIndex, offsetBy: 1)...split[1].index(split[1].endIndex, offsetBy: -2)])
        }
        
        guard let lenStr = headers["content-length"], let len = Int(lenStr) else {
            return nil
        }
        data += try await conn.receive(len: len) ?? Data()
        let body = data
        return Response(version: version, status: status, statusText: statusText, headers: headers, body: body)
    }

    var data: Data {
        body
    }

    var text: String? {
        String(data: data, encoding: .utf8)
    }

    var json: Any? {
        return try? JSONSerialization.jsonObject(with: data)
    }

    func json<T>(_ type: T.Type) async throws -> T where T: Decodable {
        let decoder = JSONDecoder()

        return try decoder.decode(type, from: data)
    }
}
