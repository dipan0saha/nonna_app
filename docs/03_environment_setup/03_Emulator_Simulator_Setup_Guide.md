# Emulator/Simulator Setup Guide

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Development Lead  
**Status**: Final  
**Section**: 2.1 - Flutter Environment Setup

## Executive Summary

This document provides comprehensive guidance for setting up Android emulators, iOS simulators, and physical device testing environments for the Nonna App project. It includes installation instructions, configuration guidelines, troubleshooting steps, and best practices for cross-platform mobile development.

## References

This document aligns with:
- `docs/03_environment_setup/01_Flutter_Installation_Verification_Report.md` - Flutter SDK setup
- `docs/03_environment_setup/02_IDE_Configuration_Document.md` - IDE configuration
- `docs/01_technical_requirements/non_functional_requirements_specification.md` - Testing requirements

---

## 1. Overview

### 1.1 Testing Environment Strategy

The Nonna App requires testing on multiple platforms and device configurations:

| Platform | Method | Priority | Use Case |
|----------|--------|----------|----------|
| **Android Emulator** | Virtual device via Android Studio | High | Android development and testing |
| **iOS Simulator** | Xcode Simulator (macOS only) | High | iOS development and testing |
| **Physical Android Device** | USB/Wireless debugging | Medium | Real-world testing, performance |
| **Physical iOS Device** | Xcode (macOS only) | Medium | Real-world testing, performance |
| **Web Browser** | Chrome (future) | Low | Web platform testing |

### 1.2 Recommended Device Configurations

Test on these device profiles to cover the majority of users:

**Android:**
- **Pixel 6** (1080x2400, API 33) - Modern flagship
- **Pixel 4a** (1080x2340, API 30) - Mid-range
- **Nexus 5X** (1080x1920, API 28) - Older device

**iOS:**
- **iPhone 15 Pro** (1179x2556) - Latest flagship
- **iPhone 13** (1170x2532) - Recent device
- **iPhone SE (3rd gen)** (750x1334) - Smaller screen

---

## 2. Android Emulator Setup

### 2.1 Prerequisites

- Android Studio installed (see IDE Configuration Document)
- Intel HAXM (Intel processors) or Hypervisor Framework (Apple Silicon)
- Virtualization enabled in BIOS (Windows/Linux)
- At least 8GB RAM (16GB recommended)
- 10GB free disk space per emulator

### 2.2 Android Studio AVD Manager Setup

**Step 1: Open AVD Manager**
```
Android Studio → Tools → AVD Manager
Or click AVD Manager icon in toolbar
```

**Step 2: Create New Virtual Device**
1. Click **"Create Virtual Device"**
2. Select hardware profile:
   - **Phone** → **Pixel 6** (recommended for primary testing)
   - Click **Next**

**Step 3: Select System Image**
1. Choose **API Level 33** (Android 13.0 - Tiramisu)
   - **ABI**: x86_64 (Intel/AMD) or arm64-v8a (Apple Silicon)
   - Click **Download** if not already installed
2. Click **Next**

**Step 4: Configure AVD**
- **AVD Name**: Pixel_6_API_33
- **Startup orientation**: Portrait
- **Graphics**: Hardware - GLES 2.0 (recommended for performance)
- **Device Frame**: Enable device frame (optional)
- **RAM**: 2048 MB (default, adjust based on system RAM)
- Click **Finish**

**Step 5: Verify Emulator**
1. Click **Play** (▶️) button in AVD Manager
2. Wait for emulator to boot (first boot may take 2-3 minutes)
3. Verify emulator is listed in `flutter devices`

```bash
flutter devices
# Should show:
# Android SDK built for x86_64 (mobile) • emulator-5554 • android-x86 • Android 13 (API 33)
```

### 2.3 Recommended AVD Configurations

Create multiple AVDs for comprehensive testing:

#### Configuration 1: Modern Flagship (Primary)
- **Device**: Pixel 6
- **API Level**: 33 (Android 13)
- **Resolution**: 1080x2400
- **RAM**: 2048 MB
- **Storage**: 2048 MB
- **Use Case**: Primary development and testing

#### Configuration 2: Mid-Range Device
- **Device**: Pixel 4a
- **API Level**: 30 (Android 11)
- **Resolution**: 1080x2340
- **RAM**: 1536 MB
- **Storage**: 2048 MB
- **Use Case**: Test on slightly older Android version

