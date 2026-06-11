import SwiftUI

// MARK: - 暖通管道尺寸计算器 / HVAC Duct Size Calculator

struct ContentView: View {
    @State private var airflow: String = ""
    @State private var velocity: String = ""
    @State private var isImperial: Bool = true
    @State private var diameter: Double? = nil
    @State private var showFrictionNote: Bool = false
    
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
                
                Spacer()
            }
        }
        .onTapGesture { hideKeyboard() }
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
        return standards.min(by: { abs($0 - Int(inches.rounded())) < abs($1 - Int(inches.rounded())) }) ?? 6
    }
    
    private func rectangularEquivalents(roundDia: Double) -> [String] {
        let aspectRatios = [(1, 1), (1.5, 1), (2, 1)]
        let area = .pi * pow(roundDia / 2, 2)
        return aspectRatios.map { (w, h) in
            let width = sqrt(area * Double(w) / Double(h))
            let height = area / width
            return "\(Int(width.rounded()))×\(Int(height.rounded())) in"
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
