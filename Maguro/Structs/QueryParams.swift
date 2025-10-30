//
//  QueryParams.swift
//  Maguro
//
//  Created by Helloyunho on 2025/10/30.
//

struct QueryParams: ExpressibleByDictionaryLiteral {
    var params: [String: String] = [:]
    
    var text: String {
        params.map { "\($0)=\($1)" }.joined(separator: "&")
    }

    init(dictionaryLiteral elements: (String, String)...) {
        for (key, value) in elements {
            self.params[key.lowercased()] = value
        }
    }

    init(_ params: [String: String] = [:]) {
        for (key, value) in params {
            self.params[key.lowercased()] = value
        }
    }
    
    init(_ string: String) {
        for split in string.split(separator: "&").map({ $0.split(separator: "=", maxSplits: 1) }) {
            self.params[split[0].lowercased()] = String(split[1])
        }
    }

    mutating func set(key: String, value: String) {
        params[key.lowercased()] = value
    }

    mutating func remove(key: String) {
        params.removeValue(forKey: key.lowercased())
    }

    func get(key: String) -> String? {
        params[key.lowercased()]
    }

    mutating func clear() {
        params = [:]
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
    
    static func +(lhs: QueryParams, rhs: QueryParams) -> QueryParams {
        var result = lhs
        for (key, value) in rhs.params {
            result.params[key] = value
        }
        return result
    }
}