#### Configuration 3: Older Device (Compatibility)
- **Device**: Nexus 5X
- **API Level**: 28 (Android 9)
- **Resolution**: 1080x1920
- **RAM**: 1024 MB
- **Storage**: 2048 MB
- **Use Case**: Test minimum supported Android version

#### Configuration 4: Tablet (Optional)
- **Device**: Pixel C
- **API Level**: 33
- **Resolution**: 2560x1800
- **RAM**: 2048 MB
- **Use Case**: Test tablet layouts and responsive design

### 2.4 Android Emulator Performance Optimization

**Enable Hardware Acceleration (Intel/AMD):**
```bash
# Install Intel HAXM (macOS/Windows)
# Download from: https://github.com/intel/haxm/releases

# Verify HAXM is installed (macOS)
kextstat | grep intel

# Verify virtualization enabled (Linux)
egrep -c '(vmx|svm)' /proc/cpuinfo
# Should return > 0
```

**Optimize Emulator Settings:**
- Use **Hardware - GLES 2.0** graphics (faster than software)
- Allocate sufficient RAM (2GB for most cases)
- Use **Cold Boot** instead of Quick Boot for first launch
- Enable **Snapshots** for faster subsequent launches

**Command Line Optimization:**
```bash
# Launch emulator with performance flags
emulator -avd Pixel_6_API_33 -gpu host -cores 4

# List available emulators
emulator -list-avds

# Launch emulator in headless mode (no GUI)
emulator -avd Pixel_6_API_33 -no-window
```

### 2.5 Android Emulator Troubleshooting

#### Issue: Emulator won't start

**Solution:**
```bash
# Check if emulator process is stuck
ps aux | grep emulator

# Kill stuck emulator process
killall qemu-system-x86_64  # macOS/Linux
taskkill /F /IM qemu-system-x86_64.exe  # Windows

# Cold boot emulator
emulator -avd Pixel_6_API_33 -no-snapshot-load
```

#### Issue: Slow emulator performance

**Solution:**
- Reduce emulator RAM allocation
- Close other resource-intensive applications
- Use x86_64 system images (faster than ARM on Intel)
- Enable hardware acceleration (HAXM/Hypervisor Framework)
- Reduce emulator screen resolution

#### Issue: "HAXM is not installed"

**Solution (macOS):**
```bash
# Allow kernel extensions in System Preferences
# System Preferences → Security & Privacy → Allow Intel HAXM

# Reinstall HAXM
brew install --cask intel-haxm
```

**Solution (Windows):**
```powershell
# Enable Hyper-V in Windows Features
# Or install HAXM from Android Studio SDK Manager
```

#### Issue: Emulator not detected by Flutter

**Solution:**
```bash
# Verify ADB can see emulator
adb devices
# Should show: emulator-5554   device

# Restart ADB server
adb kill-server
adb start-server

# Verify Flutter can see device
flutter devices
```

---

## 3. iOS Simulator Setup (macOS Only)

### 3.1 Prerequisites

- macOS 10.15 (Catalina) or later
- Xcode 15.0 or later installed
- Command Line Tools installed
- Apple Developer account (free tier sufficient for simulator)

### 3.2 Xcode and iOS Simulator Installation

**Step 1: Install Xcode**
```bash
# Download from Mac App Store (12+ GB)
# Or download from https://developer.apple.com/xcode/

# Verify Xcode installation
xcodebuild -version
# Expected: Xcode 15.0 or later

# Accept Xcode license
sudo xcodebuild -license accept

# Install additional simulators (optional)
xcodebuild -downloadPlatform iOS
```

**Step 2: Configure Xcode Command Line Tools**
```bash
# Set Xcode path
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# Verify path
xcode-select -p
# Expected: /Applications/Xcode.app/Contents/Developer

# Run first launch tasks
sudo xcodebuild -runFirstLaunch
```

**Step 3: Open Xcode Simulator**
```bash
# Open Simulator via Xcode
open -a Simulator

# Or via command line
xcrun simctl list devices
```

### 3.3 Creating and Managing iOS Simulators

**List Available Simulators:**
```bash
# List all simulators
xcrun simctl list devices

# List available device types
xcrun simctl list devicetypes

# List available runtimes (iOS versions)
xcrun simctl list runtimes
```

