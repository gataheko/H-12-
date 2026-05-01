# SensorScope 📡

A SwiftUI iOS app that reads **real-time sensor data** using **Core Motion**.  
Built for the iOS Device Capabilities assignment (Option B — Sensor Integration).

---

## Features

| Screen | What it shows |
|---|---|
| **Dashboard** | Live accelerometer (X/Y/Z) + gyroscope (X/Y/Z) with animated bar meters and a scrolling waveform graph |
| **Attitude** | 3D phone silhouette that physically rotates on screen matching your device's pitch and roll; numeric pitch/roll/yaw in degrees |
| **Shake Detector** | Counts shakes in real time using an acceleration-magnitude threshold; animated visual feedback |

---

## Requirements

- Xcode 15+
- iOS 17+ deployment target
- **Real iPhone or iPad** — the Simulator does not provide real motion data

---

## Setup & Run

1. **Clone / download** this repo.
2. Open `SensorScope.xcodeproj` in Xcode.
3. Select your connected iPhone as the run destination.
4. Sign the app: go to **Signing & Capabilities** → set your Apple ID team.
5. Press **⌘R** to build and run.

No extra dependencies or CocoaPods needed — Core Motion is built into iOS.

---

## Project Structure

```
SensorScope/
├── SensorScope.xcodeproj/
│   └── project.pbxproj
└── SensorScope/
    ├── SensorScopeApp.swift     ← @main entry point
    ├── ContentView.swift        ← TabView (3 tabs)
    ├── MotionManager.swift      ← ObservableObject wrapping CMMotionManager
    ├── DashboardView.swift      ← Accelerometer + Gyro readings + waveform
    ├── AttitudeView.swift       ← 3D tilt visualizer (pitch / roll / yaw)
    ├── ShakeView.swift          ← Shake counter with magnitude meter
    └── Info.plist               ← NSMotionUsageDescription key
```

---

## Key APIs Used

- **`CMMotionManager.startDeviceMotionUpdates`** — provides fused sensor data (accelerometer + gyroscope + magnetometer) at 30 Hz
- **`CMDeviceMotion.userAcceleration`** — gravity-removed acceleration
- **`CMDeviceMotion.rotationRate`** — raw gyroscope in rad/s
- **`CMDeviceMotion.attitude`** — pitch, roll, yaw in radians (Euler angles)
- **`rotation3DEffect`** — SwiftUI modifier used to tilt the phone silhouette

---

## Permissions

`Info.plist` contains the required `NSMotionUsageDescription` key.  
Core Motion does **not** show a user prompt at runtime on iOS 17+ for accelerometer/gyroscope access (prompt is only needed for step counting / CMPedometer).

---

## Screenshots

| Dashboard | Attitude | Shake |
|---|---|---|
| Bar meters + waveform | Tilting phone graphic | Shake counter |

---

## GitHub Submission

```bash
git init
git add .
git commit -m "Initial SensorScope submission"
git remote add origin https://github.com/YOUR_USERNAME/SensorScope.git
git push -u origin main
```
