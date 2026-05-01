import SwiftUI

struct AttitudeView: View {
    @EnvironmentObject var motion: MotionManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                // 3D phone silhouette that tilts with pitch/roll
                PhoneTiltView(pitch: motion.pitch, roll: motion.roll)
                    .frame(height: 280)
                    .padding()
                
                // Numeric readouts
                VStack(spacing: 12) {
                    AttitudeRow(label: "Pitch", value: motion.pitch, color: .indigo,
                                description: "Forward / backward tilt")
                    AttitudeRow(label: "Roll",  value: motion.roll,  color: .teal,
                                description: "Left / right tilt")
                    AttitudeRow(label: "Yaw",   value: motion.yaw,   color: .orange,
                                description: "Rotation around vertical axis")
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Attitude")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Phone Tilt View
struct PhoneTiltView: View {
    let pitch: Double   // radians
    let roll: Double    // radians
    
    // Clamp for visual safety
    var clampedPitch: Double { max(-1.2, min(1.2, pitch)) }
    var clampedRoll:  Double { max(-1.2, min(1.2, roll)) }
    
    var body: some View {
        ZStack {
            // Grid background
            GridBackground()
            
            // Phone shape
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [Color(.systemGray2), Color(.systemGray4)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 200)
                .overlay(
                    // Screen
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black)
                        .padding(8)
                        .overlay(
                            VStack(spacing: 4) {
                                Image(systemName: "gyroscope")
                                    .font(.largeTitle)
                                    .foregroundStyle(.blue)
                                Text("Live")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                            }
                        )
                )
                .shadow(radius: 20)
                // Apply rotation3D using pitch (x-axis) and roll (y-axis)
                .rotation3DEffect(.radians(clampedPitch), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.radians(clampedRoll),  axis: (x: 0, y: 1, z: 0))
                .animation(.interpolatingSpring(stiffness: 120, damping: 18), value: pitch)
                .animation(.interpolatingSpring(stiffness: 120, damping: 18), value: roll)
        }
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Grid Background
struct GridBackground: View {
    var body: some View {
        Canvas { ctx, size in
            let spacing: CGFloat = 24
            ctx.stroke(
                {
                    var p = Path()
                    var x: CGFloat = 0
                    while x <= size.width {
                        p.move(to: CGPoint(x: x, y: 0))
                        p.addLine(to: CGPoint(x: x, y: size.height))
                        x += spacing
                    }
                    var y: CGFloat = 0
                    while y <= size.height {
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: size.width, y: y))
                        y += spacing
                    }
                    return p
                }(),
                with: .color(.blue.opacity(0.08)),
                lineWidth: 1
            )
        }
    }
}

// MARK: - Attitude Row
struct AttitudeRow: View {
    let label: String
    let value: Double
    let color: Color
    let description: String
    
    /// Degrees, one decimal
    var degrees: String {
        String(format: "%.1f°", value * 180 / .pi)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.headline).foregroundStyle(color)
                Text(description).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(degrees)
                .font(.system(.title3, design: .monospaced).bold())
                .foregroundStyle(color)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
