//
//  Headers.swift
//  Maguro
//
//  Created by Helloyunho on 2025/10/26.
//

struct Headers: ExpressibleByDictionaryLiteral {
    var headers: [String: String] = [:]

    init(dictionaryLiteral elements: (String, String)...) {
        for (key, value) in elements {
            self.headers[key.lowercased()] = value
        }
    }

    init(_ headers: [String: String] = [:]) {
        for (key, value) in headers {
            self.headers[key.lowercased()] = value
        }
    }

    mutating func set(key: String, value: String) {
        headers[key.lowercased()] = value
    }

    mutating func remove(key: String) {
        headers.removeValue(forKey: key.lowercased())
    }

    func get(key: String) -> String? {
        headers[key.lowercased()]
    }

    mutating func clear() {
        headers = [:]
    }

    subscript(key: String) -> String? {
        get {
            get(key: key)
        }
        mutating set {
            if let newValue {
                set(key: key, value: newValue)
            } else {
                remove(key: key)
            }
        }
    }
    
    static func +(lhs: Headers, rhs: Headers) -> Headers {
        var result = lhs
        for (key, value) in rhs.headers {
            result.headers[key] = value
        }
        return result
    }
}
