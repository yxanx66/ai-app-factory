import SwiftUI

// MARK: - Data Models
enum SunExposure: String, CaseIterable {
    case fullSun = "Full Sun"
    case partialSun = "Partial Sun"
    case partialShade = "Partial Shade"
    case fullShade = "Full Shade"
    
    var icon: String {
        switch self {
        case .fullSun: return "sun.max.fill"
        case .partialSun: return "cloud.sun.fill"
        case .partialShade: return "cloud.fill"
        case .fullShade: return "moon.fill"
        }
    }
}

struct Plant: Identifiable {
    let id = UUID()
    let name: String
    let scientificName: String
    let sunlight: SunExposure
    let water: String
    let height: String
    let spread: String
    let description: String
    let zones: String
    let color: String
}

// MARK: - App Entry
@main
struct LandscapeApp: App {
    var body: some Scene {
        WindowGroup {
            TabBarView()
        }
    }
}

// MARK: - Tab Bar
struct TabBarView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PlantDatabaseView()
                .tabItem {
                    Label("Plants", systemImage: "leaf.fill")
                }
                .tag(0)
            
            SunlightAnalysisView()
                .tabItem {
                    Label("Sunlight", systemImage: "sun.max.fill")
                }
                .tag(1)
            
            AreaCalculatorView()
                .tabItem {
                    Label("Area", systemImage: "ruler")
                }
                .tag(2)
        }
        .tint(.green)
    }
}

// MARK: - Tab 1: Plant Database
struct PlantDatabaseView: View {
    let plants = PlantData.all
    
    var body: some View {
        NavigationStack {
            List(plants) { plant in
                NavigationLink(destination: PlantDetailView(plant: plant)) {
                    HStack(spacing: 14) {
                        Image(systemName: plantIcon(for: plant))
                            .font(.title2)
                            .foregroundColor(.green)
                            .frame(width: 40, height: 40)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(plant.name)
                                .font(.headline)
                            Text(plant.scientificName)
                                .font(.caption).italic()
                                .foregroundColor(.secondary)
                            HStack(spacing: 6) {
                                Image(systemName: plant.sunlight.icon)
                                    .font(.caption2)
                                Text(plant.sunlight.rawValue)
                                    .font(.caption)
                                Text("•")
                                    .foregroundColor(.secondary)
                                Text(plant.zones)
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Plant Database")
            .listStyle(.plain)
        }
    }
    
    private func plantIcon(for plant: Plant) -> String {
        switch plant.name {
        case "Lavender", "Roses": return "camera.macro"
        case "Japanese Maple", "Boxwood": return "tree.fill"
        case "Hydrangea": return "flower2"
        case "Hostas", "Ferns": return "leaf"
        case "Ornamental Grass": return "leaf.arrow.triangle.circlepath"
        case "Azalea": return "flower1"
        case "Sedum": return "circle.hexagongrid.fill"
        default: return "leaf.fill"
        }
    }
}

struct PlantDetailView: View {
    let plant: Plant
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(spacing: 6) {
                    Image(systemName: "camera.macro")
                        .font(.system(size: 56))
                        .foregroundColor(.green)
                    Text(plant.name)
                        .font(.largeTitle).bold()
                    Text(plant.scientificName)
                        .font(.title3).italic()
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                
                // Info Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    InfoCard(label: "Sunlight", value: plant.sunlight.rawValue,
                             icon: plant.sunlight.icon, color: .orange)
                    InfoCard(label: "Water", value: plant.water, icon: "drop.fill", color: .blue)
                    InfoCard(label: "Height", value: plant.height, icon: "arrow.up", color: .green)
                    InfoCard(label: "Spread", value: plant.spread, icon: "arrow.left.and.right", color: .green)
                    InfoCard(label: "Zones", value: plant.zones, icon: "map.fill", color: .brown)
                    InfoCard(label: "Color", value: plant.color, icon: "paintpalette.fill", color: .pink)
                }
                .padding(.horizontal)
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                    Text(plant.description)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoCard: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption).foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline).fontWeight(.medium)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }
}

// MARK: - Tab 2: Sunlight Analysis
struct SunlightAnalysisView: View {
    let orientations = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
    @State private var selectedOrientation = "S"
    @State private var season = "Summer"
    let seasons = ["Spring", "Summer", "Fall", "Winter"]
    
    var sunExposure: SunExposure {
        switch selectedOrientation {
        case "N": return .fullShade
        case "NE": return .partialShade
        case "E": return .partialSun
        case "SE": return .fullSun
        case "S": return .fullSun
        case "SW": return .fullSun
        case "W": return .fullSun
        case "NW": return .partialSun
        default: return .partialSun
        }
    }
    
