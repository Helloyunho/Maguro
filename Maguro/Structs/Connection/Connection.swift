//
//  Connection.swift
//  Maguro
//
//  Created by Helloyunho on 2025/10/27.
//

import Foundation
import Network

class Connection {
    let MAX_DATA_LEN = 65536

    let dispatchQueue: DispatchQueue = .global()
    let sock: NWConnection
    let req: Request
    
    private var data = Data()
    private var isDone = false
    private var error: Error?
    
    init(_ request: Request) {
        sock = NWConnection(to: .url(request.url.url), using: request.url.scheme == "https" ? .tls : .tcp)
        req = request
    }

    func send() async throws -> Response? {
        sock.start(queue: dispatchQueue)
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
        
        self.receive()
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.global().async {
                while !self.isDone {}
                if let error = self.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
        
        return Response(data)
    }
    
    func disconnect() {
        sock.cancel()
    }
    
    private func receive() {
        self.sock.receive(minimumIncompleteLength: 0, maximumLength: MAX_DATA_LEN) { data, _, isDone, error in
            if let data, !data.isEmpty {
                self.data += data
                if data.count < self.MAX_DATA_LEN {
                    self.isDone = true
                    self.disconnect()
                    return
                }
            }
            if let error {
                self.isDone = true
                self.error = error
                self.disconnect()
                return
            }
            if isDone {
                self.isDone = true
                self.disconnect()
                return
            }
            self.receive()
        }
    }
}