**Create New Simulator:**
```bash
# Create iPhone 15 Pro simulator (iOS 17)
xcrun simctl create "iPhone 15 Pro" "iPhone 15 Pro" "iOS17.0"

# Create iPhone SE (iOS 16)
xcrun simctl create "iPhone SE (3rd)" "iPhone SE (3rd generation)" "iOS16.0"

# Boot simulator
xcrun simctl boot "iPhone 15 Pro"

# Open Simulator app
open -a Simulator
```

**Delete Simulator:**
```bash
# List simulators with UUIDs
xcrun simctl list devices

# Delete specific simulator
xcrun simctl delete <UUID>

# Delete all unavailable simulators
xcrun simctl delete unavailable
```

### 3.4 Recommended iOS Simulator Configurations

Create these simulators for comprehensive testing:

#### Configuration 1: Latest iPhone (Primary)
- **Device**: iPhone 15 Pro
- **iOS Version**: 17.0
- **Screen Size**: 6.1" (1179x2556)
- **Use Case**: Primary iOS development and testing

#### Configuration 2: Standard iPhone
- **Device**: iPhone 13
- **iOS Version**: 16.0
- **Screen Size**: 6.1" (1170x2532)
- **Use Case**: Test on recent, widely-used device

#### Configuration 3: Small iPhone
- **Device**: iPhone SE (3rd generation)
- **iOS Version**: 15.0
- **Screen Size**: 4.7" (750x1334)
- **Use Case**: Test on smaller screens, older iOS

#### Configuration 4: iPad (Optional)
- **Device**: iPad Pro (12.9-inch)
- **iOS Version**: 17.0
- **Screen Size**: 12.9" (2048x2732)
- **Use Case**: Test tablet layouts and responsive design

### 3.5 iOS Simulator Commands

**Launch Simulator:**
```bash
# Launch specific simulator
xcrun simctl boot "iPhone 15 Pro"
open -a Simulator

# Or use Flutter command
flutter emulators --launch apple_ios_simulator
```

**Simulator Operations:**
```bash
# Install app on simulator
xcrun simctl install booted /path/to/app.app

# Uninstall app
xcrun simctl uninstall booted com.example.nonna_app

# Take screenshot
xcrun simctl io booted screenshot ~/Desktop/screenshot.png

# Record video
xcrun simctl io booted recordVideo --codec=h264 ~/Desktop/video.mp4

# Reset simulator (erase all data)
xcrun simctl erase "iPhone 15 Pro"

# Shutdown simulator
xcrun simctl shutdown "iPhone 15 Pro"

# Shutdown all simulators
xcrun simctl shutdown all
```

### 3.6 iOS Simulator Troubleshooting

#### Issue: Simulator won't boot

**Solution:**
```bash
# Shutdown all simulators
xcrun simctl shutdown all

# Reset simulator
xcrun simctl erase "iPhone 15 Pro"

# Reboot Mac (if issue persists)
sudo reboot
```

#### Issue: Simulator not detected by Flutter

**Solution:**
```bash
# Verify Xcode command line tools
xcode-select -p

# Reset Xcode path
sudo xcode-select --reset

# Kill and restart Simulator
killall Simulator
open -a Simulator

# Verify Flutter can see simulator
flutter devices
```

#### Issue: "Unable to boot device in current state: Booted"

**Solution:**
```bash
# Shutdown simulator
xcrun simctl shutdown "iPhone 15 Pro"

# Wait a few seconds, then boot
xcrun simctl boot "iPhone 15 Pro"
```

#### Issue: Slow simulator performance

**Solution:**
- Close other resource-intensive applications
- Reduce simulator window size (Window → Physical Size → 50%)
- Disable "Show Device Bezels" (Window → Show Device Bezels)
- Use newer Mac with Apple Silicon (significantly faster)

---

## 4. Physical Device Setup

### 4.1 Android Physical Device Setup

**Prerequisites:**
- Android device running Android 5.0 (API 21) or later
- USB cable (USB-C or Micro-USB)
- Android device with Developer Options enabled

**Step 1: Enable Developer Options on Android Device**
1. Open **Settings** on Android device
2. Navigate to **About Phone**
3. Tap **Build Number** 7 times
4. Developer Options will be enabled

**Step 2: Enable USB Debugging**
1. Open **Settings** → **Developer Options**
2. Enable **USB Debugging**
3. Enable **Install via USB** (optional, for faster installation)