    var recommendedPlants: [Plant] {
        PlantData.all.filter { $0.sunlight == sunExposure || $0.sunlight == .partialSun }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Compass
                    ZStack {
                        Circle()
                            .stroke(Color.green.opacity(0.2), lineWidth: 2)
                            .frame(width: 200, height: 200)
                        
                        CompassView(selected: $selectedOrientation, directions: orientations)
                        
                        VStack(spacing: 2) {
                            Image(systemName: "location.north.fill")
                                .font(.title2).foregroundColor(.green)
                            Text(selectedOrientation)
                                .font(.title).bold()
                        }
                    }
                    .padding()
                    
                    // Sun Exposure Result
                    VStack(spacing: 4) {
                        Image(systemName: sunExposure.icon)
                            .font(.system(size: 40))
                            .foregroundColor(exposureColor)
                        Text(sunExposure.rawValue)
                            .font(.title2).bold()
                        Text("\(season) • \(selectedOrientation) facing")
                            .font(.subheadline).foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(exposureColor.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Recommended Plants
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recommended Plants (\(recommendedPlants.count))")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(recommendedPlants) { plant in
                            HStack(spacing: 12) {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.green)
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(plant.name).font(.subheadline).fontWeight(.medium)
                                    Text(plant.sunlight.rawValue)
                                        .font(.caption).foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(plant.zones).font(.caption).foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Sunlight Analysis")
        }
    }
    
    private var exposureColor: Color {
        switch sunExposure {
        case .fullSun: return .orange
        case .partialSun: return .yellow
        case .partialShade: return .blue
        case .fullShade: return .purple
        }
    }
}

struct CompassView: View {
    @Binding var selected: String
    let directions: [String]
    
    var body: some View {
        ForEach(Array(directions.enumerated()), id: \.element) { i, dir in
            let angle = Double(i) * 45.0 - 90
            Button(action: { selected = dir }) {
                Text(dir)
                    .font(selected == dir ? .headline.bold() : .subheadline)
                    .foregroundColor(selected == dir ? .white : .secondary)
                    .frame(width: 36, height: 36)
                    .background(selected == dir ? Color.green : Color.clear)
                    .cornerRadius(18)
            }
            .position(
                x: 100 + 85 * cos(angle * .pi / 180),
                y: 100 + 85 * sin(angle * .pi / 180)
            )
            .frame(width: 36, height: 36)
        }
    }
}

// MARK: - Tab 3: Area Calculator
struct AreaCalculatorView: View {
    @State private var length: String = ""
    @State private var width: String = ""
    @State private var shape: ShapeType = .rectangle
    @State private var radius: String = ""
    @State private var areaResult: Double? = nil
    
    enum ShapeType: String, CaseIterable {
        case rectangle = "Rectangle"
        case circle = "Circle"
        case triangle = "Triangle"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Shape Picker
                    Picker("Shape", selection: $shape) {
                        ForEach(ShapeType.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Input Card
                    VStack(spacing: 16) {
                        switch shape {
                        case .rectangle, .triangle:
                            InputField(label: shape == .rectangle ? "Length (ft)" : "Base (ft)",
                                       value: $length, icon: "arrow.left.and.right")
                            InputField(label: shape == .rectangle ? "Width (ft)" : "Height (ft)",
                                       value: $width, icon: "arrow.up.and.down")
                        case .circle:
                            InputField(label: "Radius (ft)", value: $radius, icon: "circle")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Calculate
                    Button(action: calculate) {
                        Label("Calculate", systemImage: "equal.circle")
                            .font(.headline).frame(maxWidth: .infinity)
                            .padding().background(Color.green)
                            .foregroundColor(.white).cornerRadius(14)
                    }
                    .padding(.horizontal)
                    
                    // Result
                    if let area = areaResult {
                        VStack(spacing: 12) {
                            Text("Garden Area")
                                .font(.subheadline).foregroundColor(.secondary)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(String(format: "%.1f", area))
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.green)
                                Text("sq ft")
                                    .font(.title3).foregroundColor(.secondary)
                            }
                            
                            Text(String(format: "%.2f sq m", area * 0.092903))
                                .font(.headline).foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.08))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Plant density recommendation
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Planting Guide")
                                .font(.headline)
                            ForEach(plantDensityTips(for: area), id: \.self) { tip in
                                Label(tip, systemImage: "leaf")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Area Calculator")
        }
        .onTapGesture { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil) }
    }
    
    private func calculate() {
        switch shape {
        case .rectangle:
            guard let l = Double(length), let w = Double(width) else { areaResult = nil; return }
            areaResult = l * w
        case .circle:
            guard let r = Double(radius) else { areaResult = nil; return }
            areaResult = .pi * r * r
        case .triangle:
            guard let b = Double(length), let h = Double(width) else { areaResult = nil; return }
            areaResult = 0.5 * b * h
        }
    }
    
