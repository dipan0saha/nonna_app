# Flutter Installation Verification Report

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Development Lead  
**Status**: Final  
**Section**: 2.1 - Flutter Environment Setup

## Executive Summary

This document provides comprehensive guidance for installing, verifying, and validating the Flutter SDK development environment for the Nonna App project. It includes platform-specific installation instructions, environment configuration guidelines, validation procedures, and troubleshooting steps.

## References

This document aligns with:
- `discovery/01_discovery/02_technology_stack/Technology_Stack.md` - Flutter and Dart requirements
- `docs/01_technical_requirements/non_functional_requirements_specification.md` - Development environment standards
- `pubspec.yaml` - Project SDK version requirements (SDK ^3.10.1)

---

## 1. Flutter SDK Requirements

### 1.1 Required Versions

Based on the project's `pubspec.yaml` configuration:

- **Dart SDK**: ^3.10.1 or higher
- **Flutter SDK**: Latest stable version supporting Dart 3.10.1+
- **Recommended Flutter Channel**: Stable (for production readiness)

### 1.2 Platform Support

The Nonna App targets the following platforms:
- ✅ **iOS** (iPhone, iPad)
- ✅ **Android** (phones, tablets)
- 🔄 **Web** (future enhancement)
- 🔄 **macOS** (future enhancement)
- 🔄 **Linux** (future enhancement)
- 🔄 **Windows** (future enhancement)

---

## 2. Installation Instructions

### 2.1 macOS Installation

#### Prerequisites
- macOS 10.14 (Mojave) or later
- Disk Space: At least 2.8 GB (excluding IDE/tools)
- Tools: bash, curl, git, mkdir, rm, unzip, which, xcode-select

#### Installation Steps

**Step 1: Install Xcode Command Line Tools**
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify installation
xcode-select -p
# Expected output: /Library/Developer/CommandLineTools
```

**Step 2: Download Flutter SDK**
```bash
# Create development directory
mkdir -p ~/development
cd ~/development

# Download Flutter SDK (replace with current stable version)
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.24.0-stable.zip

# Extract the archive
unzip flutter_macos_3.24.0-stable.zip

# Verify extraction
ls -l flutter/bin/flutter
```

**Step 3: Add Flutter to PATH**

Add Flutter to your PATH permanently:

```bash
# For bash (~/.bash_profile or ~/.bashrc)
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bash_profile
source ~/.bash_profile

# For zsh (~/.zshrc)
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

# For fish (~/.config/fish/config.fish)
set -Ua fish_user_paths $HOME/development/flutter/bin
```

**Step 4: Verify Installation**
```bash
# Check Flutter version
flutter --version

# Run Flutter doctor
flutter doctor -v

# Accept Android licenses (if Android development planned)
flutter doctor --android-licenses
```

#### macOS-Specific Requirements for iOS Development

**Install Xcode (for iOS development)**
```bash
# Download Xcode from Mac App Store (12+ GB)
# Or use xcode-select to install command line tools only

# After Xcode installation, configure it
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# Install CocoaPods (for iOS dependencies)
sudo gem install cocoapods
pod setup

# Verify CocoaPods installation
pod --version
```

---

### 2.2 Windows Installation

#### Prerequisites
- Windows 10 64-bit or later
- Disk Space: At least 2.8 GB (excluding IDE/tools)
- Tools: PowerShell 5.0 or later, Git for Windows

#### Installation Steps

**Step 1: Download Flutter SDK**
1. Download the Flutter SDK from: https://flutter.dev/docs/get-started/install/windows
2. Extract the zip file to a desired location (e.g., `C:\src\flutter`)
   - **Important**: Do NOT install Flutter in directories requiring elevated privileges (e.g., `C:\Program Files\`)

**Step 2: Add Flutter to PATH**

```powershell
# Open System Properties > Environment Variables
# Add Flutter bin directory to PATH:
C:\src\flutter\bin

# Or use PowerShell (as Administrator):
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\src\flutter\bin",
    "User"
)
```

**Step 3: Verify Installation**
```powershell
# Check Flutter version
flutter --version

# Run Flutter doctor
flutter doctor -v

# Accept Android licenses (if Android development planned)
flutter doctor --android-licenses
```

#### Windows-Specific Requirements for Android Development

**Install Android Studio and SDK**
1. Download Android Studio from: https://developer.android.com/studio
2. Run the installer and follow the Android Studio Setup Wizard
3. Install Android SDK, Android SDK Platform-Tools, and Android SDK Build-Tools
4. Configure Android SDK location in environment variables:

```powershell
# Set ANDROID_HOME environment variable
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Users\<USERNAME>\AppData\Local\Android\Sdk", "User")

