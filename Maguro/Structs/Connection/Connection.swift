//
//  Connection.swift
//  Maguro
//
//  Created by Helloyunho on 2025/10/27.
//

import Foundation
import Network

class Connection: Hashable {
    static func == (lhs: Connection, rhs: Connection) -> Bool {
        lhs.sock === rhs.sock
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(sock as AnyObject))
    }

    let MAX_DATA_LEN = 65536

    let dispatchQueue: DispatchQueue = .global()
    var sock: NWConnection
    
    private var data = Data()
    private var isDone = false
    private var error: Error?
    
    init(_ req: Request) {
        sock = NWConnection(to: .url(req.url.url), using: req.url.scheme == "https" ? .tls : .tcp)
        sock.start(queue: dispatchQueue)
    }
    
    deinit {
        disconnect()
    }

    func send(_ req: Request) async throws -> Response? {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            sock.send(
                content: req.raw,
                completion: .contentProcessed { err in
                    if let err {
                        continuation.resume(throwing: err)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            )
        }
        
        return try await Response.read(conn: self)
    }
    
    func disconnect() {
        sock.cancel()
    }
    
    func receive(len: Int = 65536) async throws -> Data? {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data?, Error>) in
            self.sock.receive(minimumIncompleteLength: 0, maximumLength: len) { data, _, _, error in
                if let data, !data.isEmpty {
                    continuation.resume(returning: data)
                    return
                }
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: nil)
            }
        }
    }
}

