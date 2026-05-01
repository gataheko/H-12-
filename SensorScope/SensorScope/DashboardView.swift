import SwiftUI

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject var motion: MotionManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Unavailable banner
                    if !motion.isAvailable {
                        UnavailableBanner()
                    }
                    
                    // Waveform
                    WaveformCard(history: motion.accelHistory)
                    
                    // Accelerometer card
                    SensorCard(
                        title: "Accelerometer",
                        icon: "arrow.up.and.down.and.arrow.left.and.right",
                        color: .blue,
                        axes: [
                            AxisRow(label: "X", value: motion.accelX, color: .red),
                            AxisRow(label: "Y", value: motion.accelY, color: .green),
                            AxisRow(label: "Z", value: motion.accelZ, color: .blue)
                        ]
                    )
                    
                    // Gyroscope card
                    SensorCard(
                        title: "Gyroscope  (rad/s)",
                        icon: "gyroscope",
                        color: .purple,
                        axes: [
                            AxisRow(label: "X", value: motion.gyroX, color: .orange),
                            AxisRow(label: "Y", value: motion.gyroY, color: .teal),
                            AxisRow(label: "Z", value: motion.gyroZ, color: .purple)
                        ]
                    )
                }
                .padding()
            }
            .navigationTitle("SensorScope")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Unavailable Banner
struct UnavailableBanner: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text("Device Motion unavailable — run on a real device for live data.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.yellow.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Waveform Card
struct WaveformCard: View {
    let history: [Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Acceleration Magnitude", systemImage: "waveform")
                .font(.headline)
            
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let max = history.max() ?? 1.0
                let step = w / CGFloat(history.count - 1)
                
                ZStack {
                    // Fill
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: h))
                        for (i, val) in history.enumerated() {
                            let x = CGFloat(i) * step
                            let norm = CGFloat(val / max(max, 0.01))
                            let y = h - norm * h
                            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        path.addLine(to: CGPoint(x: w, y: h))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.5), .blue.opacity(0.05)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    
                    // Stroke
                    Path { path in
                        for (i, val) in history.enumerated() {
                            let x = CGFloat(i) * step
                            let norm = CGFloat(val / max(max, 0.01))
                            let y = h - norm * h
                            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2)
                }
            }
            .frame(height: 90)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Sensor Card
struct SensorCard: View {
    let title: String
    let icon: String
    let color: Color
    let axes: [AxisRow]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(color)
            
            ForEach(axes) { row in
                AxisRowView(row: row)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Axis Row Model + View
struct AxisRow: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let color: Color
}

struct AxisRowView: View {
    let row: AxisRow
    
    var body: some View {
        HStack(spacing: 12) {
            Text(row.label)
                .font(.system(.body, design: .monospaced).bold())
                .foregroundStyle(row.color)
                .frame(width: 20)
            
            // Bar
            GeometryReader { geo in
                let w = geo.size.width
                let clamped = min(abs(row.value), 2.0)
                let barW = CGFloat(clamped / 2.0) * (w / 2)
                
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule().fill(Color(.systemGray5)).frame(height: 8)
                    
                    // Positive / negative bar
                    HStack(spacing: 0) {
                        if row.value < 0 {
                            Spacer()
                            Capsule()
                                .fill(row.color)
                                .frame(width: barW, height: 8)
                        } else {
                            Spacer()
                            Capsule()
                                .fill(row.color)
                                .frame(width: barW, height: 8)
                        }
                    }
                    .frame(width: w / 2 + (row.value >= 0 ? barW : -barW), alignment: row.value >= 0 ? .trailing : .leading)
                }
            }
            .frame(height: 8)
            
            Text(String(format: "% .3f", row.value))
                .font(.system(.callout, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 72, alignment: .trailing)
        }
    }
}
