import SwiftUI
import MessageUI

// MARK: - 暖通管道尺寸计算器 / HVAC Duct Size Calculator

struct ContentView: View {
    @State private var airflow: String = ""
    @State private var velocity: String = ""
    @State private var isImperial: Bool = true
    @State private var diameter: Double? = nil
    @State private var showAbout = false
    @State private var showFeedback = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    private let appVersion = "1.0"
    private let buildNumber = "1"
    private let feedbackEmail = "hvac.feedback@ai-app-factory.com"
    
    private var velocityRange: (min: Double, max: Double) {
        isImperial ? (300, 1200) : (1.5, 6.0)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 4) {
                    Image(systemName: "wind")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    Text("Duct Size Calculator")
                        .font(.largeTitle).bold()
                    Text("HVAC Round Duct Sizing")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Unit Toggle
                Picker("Unit", selection: $isImperial) {
                    Text("Imperial (CFM / FPM)").tag(true)
                    Text("Metric (m³/s / m/s)").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Input Card
                VStack(spacing: 16) {
                    // Airflow input
                    VStack(alignment: .leading, spacing: 6) {
                        Label(isImperial ? "Airflow (CFM)" : "Airflow (m³/s)",
                              systemImage: "arrow.triangle.swap")
                            .font(.headline)
                        HStack {
                            TextField(isImperial ? "e.g. 400" : "e.g. 0.19",
                                      text: $airflow)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .font(.title3)
                            Text(isImperial ? "CFM" : "m³/s")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Velocity input
                    VStack(alignment: .leading, spacing: 6) {
                        Label(isImperial ? "Velocity (FPM)" : "Velocity (m/s)",
                              systemImage: "gauge.medium")
                            .font(.headline)
                        HStack {
                            TextField(isImperial ? "e.g. 700" : "e.g. 3.5",
                                      text: $velocity)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .font(.title3)
                            Text(isImperial ? "FPM" : "m/s")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Velocity range hint
                    if let v = Double(velocity), !velocity.isEmpty {
                        if v < velocityRange.min || v > velocityRange.max {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.orange)
                                Text(isImperial
                                    ? "Typical range: \(Int(velocityRange.min))–\(Int(velocityRange.max)) FPM"
                                    : "Typical range: \(String(format: "%.1f", velocityRange.min))–\(String(format: "%.1f", velocityRange.max)) m/s")
                                    .font(.caption).foregroundColor(.orange)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Calculate Button
                Button(action: calculate) {
                    Label("Calculate Diameter", systemImage: "equal.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
                
                // Result Card
                if let d = diameter {
                    VStack(spacing: 12) {
                        Text("Recommended Round Duct Diameter")
                            .font(.subheadline).foregroundColor(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%.1f", d))
                                .font(.system(size: 56, weight: .bold))
                                .foregroundColor(.blue)
                            Text(isImperial ? "in" : "mm")
                                .font(.title2).foregroundColor(.secondary)
                        }
                        
                        if isImperial {
                            Text("Standard duct size: \(nearestStandardSize(d)) in")
                                .font(.headline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // Quick reference
                        VStack(spacing: 4) {
                            Text("Equivalent Rectangular Sizes")
                                .font(.caption).foregroundColor(.secondary)
                            let roundInch = isImperial ? d : d / 25.4
                            let eqSizes = rectangularEquivalents(roundDia: roundInch)
                            ForEach(eqSizes.prefix(3), id: \.self) { s in
                                Text(s)
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                // HVAC Reference
                VStack(alignment: .leading, spacing: 8) {
                    Label("Reference", systemImage: "book.fill")
                        .font(.headline)
                    HStack {
                        DotColor.good
                        Text("Main duct supply: 700–900 FPM")
                    }
                    HStack {
                        DotColor.ok
                        Text("Branch duct: 400–600 FPM")
                    }
                    HStack {
                        DotColor.caution
                        Text("Return duct: 300–500 FPM")
                    }
                }
                .font(.caption)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Bottom buttons
                VStack(spacing: 12) {
                    Divider()
                    HStack(spacing: 24) {
                        Button(action: { showAbout = true }) {
                            Label("About", systemImage: "info.circle")
                                .font(.caption)
                        }
                        Button(action: { showFeedback = true }) {
                            Label("Feedback", systemImage: "envelope")
                                .font(.caption)
                        }
                        Button(action: requestReview) {
                            Label("Rate App", systemImage: "star")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.secondary)
                    Text("v\(appVersion) (build \(buildNumber))")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .padding(.bottom, 24)
                
                Spacer()
            }
        }
        .onTapGesture { hideKeyboard() }
        .sheet(isPresented: $showAbout) {
            AboutView(dismiss: { showAbout = false })
        }
        .sheet(isPresented: $showFeedback) {
            FeedbackView(dismiss: { showFeedback = false },
                         email: feedbackEmail,
                         version: appVersion)
        }
    }
    
    // MARK: - Calculation
    private func calculate() {
        guard let q = Double(airflow), let v = Double(velocity), q > 0, v > 0 else {
            diameter = nil
            return
        }
        
        if isImperial {
            // Diameter (in) = 24 * √(CFM / (FPM * π))
            diameter = 24 * sqrt(q / (v * .pi))
        } else {
            // Diameter (mm) = 2000 * √(m³/s / (m/s * π))
            diameter = 2000 * sqrt(q / (v * .pi))
        }
    }
    
    private func nearestStandardSize(_ inches: Double) -> Int {
        let standards = [4, 5, 6, 7, 8, 9, 10, 12, 14, 16, 18, 20, 22, 24]
        // Fixed BUG-001: compare using raw double, not rounded int
        return standards.min(by: { abs(Double($0) - inches) < abs(Double($1) - inches) }) ?? 6
    }
    
    private func requestReview() {
        guard let url = URL(string: "https://apps.apple.com/app/id0000000000?action=write-review") else { return }
        UIApplication.shared.open(url)
    }
    
    private func rectangularEquivalents(roundDia: Double) -> [String] {
        let aspectRatios = [(1, 1), (1.5, 1), (2, 1)]
        let area = .pi * pow(roundDia / 2, 2)
        return aspectRatios.map { (w, h) in
            let width = sqrt(area * Double(w) / Double(h))
            let height = area / width
            return "\(Int(width.rounded()))×\(Int(height.rounded())) in (approx)"
        }
    }
}

// MARK: - About View
struct AboutView: View {
    let dismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "wind")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                        .padding(.top, 32)
                    
                    Text("Duct Calculator")
                        .font(.title).bold()
                    Text("HVAC Round Duct Sizing Tool")
                        .font(.subheadline).foregroundColor(.secondary)
                    
                    VStack(spacing: 6) {
                        Text("Version 1.0 (Build 1)")
                            .font(.caption)
                        Text("© 2026 AI App Factory")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    
                    Divider().padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Formula Reference")
                            .font(.headline)
                        Text("Uses the standard HVAC duct sizing formula: D = 24 × √(CFM / (FPM × π)) for imperial, and D = 2000 × √(m³/s / (m/s × π)) for metric. Results are rounded to standard duct sizes per industry practice. Rectangular equivalents are approximate (equal-area method).")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    Divider().padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        Link(destination: URL(string: "https://ai-app-factory.com/privacy")!) {
                            Label("Privacy Policy", systemImage: "hand.raised")
                                .font(.subheadline)
                        }
                        Link(destination: URL(string: "mailto:hvac.feedback@ai-app-factory.com")!) {
                            Label("Contact Support", systemImage: "envelope")
                                .font(.subheadline)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Feedback View
struct FeedbackView: View {
    let dismiss: () -> Void
    let email: String
    let version: String
    
    @State private var selectedType: FeedbackType = .bug
    @State private var message: String = ""
    @State private var showMailComposer = false
    
    enum FeedbackType: String, CaseIterable {
        case bug = "Report a Bug"
        case feature = "Feature Request"
        case other = "Other / General"
        
        var icon: String {
            switch self {
            case .bug: return "ant"
            case .feature: return "lightbulb"
            case .other: return "ellipsis.bubble"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Type picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What's on your mind?")
                            .font(.headline)
                        Picker("Type", selection: $selectedType) {
                            ForEach(FeedbackType.allCases, id: \.self) { type in
                                Label(type.rawValue, systemImage: type.icon).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal)
                    
                    // Message
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Details")
                            .font(.headline)
                        TextEditor(text: $message)
                            .frame(minHeight: 140)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Version info
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.secondary)
                        Text("App v\(version) · iOS \(UIDevice.current.systemVersion)")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    
                    // Send button
                    Button(action: { showMailComposer = true }) {
                        Label("Send Feedback", systemImage: "paperplane.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(message.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .disabled(message.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showMailComposer) {
                if MFMailComposeViewController.canSendMail() {
                    MailComposer(
                        subject: "[\(selectedType.rawValue)] Duct Calculator Feedback",
                        recipients: [email],
                        body: """
                        \(message)
                        
                        
                        ---
                        App Version: \(version)
                        iOS: \(UIDevice.current.systemVersion)
                        Device: \(UIDevice.current.model)
                        """,
                        result: { result in
                            showMailComposer = false
                            if case .success(_) = result {
                                dismiss()
                            }
                        }
                    )
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "envelope.circle")
                            .font(.system(size: 48)).foregroundColor(.blue)
                        Text("No email account configured")
                            .font(.headline)
                        Text("Please email us directly at:")
                            .font(.subheadline).foregroundColor(.secondary)
                        Text(email)
                            .font(.subheadline).bold()
                            .foregroundColor(.blue)
                        Button("OK") { showMailComposer = false }
                            .padding(.top)
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - Mail Composer (UIKit bridge)
struct MailComposer: UIViewControllerRepresentable {
    let subject: String
    let recipients: [String]
    let body: String
    let result: (Result<MFMailComposeResult, Error>) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(result: result)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setSubject(subject)
        vc.setToRecipients(recipients)
        vc.setMessageBody(body, isHTML: false)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let result: (Result<MFMailComposeResult, Error>) -> Void
        init(result: @escaping (Result<MFMailComposeResult, Error>) -> Void) {
            self.result = result
        }
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            controller.dismiss(animated: true) {
                if let error = error {
                    self.result(.failure(error))
                } else {
                    self.result(.success(result))
                }
            }
        }
    }
}

// MARK: - Helper Views
enum DotColor {
    static var good: some View { Circle().fill(Color.green).frame(width: 8, height: 8) }
    static var ok: some View { Circle().fill(Color.orange).frame(width: 8, height: 8) }
    static var caution: some View { Circle().fill(Color.yellow).frame(width: 8, height: 8) }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
    }
}
