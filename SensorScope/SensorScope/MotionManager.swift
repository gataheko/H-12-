import Foundation
import CoreMotion
import Combine

class MotionManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var accelX: Double = 0.0
    @Published var accelY: Double = 0.0
    @Published var accelZ: Double = 0.0
    
    @Published var gyroX: Double = 0.0
    @Published var gyroY: Double = 0.0
    @Published var gyroZ: Double = 0.0
    
    @Published var pitch: Double = 0.0
    @Published var roll:  Double = 0.0
    @Published var yaw:   Double = 0.0
    
    @Published var isShaking: Bool = false
    @Published var shakeCount: Int = 0
    @Published var isAvailable: Bool = false
    
    // Rolling history for the waveform (last 60 samples)
    @Published var accelHistory: [Double] = Array(repeating: 0, count: 60)
    
    // MARK: - Private
    private let motionManager = CMMotionManager()
    private let updateInterval: TimeInterval = 1.0 / 30.0   // 30 Hz
    private let shakeThreshold: Double = 2.5
    private var shakeCooldown = false
    
    // MARK: - Public Helpers
    func resetShakeCount() {
        shakeCount = 0
    }
    
    // MARK: - Start / Stop
    func start() {
        isAvailable = motionManager.isDeviceMotionAvailable
        
        guard isAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion, error == nil else { return }
            self.process(motion)
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    // MARK: - Processing
    private func process(_ motion: CMDeviceMotion) {
        // Accelerometer (user)
        accelX = motion.userAcceleration.x
        accelY = motion.userAcceleration.y
        accelZ = motion.userAcceleration.z
        
        // Gyroscope
        gyroX = motion.rotationRate.x
        gyroY = motion.rotationRate.y
        gyroZ = motion.rotationRate.z
        
        // Attitude (pitch / roll / yaw in radians)
        pitch = motion.attitude.pitch
        roll  = motion.attitude.roll
        yaw   = motion.attitude.yaw
        
        // Waveform history — use total acceleration magnitude
        let magnitude = sqrt(accelX*accelX + accelY*accelY + accelZ*accelZ)
        accelHistory.removeFirst()
        accelHistory.append(magnitude)
        
        // Shake detection
        if magnitude > shakeThreshold && !shakeCooldown {
            isShaking = true
            shakeCount += 1
            shakeCooldown = true
            // Reset after 0.4 s
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.isShaking = false
                self.shakeCooldown = false
            }
        }
    }
}
