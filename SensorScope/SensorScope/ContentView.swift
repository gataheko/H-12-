import SwiftUI

struct ContentView: View {
    @StateObject private var motion = MotionManager()
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "waveform.path")
                }
            
            AttitudeView()
                .tabItem {
                    Label("Attitude", systemImage: "rotate.3d")
                }
            
            ShakeView()
                .tabItem {
                    Label("Shake", systemImage: "hand.tap")
                }
        }
        .environmentObject(motion)
        .onAppear { motion.start() }
        .onDisappear { motion.stop() }
    }
}

#Preview {
    ContentView()
}
