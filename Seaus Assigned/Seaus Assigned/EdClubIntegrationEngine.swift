import SwiftUI
import WebKit

#if os(iOS) || os(macOS)
struct EdClubSyncButton: View {
    @Binding var assignments: [TaskAssignment]
    @State private var isSyncing = false
    @State private var showWebAuthSheet = false
    @State private var schoolCode = ""
    @State private var showSetupModal = false
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: {
                showSetupModal = true
            }) {
                HStack {
                    Image(systemName: isSyncing ? "arrow.triangle.2.circlepath" : "arrow.down.doc.fill")
                    Text(isSyncing ? "Syncing EdClub..." : "Connect EdClub")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.orange)
            .disabled(isSyncing)
            .sheet(isPresented: $showSetupModal) {
                VStack(spacing: 15) {
                    Text("EdClub School Connection").font(.headline)
                    Text("Enter your custom school code or district subdomain to load your custom login interface.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    TextField("School Code (e.g., lwsd414)", text: $schoolCode)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                    
                    HStack {
                        Button("Cancel") { showSetupModal = false }
                        Spacer()
                        Button("Open Portal") {
                            showSetupModal = false
                            showWebAuthSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.blue)
                    }
                }
                .padding()
                .frame(width: 320)
            }
            .sheet(isPresented: $showWebAuthSheet) {
                VStack(spacing: 0) {
                    HStack {
                        Text("Sign In to EdClub Portal").font(.headline)
                        Spacer()
                        Button("Cancel") { showWebAuthSheet = false }
                    }
                    .padding()
                    .background(Color.black.opacity(0.05))
                    
                    Divider()
                    
                    EdClubWebViewContainer(schoolCode: schoolCode, isSyncing: $isSyncing, showSheet: $showWebAuthSheet, assignments: $assignments)
                }
                .frame(minWidth: 600, minHeight: 650)
            }
        }
    }
}

struct EdClubWebViewContainer: NSViewRepresentable {
    let schoolCode: String
    @Binding var isSyncing: Bool
    @Binding var showSheet: Bool
    @Binding var assignments: [TaskAssignment]
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        let cleanSubdomain = schoolCode.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let destinationUrlString = cleanSubdomain.isEmpty ? "https://www.typingclub.com/login.html" : "https://\(cleanSubdomain).edclub.com"
        
        if let url = URL(string: destinationUrlString) {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: EdClubWebViewContainer
        private var dataExtracted = false
        
        init(_ parent: EdClubWebViewContainer) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard let url = webView.url?.absoluteString.lowercased() else { return }
            
            if (url.contains("edclub.com/dashboard") || url.contains("typingclub.com/dashboard") || url.contains("/student/")) && !dataExtracted {
                dataExtracted = true
                parent.isSyncing = true
                parent.showSheet = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak webView] in
                    let scrapeJS = """
                    var titles = Array.from(document.querySelectorAll('.assignment-name, .lesson-title, .module-name, h4, .attempt-name')).map(e => e.innerText);
                    var statuses = Array.from(document.querySelectorAll('.assignment-status, .badge, .status-text, .score')).map(e => e.innerText);
                    JSON.stringify({titles: titles, statuses: statuses});
                    """
                    
                    webView?.evaluateJavaScript(scrapeJS) { [weak self] result, error in
                        guard let self = self else { return }
                        if let jsonString = result as? String,
                           let data = jsonString.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: [String]] {
                            
                            let titles = json["titles"] ?? []
                            let statuses = json["statuses"] ?? []
                            
                            DispatchQueue.main.async {
                                for i in 0..<titles.count {
                                    let taskTitle = titles[i].trimmingCharacters(in: .whitespacesAndNewlines)
                                    if taskTitle.isEmpty || taskTitle.count < 3 { continue }
                                    
                                    let rawStatus = i < statuses.count ? statuses[i] : "Pending"
                                    let finalStatus = rawStatus.lowercased().contains("complete") || rawStatus.lowercased().contains("stars") ? "Completed" : "In Progress"
                                    
                                    if !self.parent.assignments.contains(where: { $0.title == taskTitle }) {
                                        self.parent.assignments.append(TaskAssignment(
                                            title: taskTitle,
                                            studentName: "EdClub Sync",
                                            className: "Typing Lab",
                                            status: finalStatus,
                                            externalProvider: "EdClub"
                                        ))
                                    }
                                }
                                self.parent.isSyncing = false
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.parent.isSyncing = false
                            }
                        }
                    }
                }
            }
        }
    }
}
#endif
