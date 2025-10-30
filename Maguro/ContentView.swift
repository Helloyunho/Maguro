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
                    onPressConnect()
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
    
    func onPressConnect() {
        Task {
            do {
                let url = Url(self.url)
                var text: String
                switch url.scheme {
                case "http", "https":
                    guard let resp = try await connect(url: url) else {
                        return
                    }
                    text = resp.text ?? "Failed to get text"
                case "file":
                    text = try String(contentsOf: .init(filePath: url.path), encoding: .utf8)
                case "data":
                    let dataURL = DataURL(self.url)
                    text = dataURL?.text ?? "Failed to get text"
                default:
                    text = "Unknown scheme."
                }
                result = parse(text)
            } catch {
                errorModel.error = error
                errorModel.showError = true
            }
        }
    }
    
    func connect(url: Url) async throws -> Response? {
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