    private func plantDensityTips(for area: Double) -> [String] {
        [
            "Small shrubs (2-3 ft): ~\(Int(area / 4)) plants",
            "Medium shrubs (3-5 ft): ~\(Int(area / 9)) plants",
            "Ground cover (1 ft spacing): ~\(Int(area)) plants",
            "Recommended mulch: \(String(format: "%.1f", area * 0.2)) cu ft"
        ]
    }
}

struct InputField: View {
    let label: String
    @Binding var value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(label, systemImage: icon).font(.headline)
            TextField("Enter value", text: $value)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .font(.title3)
        }
    }
}

// MARK: - Plant Data
struct PlantData {
    static let all: [Plant] = [
        Plant(name: "Lavender", scientificName: "Lavandula angustifolia",
              sunlight: .fullSun, water: "Low", height: "1-3 ft",
              spread: "2-3 ft",
              description: "Fragrant purple flowers on silvery-green foliage. Drought-tolerant once established. Perfect for borders, rock gardens, and containers. Attracts pollinators.",
              zones: "5-9", color: "Purple"),
        
        Plant(name: "Japanese Maple", scientificName: "Acer palmatum",
              sunlight: .partialShade, water: "Moderate", height: "10-25 ft",
              spread: "10-20 ft",
              description: "Elegant ornamental tree with delicate, deeply-lobed leaves. Brilliant fall color in reds and oranges. Prefers sheltered位置 from strong wind.",
              zones: "5-8", color: "Red / Green"),
        
        Plant(name: "Hydrangea", scientificName: "Hydrangea macrophylla",
              sunlight: .partialSun, water: "High", height: "3-6 ft",
              spread: "3-6 ft",
              description: "Classic garden shrub with large globe-shaped flower clusters. Flower color varies by soil pH (blue in acidic, pink in alkaline). Long blooming season.",
              zones: "4-9", color: "Blue / Pink / White"),
        
        Plant(name: "Boxwood", scientificName: "Buxus sempervirens",
              sunlight: .partialSun, water: "Moderate", height: "2-8 ft",
              spread: "2-8 ft",
              description: "Evergreen shrub with dense, small glossy leaves. Ideal for hedges, topiary, and formal gardens. Very adaptable and easy to prune into shapes.",
              zones: "5-9", color: "Green"),
        
        Plant(name: "Hostas", scientificName: "Hosta spp.",
              sunlight: .fullShade, water: "Moderate", height: "1-3 ft",
              spread: "1-4 ft",
              description: "Shade-loving perennials with bold foliage in green, blue, gold, and variegated patterns. Low-maintenance and deer-resistant varieties available.",
              zones: "3-9", color: "Green / Variegated"),
        
        Plant(name: "Knock Out Roses", scientificName: "Rosa 'Knock Out'",
              sunlight: .fullSun, water: "Moderate", height: "3-4 ft",
              spread: "3-4 ft",
              description: "Easy-care shrub roses that bloom from spring to frost. Disease-resistant, self-cleaning (no deadheading needed). Available in several colors.",
              zones: "4-9", color: "Red / Pink / Yellow"),
        
        Plant(name: "Ornamental Grass", scientificName: "Miscanthus sinensis",
              sunlight: .fullSun, water: "Low to Moderate", height: "4-7 ft",
              spread: "3-5 ft",
              description: "Tall, graceful grass with feathery plumes in late summer. Adds movement and texture to landscapes. Good for screening and winter interest.",
              zones: "4-9", color: "Silver / Bronze"),
        
        Plant(name: "Ferns", scientificName: "Matteuccia struthiopteris",
              sunlight: .fullShade, water: "High", height: "2-4 ft",
              spread: "2-3 ft",
              description: "Classic shade garden plants with delicate, arching fronds. Ostrich fern is a popular choice for woodland gardens. Thrives in moist, rich soil.",
              zones: "3-8", color: "Green"),
        
        Plant(name: "Azalea", scientificName: "Rhododendron spp.",
              sunlight: .partialShade, water: "Moderate", height: "2-6 ft",
              spread: "2-5 ft",
              description: "Spring-blooming shrubs covered in vibrant flowers. Prefers acidic, well-drained soil. Evergreen varieties provide year-round structure.",
              zones: "5-9", color: "Pink / Red / White / Orange"),
        
        Plant(name: "Sedum", scientificName: "Sedum spectabile",
              sunlight: .fullSun, water: "Very Low", height: "1-2 ft",
              spread: "1-2 ft",
              description: "Succulent perennial with fleshy leaves and late-summer flower heads. Extremely drought-tolerant. Great for rock gardens, green roofs, and borders.",
              zones: "3-9", color: "Pink / Red / White"),
    ]
}