# Add platform-tools to PATH
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "User") + ";%ANDROID_HOME%\platform-tools",
    "User"
)
```

---

### 2.3 Linux Installation

#### Prerequisites
- Ubuntu 18.04 or later (or equivalent distribution)
- Disk Space: At least 2.8 GB (excluding IDE/tools)
- Tools: bash, curl, git, mkdir, rm, unzip, which, xz-utils, zip, libglu1-mesa

#### Installation Steps

**Step 1: Install Dependencies**
```bash
# Update package list
sudo apt-get update

# Install required dependencies
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Install additional libraries for Chrome (if using Flutter web)
sudo apt-get install -y \
  libgconf-2-4 \
  libgtk-3-0 \
  libnotify-dev \
  libnss3 \
  libxss1 \
  libxtst6 \
  xdg-utils
```

**Step 2: Download Flutter SDK**
```bash
# Create development directory
mkdir -p ~/development
cd ~/development

# Download Flutter SDK (replace with current stable version)
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz

# Extract the archive
tar xf flutter_linux_3.24.0-stable.tar.xz

# Verify extraction
ls -l flutter/bin/flutter
```

**Step 3: Add Flutter to PATH**
```bash
# Add to ~/.bashrc or ~/.zshrc
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verify PATH
echo $PATH | grep flutter
```

**Step 4: Verify Installation**
```bash
# Check Flutter version
flutter --version

# Run Flutter doctor
flutter doctor -v

# Accept Android licenses (if Android development planned)
flutter doctor --android-licenses
```

#### Linux-Specific Requirements for Android Development

**Install Android Studio and SDK**
```bash
# Download Android Studio
wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.1.1.28/android-studio-2023.1.1.28-linux.tar.gz

# Extract Android Studio
sudo tar -xzf android-studio-*-linux.tar.gz -C /opt/

# Add Android Studio to PATH
echo 'export PATH="$PATH:/opt/android-studio/bin"' >> ~/.bashrc
source ~/.bashrc

# Launch Android Studio
studio.sh

# Follow Android Studio Setup Wizard to install Android SDK
```

---

## 3. Environment Variables Configuration

### 3.1 Required Environment Variables

| Variable | Purpose | Example Value (macOS/Linux) | Example Value (Windows) |
|----------|---------|------------------------------|-------------------------|
| `FLUTTER_ROOT` | Flutter SDK location | `~/development/flutter` | `C:\src\flutter` |
| `ANDROID_HOME` | Android SDK location | `~/Library/Android/sdk` | `C:\Users\<USERNAME>\AppData\Local\Android\Sdk` |
| `JAVA_HOME` | Java JDK location | `/Library/Java/JavaVirtualMachines/jdk-11.jdk/Contents/Home` | `C:\Program Files\Java\jdk-11` |
| `PATH` | Include Flutter & Android tools | Append Flutter and Android bin directories | Same |

### 3.2 Verification Commands

```bash
# Verify environment variables
echo $FLUTTER_ROOT     # macOS/Linux
echo $ANDROID_HOME     # macOS/Linux
echo $JAVA_HOME        # macOS/Linux

# Windows (PowerShell)
echo $env:FLUTTER_ROOT
echo $env:ANDROID_HOME
echo $env:JAVA_HOME

# Verify PATH includes Flutter
which flutter          # macOS/Linux
where.exe flutter      # Windows

# Verify PATH includes Android tools
which adb             # macOS/Linux
where.exe adb         # Windows
```

---

## 4. Flutter Doctor Validation

### 4.1 Running Flutter Doctor

The `flutter doctor` command validates your Flutter installation and identifies any missing dependencies:

```bash
# Run basic flutter doctor
flutter doctor

# Run verbose flutter doctor for detailed information
flutter doctor -v
```

### 4.2 Expected Output

A successful Flutter installation should show:

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.24.0, on macOS 14.0 23A344 darwin-arm64, locale en-US)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[✓] Xcode - develop for iOS and macOS (Xcode 15.0)
[✓] Chrome - develop for the web
[✓] Android Studio (version 2023.1)
[✓] VS Code (version 1.85.0)
[✓] Connected device (3 available)
[✓] Network resources

• No issues found!
```

### 4.3 Common Flutter Doctor Issues and Resolutions

| Issue | Resolution |
|-------|-----------|
| ❌ Android toolchain - Android SDK not found | Install Android Studio and SDK, set `ANDROID_HOME` |
| ❌ Android licenses not accepted | Run `flutter doctor --android-licenses` and accept all |
| ❌ Xcode not installed (macOS) | Install Xcode from Mac App Store |
| ❌ CocoaPods not installed (macOS) | Run `sudo gem install cocoapods` |
| ❌ VS Code or Android Studio not detected | Install IDE and Flutter/Dart extensions |
| ⚠️ Some Android licenses not accepted | Run `flutter doctor --android-licenses` |
| ⚠️ Connected device not available | Connect a physical device or start an emulator |