**Step 3: Connect Device to Computer**
```bash
# Connect device via USB cable
# On device, authorize the computer when prompted

# Verify device is detected
adb devices
# Should show: <device-id>   device

# If device shows "unauthorized", check device screen for authorization prompt

# Verify Flutter can see device
flutter devices
# Should show: <device-name> (mobile) • <device-id> • android-arm64 • Android 13 (API 33)
```

**Step 4: Run App on Physical Device**
```bash
# Run Flutter app on connected device
flutter run

# Or specify device
flutter run -d <device-id>
```

### 4.2 iOS Physical Device Setup (macOS Only)

**Prerequisites:**
- iOS device running iOS 12.0 or later
- Lightning/USB-C cable
- Apple ID (free Apple Developer account sufficient)
- Xcode installed and configured

**Step 1: Connect Device to Mac**
1. Connect iOS device to Mac via cable
2. Unlock device and trust the computer (prompt will appear)
3. Open Xcode → **Window** → **Devices and Simulators**
4. Verify device appears in left sidebar

**Step 2: Configure Code Signing (Xcode)**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** project in left navigator
3. Select **Runner** target
4. Go to **Signing & Capabilities** tab
5. Select your **Team** (your Apple ID)
6. Ensure **Automatically manage signing** is checked
7. Verify **Bundle Identifier** is unique (e.g., `com.yourcompany.nonnaapp`)

**Step 3: Run App on Physical Device**
```bash
# Verify device is detected
flutter devices
# Should show: <device-name> (mobile) • <device-id> • ios • iOS 17.0

# Run Flutter app on connected device
flutter run

# Or specify device
flutter run -d <device-id>
```

### 4.3 Wireless Debugging (Optional)

#### Android Wireless Debugging (Android 11+)

**Step 1: Enable Wireless Debugging**
1. Connect device via USB initially
2. Enable **Developer Options** → **Wireless Debugging**
3. Note device IP address and port

**Step 2: Connect Wirelessly**
```bash
# Ensure device and computer are on same Wi-Fi network
adb tcpip 5555
adb connect <device-ip>:5555

# Verify connection
adb devices
# Should show: <device-ip>:5555   device

# Disconnect USB cable (device remains connected wirelessly)
```

#### iOS Wireless Debugging (iOS 16+, Xcode 14+)

**Step 1: Enable Network Debugging**
1. Connect device via USB initially
2. Open Xcode → **Window** → **Devices and Simulators**
3. Select device in left sidebar
4. Check **Connect via network**
5. Wait for network icon to appear next to device name
6. Disconnect USB cable (device remains connected wirelessly)

---

## 5. Multi-Device Testing

### 5.1 Running on Multiple Devices Simultaneously

**List All Available Devices:**
```bash
flutter devices
# Output:
# Pixel 6 (mobile) • emulator-5554 • android-x86 • Android 13 (API 33)
# iPhone 15 Pro (mobile) • <simulator-id> • ios • iOS 17.0
# Chrome (web) • chrome • web-javascript • Google Chrome 120.0
```

**Run on Specific Device:**
```bash
# Run on Android emulator
flutter run -d emulator-5554

# Run on iOS simulator
flutter run -d <simulator-id>

# Run on physical device
flutter run -d <device-id>

# Run on all connected devices
flutter run -d all
```

### 5.2 Testing Workflow Best Practices

**Development Workflow:**
1. **Primary Development**: Android Emulator (Pixel 6, API 33)
   - Fastest hot reload
   - Good performance on most machines

2. **Cross-Platform Verification**: iOS Simulator (iPhone 15 Pro)
   - Verify iOS-specific behavior
   - Test platform-specific UI differences

3. **Real-World Testing**: Physical Devices
   - Test performance, battery usage
   - Verify camera, location, notifications
   - Test network conditions (Wi-Fi, cellular, offline)

4. **Edge Case Testing**: Older Devices/OS Versions
   - Verify compatibility with older Android/iOS versions
   - Test on lower-end hardware

---

## 6. Device Configuration for Nonna App Features

### 6.1 Camera Testing

**Android Emulator:**
- Enable virtual camera in AVD settings
- Use webcam as emulated camera (if available)

**iOS Simulator:**
- Simulator uses Mac webcam automatically
- Drag and drop images to test photo picker

**Physical Device:**
- Test actual camera capture
- Verify photo quality, compression, upload

### 6.2 Push Notifications Testing

**Android Emulator:**
- Configure Firebase Cloud Messaging (FCM)
- Test with Firebase Console or OneSignal

