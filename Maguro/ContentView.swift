//
//  ContentView.swift
//  Maguro
//
//  Created by Helloyunho on 2025/10/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State var url = ""
    @State var result: String?
    @State var errorModel = ErrorModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("URL")
                    TextField("Type URL", text: $url)
                        .frame(width: 200)
                    #if !os(macOS)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                    #endif
                        .disableAutocorrection(true)
                }
                Button("Connect") {
                    Task {
                        do {
                            guard let resp = try await connect() else {
                                return
                            }
                            result = parse(resp.text ?? "Failed to get text")
                        } catch {
                            errorModel.error = error
                            errorModel.showError = true
                        }
                    }
                }
                ScrollView {
                    Text(result ?? "")
                }
            }
        }
        .alert("Error", isPresented: $errorModel.showError, presenting: errorModel.error) { _ in
        } message: { error in
            Text(error.localizedDescription)
        }
    }
    
    func connect() async throws -> Response? {
        let url = Url(url)
        let req = Request(url: url)
        let conn = Connection(req)
        return try await conn.send()
    }
    
    func parse(_ body: String) -> String {
        let parser = HTMLParser(body)
        parser.parse()
        return parser.parsedText
    }
}

#Preview {
    ContentView()
}