---

## 5. Flutter Channel Management

### 5.1 Flutter Channels

Flutter has multiple release channels:

| Channel | Description | Recommended For |
|---------|-------------|-----------------|
| **stable** | Latest stable release | Production apps (Nonna App) |
| **beta** | Pre-release for testing | Testing upcoming features |
| **dev** | Latest development builds | Experimental features |
| **master** | Bleeding edge, unstable | Flutter contributors only |

### 5.2 Channel Commands

```bash
# List all channels
flutter channel

# Switch to stable channel (recommended for Nonna App)
flutter channel stable

# Update Flutter to latest version on current channel
flutter upgrade

# Downgrade to a specific version (if needed)
flutter downgrade <version>

# Check current Flutter version
flutter --version
```

### 5.3 Recommended Configuration for Nonna App

```bash
# Use stable channel for production
flutter channel stable

# Update to latest stable
flutter upgrade

# Verify Dart SDK version meets requirements (^3.10.1)
dart --version
# Expected: Dart SDK version: 3.10.1 or higher
```

---

## 6. Validation Checklist

### 6.1 Installation Validation Checklist

Use this checklist to validate your Flutter environment setup:

- [ ] **Flutter SDK Installed**
  - [ ] Flutter executable accessible in PATH
  - [ ] Flutter version displayed: `flutter --version`
  - [ ] Dart SDK version ≥ 3.10.1

- [ ] **Environment Variables Configured**
  - [ ] `FLUTTER_ROOT` set (optional but recommended)
  - [ ] `ANDROID_HOME` set (for Android development)
  - [ ] `JAVA_HOME` set (for Android development)
  - [ ] Flutter bin directory in PATH

- [ ] **Flutter Doctor Passes**
  - [ ] Run `flutter doctor -v` successfully
  - [ ] All required toolchains show ✓ (checkmark)
  - [ ] Android licenses accepted (if Android dev)
  - [ ] Xcode configured (if iOS dev on macOS)

- [ ] **Platform-Specific Setup**
  - [ ] Android SDK installed and configured
  - [ ] Xcode installed (macOS only, for iOS)
  - [ ] CocoaPods installed (macOS only, for iOS)
  - [ ] Chrome installed (for web development)

- [ ] **Flutter Channel**
  - [ ] Using stable channel: `flutter channel stable`
  - [ ] Latest stable version: `flutter upgrade`

- [ ] **Project Compatibility**
  - [ ] Dart SDK version meets project requirements (^3.10.1)
  - [ ] `flutter pub get` runs successfully in project directory
  - [ ] No dependency conflicts in `pubspec.yaml`

---

## 7. Project-Specific Setup

### 7.1 Nonna App Flutter Configuration

After installing Flutter, configure the Nonna App project:

```bash
# Navigate to project directory
cd /path/to/nonna_app

# Get Flutter dependencies
flutter pub get

# Verify no issues
flutter analyze

# Run code generation (if needed)
flutter pub run build_runner build --delete-conflicting-outputs

# Verify project runs
flutter run
```

### 7.2 Verify Project SDK Compatibility

```bash
# Check pubspec.yaml SDK constraints
cat pubspec.yaml | grep -A 1 "environment:"
# Expected output:
# environment:
#   sdk: ^3.10.1

# Verify current Dart SDK meets requirements
dart --version
# Should be 3.10.1 or higher
```

---

## 8. Troubleshooting Guide

### 8.1 Common Installation Issues

#### Issue: "flutter: command not found"

**Solution:**
```bash
# Verify Flutter is in PATH
echo $PATH | grep flutter   # macOS/Linux
echo $env:PATH | Select-String flutter  # Windows

# If not in PATH, add Flutter to your shell profile
export PATH="$PATH:/path/to/flutter/bin"  # macOS/Linux
```

#### Issue: "Android licenses not accepted"

**Solution:**
```bash
# Accept all Android SDK licenses
flutter doctor --android-licenses

# Press 'y' to accept each license
```

#### Issue: "Android SDK not found"

**Solution:**
```bash
# Set ANDROID_HOME environment variable
export ANDROID_HOME=$HOME/Library/Android/sdk  # macOS/Linux
export ANDROID_HOME=C:\Users\<USERNAME>\AppData\Local\Android\Sdk  # Windows

# Verify Android SDK installation
ls $ANDROID_HOME  # Should show platform-tools, build-tools, platforms, etc.
```

#### Issue: "CocoaPods not installed" (macOS)

