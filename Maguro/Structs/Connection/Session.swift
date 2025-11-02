//
//  Session.swift
//  Maguro
//
//  Created by Helloyunho on 2025/11/2.
//

import Foundation

class Session {
    struct Key: Hashable {
        let host: String
        let port: UInt16?
    }
    var connections: [Key: Connection] = [:]
    
    func send(_ req: Request) async throws -> Response? {
        let key = Key(host: req.url.host, port: req.url.port)
        if !connections.keys.contains(key) {
            connections[key] = Connection(req)
        }
        let resp = try await connections[key]?.send(req)
        return resp
    }
}
