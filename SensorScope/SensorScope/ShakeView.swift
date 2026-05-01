import SwiftUI

struct ShakeView: View {
    @EnvironmentObject var motion: MotionManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                // Shake indicator
                ZStack {
                    Circle()
                        .fill(motion.isShaking ? Color.orange : Color(.systemGray5))
                        .frame(width: 200, height: 200)
                        .animation(.spring(response: 0.3, dampingFraction: 0.4), value: motion.isShaking)
                    
                    VStack(spacing: 8) {
                        Image(systemName: motion.isShaking ? "iphone.gen3.radiowaves.left.and.right" : "iphone.gen3")
                            .font(.system(size: 64))
                            .foregroundStyle(motion.isShaking ? .white : .secondary)
                            .symbolEffect(.bounce, value: motion.isShaking)
                        
                        if motion.isShaking {
                            Text("SHAKE!")
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .scaleEffect(motion.isShaking ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.4), value: motion.isShaking)
                
                // Count
                VStack(spacing: 4) {
                    Text("\(motion.shakeCount)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(motion.shakeCount > 0 ? .orange : .secondary)
                        .contentTransition(.numericText())
                        .animation(.spring, value: motion.shakeCount)
                    
                    Text("shakes detected")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
                // Magnitude meter
                VStack(alignment: .leading, spacing: 6) {
                    Text("Current Magnitude")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    let magnitude = sqrt(
                        motion.accelX * motion.accelX +
                        motion.accelY * motion.accelY +
                        motion.accelZ * motion.accelZ
                    )
                    let clamped = min(magnitude, 4.0)
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(.systemGray5))
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.yellow, .orange, .red],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * CGFloat(clamped / 4.0))
                                .animation(.easeOut(duration: 0.1), value: magnitude)
                        }
                        .frame(height: 14)
                    }
                    .frame(height: 14)
                    
                    HStack {
                        Text("0")
                        Spacer()
                        Text("Threshold: 2.5")
                            .foregroundStyle(.orange)
                        Spacer()
                        Text("4+")
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
                
                // Reset button
                Button {
                    // Using a trick: reset is done via the MotionManager
                    // We'll add a resetShake helper
                    motion.resetShakeCount()
                } label: {
                    Label("Reset Count", systemImage: "arrow.counterclockwise")
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                
                Spacer()
            }
            .navigationTitle("Shake Detector")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