**Solution:**
```bash
# Install CocoaPods
sudo gem install cocoapods

# Initialize CocoaPods
pod setup

# Verify installation
pod --version
```

#### Issue: "Xcode not configured" (macOS)

**Solution:**
```bash
# Install Xcode from Mac App Store
# Then configure Xcode command line tools
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# Verify Xcode installation
xcodebuild -version
```

#### Issue: "Network issues downloading Flutter"

**Solution:**
```bash
# Use Flutter mirror (China)
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# Or use proxy
export http_proxy=http://proxy.example.com:8080
export https_proxy=http://proxy.example.com:8080
```

### 8.2 Performance Issues

#### Issue: "Slow Flutter pub get"

**Solution:**
```bash
# Clear pub cache
flutter pub cache clean

# Use pub cache repair
flutter pub cache repair

# Re-run pub get
flutter pub get
```

#### Issue: "Slow Flutter doctor"

**Solution:**
```bash
# Skip unnecessary checks
flutter doctor --no-check-for-updates

# Run specific checks only
flutter doctor --android-licenses
```

---

## 9. Continuous Validation

### 9.1 Regular Maintenance

Developers should regularly validate their Flutter environment:

```bash
# Update Flutter to latest stable version (monthly)
flutter upgrade

# Clean build artifacts (weekly)
flutter clean

# Update project dependencies (before each PR)
flutter pub upgrade --major-versions

# Re-run flutter doctor (after system updates)
flutter doctor -v
```

### 9.2 Team Synchronization

To ensure all team members use compatible Flutter versions:

```bash
# Document current Flutter version in project
flutter --version > FLUTTER_VERSION.txt

# Commit FLUTTER_VERSION.txt to repository
git add FLUTTER_VERSION.txt
git commit -m "docs: update Flutter version reference"

# Team members can verify their version matches
cat FLUTTER_VERSION.txt
```

---

## 10. CI/CD Environment Setup

### 10.1 GitHub Actions Flutter Setup

For CI/CD pipelines, use the `subosito/flutter-action` GitHub Action:

```yaml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
        channel: 'stable'
    
    - name: Verify Flutter installation
      run: |
        flutter --version
        flutter doctor -v
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Run tests
      run: flutter test
    
    - name: Build APK
      run: flutter build apk --release
```

### 10.2 Docker Flutter Environment

For containerized development:

```dockerfile
# Use official Flutter image
FROM cirrusci/flutter:stable

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Install dependencies
RUN flutter pub get

# Run tests
RUN flutter test

# Build app
RUN flutter build apk --release
```

---

## 11. Validation Sign-Off

### 11.1 Validation Checklist

Before proceeding to Section 2.2 (Project Initialization), verify:

- [ ] Flutter SDK installed and accessible
- [ ] Dart SDK version ≥ 3.10.1
- [ ] `flutter doctor` passes with no critical errors
- [ ] Environment variables configured correctly
- [ ] Platform-specific toolchains installed (Android SDK, Xcode)
- [ ] Project dependencies install successfully (`flutter pub get`)
- [ ] Project analyzes without errors (`flutter analyze`)
- [ ] IDE configured with Flutter extensions (see IDE Configuration Document)

### 11.2 Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Development Lead | [Name] | [Date] | [Signature] |
| DevOps Engineer | [Name] | [Date] | [Signature] |
| QA Lead | [Name] | [Date] | [Signature] |

---

## 12. References and Resources

### 12.1 Official Documentation

- Flutter Installation Guide: https://flutter.dev/docs/get-started/install
- Flutter Doctor Documentation: https://flutter.dev/docs/get-started/flutter-doctor
- Dart SDK Installation: https://dart.dev/get-dart
- Android Studio Setup: https://developer.android.com/studio/install
- Xcode Setup: https://developer.apple.com/xcode/

### 12.2 Troubleshooting Resources

- Flutter Issue Tracker: https://github.com/flutter/flutter/issues
- Stack Overflow Flutter Tag: https://stackoverflow.com/questions/tagged/flutter
- Flutter Community Slack: https://fluttercommunity.dev/
- Flutter Discord: https://discord.com/invite/flutter

### 12.3 Internal Resources

- `docs/03_environment_setup/02_IDE_Configuration_Document.md` - IDE setup guide
- `docs/03_environment_setup/03_Emulator_Simulator_Setup_Guide.md` - Emulator setup
- `docs/03_environment_setup/04_Git_Repository_Initialization_Confirmation.md` - Git setup
- `docs/03_environment_setup/05_Branching_Strategy_Document.md` - Git workflow

---

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Next Review**: Before Section 2.2 (Project Initialization)  
**Status**: ✅ Complete