**iOS Simulator:**
- Push notifications **NOT supported** in simulator
- **Must use physical device** for push notification testing

**Physical Device:**
- Enable notifications in device settings
- Test foreground, background, and terminated states

### 6.3 Location Services Testing

**Android Emulator:**
```bash
# Set location via command line
adb emu geo fix <longitude> <latitude>

# Example: Set location to San Francisco
adb emu geo fix -122.4194 37.7749
```

**iOS Simulator:**
- Use Xcode: **Debug** → **Simulate Location** → Choose location
- Or use GPX files for custom locations

**Physical Device:**
- Test with actual GPS
- Verify location permissions

### 6.4 Offline Mode Testing

**All Devices:**
- Enable Airplane Mode
- Disable Wi-Fi/Cellular
- Verify app functionality with cached data
- Test error handling for network requests

---

## 7. Continuous Integration Device Testing

### 7.1 GitHub Actions with Android Emulator

```yaml
name: Android Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      
      - name: Run Android Emulator
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 33
          target: google_apis
          arch: x86_64
          profile: Pixel_6
          script: flutter test integration_test
```

### 7.2 Firebase Test Lab (Optional)

For comprehensive device testing on real devices in the cloud:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Build app bundle
flutter build apk --debug

# Run tests on Firebase Test Lab
gcloud firebase test android run \
  --type instrumentation \
  --app build/app/outputs/flutter-apk/app-debug.apk \
  --device model=Pixel6,version=33,locale=en,orientation=portrait
```

---

## 8. Device Testing Checklist

### 8.1 Android Testing Checklist

- [ ] **Emulator Setup**
  - [ ] Pixel 6 (API 33) emulator created
  - [ ] Mid-range device (API 30) emulator created
  - [ ] Older device (API 28) emulator created
  - [ ] Hardware acceleration enabled (HAXM/Hypervisor)

- [ ] **Physical Device Testing**
  - [ ] USB debugging enabled on device
  - [ ] Device detected by ADB
  - [ ] App installs and runs successfully
  - [ ] Camera, notifications, location tested

- [ ] **Emulator Performance**
  - [ ] Emulator boots in < 2 minutes
  - [ ] Hot reload works within 2 seconds
  - [ ] No lag during UI interactions

### 8.2 iOS Testing Checklist

- [ ] **Simulator Setup**
  - [ ] iPhone 15 Pro (iOS 17) simulator created
  - [ ] iPhone 13 (iOS 16) simulator created
  - [ ] iPhone SE (iOS 15) simulator created
  - [ ] Simulators boot successfully

- [ ] **Physical Device Testing**
  - [ ] Device detected by Xcode
  - [ ] Code signing configured
  - [ ] App installs and runs successfully
  - [ ] Camera, location tested (notifications require physical device)

- [ ] **Simulator Performance**
  - [ ] Simulator boots in < 1 minute
  - [ ] Hot reload works within 2 seconds
  - [ ] No lag during UI interactions

---

## 9. Troubleshooting Quick Reference

| Issue | Platform | Solution |
|-------|----------|----------|
| Emulator won't start | Android | Cold boot, kill stuck processes, check HAXM |
| Slow emulator | Android | Reduce RAM, use hardware graphics, enable HAXM |
| Device not detected | Android | Enable USB debugging, restart ADB, check cable |
| Simulator won't boot | iOS | Shutdown all, reset simulator, reboot Mac |
| Simulator slow | iOS | Reduce window size, close other apps, use Apple Silicon |
| Code signing error | iOS | Configure Team in Xcode, ensure unique Bundle ID |
| Push notifications not working | iOS | Use physical device (not supported in simulator) |
| Camera not working | Both | Enable camera permissions, use physical device for real camera |

---

## 10. References and Resources

### 10.1 Official Documentation

- Android Emulator: https://developer.android.com/studio/run/emulator
- iOS Simulator: https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device
- Flutter Device Setup: https://flutter.dev/docs/get-started/install
- ADB Commands: https://developer.android.com/studio/command-line/adb

### 10.2 Internal Resources

- `docs/03_environment_setup/01_Flutter_Installation_Verification_Report.md`
- `docs/03_environment_setup/02_IDE_Configuration_Document.md`
- `docs/03_environment_setup/04_Git_Repository_Initialization_Confirmation.md`

---

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Next Review**: Quarterly or when device configurations change  
**Status**: ✅ Complete
