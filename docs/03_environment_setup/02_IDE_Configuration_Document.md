# IDE Configuration Document

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Development Lead  
**Status**: Final  
**Section**: 2.1 - Flutter Environment Setup

## Executive Summary

This document provides comprehensive guidance for configuring Integrated Development Environments (IDEs) for Flutter development on the Nonna App project. It covers setup instructions for Visual Studio Code and Android Studio, including required extensions, recommended settings, code formatting configuration, and debugging tools.

## References

This document aligns with:
- `docs/03_environment_setup/01_Flutter_Installation_Verification_Report.md` - Flutter SDK setup
- `docs/02_architecture_design/folder_structure_code_organization.md` - Code organization standards
- `analysis_options.yaml` - Linting and analysis configuration
- `.pre-commit-config.yaml` - Pre-commit hook configuration

---

## 1. IDE Recommendations

### 1.1 Supported IDEs

The Nonna App project officially supports two primary IDEs:

| IDE | Recommended For | Pros | Cons |
|-----|-----------------|------|------|
| **Visual Studio Code** | Quick development, lightweight setup | Fast, extensible, great Git integration | Fewer built-in Flutter tools |
| **Android Studio** | Android-heavy development, comprehensive tooling | Full Android/iOS tooling, powerful debugger | Heavier resource usage |

**Recommendation for Nonna App**: **Visual Studio Code** for its lightweight nature and excellent Flutter/Dart support, with Android Studio as a secondary option for Android-specific debugging.

---

## 2. Visual Studio Code Setup

### 2.1 Prerequisites

- Visual Studio Code 1.85.0 or later
- Flutter SDK installed (see Flutter Installation Verification Report)
- Git installed and configured

### 2.2 Installation

**macOS:**
```bash
# Download from https://code.visualstudio.com/
# Or install via Homebrew
brew install --cask visual-studio-code
```

**Windows:**
```powershell
# Download from https://code.visualstudio.com/
# Run the installer VSCodeUserSetup-x64-<version>.exe
```

**Linux:**
```bash
# Ubuntu/Debian
sudo snap install code --classic

# Or download .deb package and install
sudo dpkg -i code_<version>_amd64.deb
```

### 2.3 Required Extensions

Install these extensions for Flutter development:

#### Core Flutter Extensions

1. **Flutter** (Dart-Code.flutter)
   ```bash
   code --install-extension Dart-Code.flutter
   ```
   - Provides Flutter-specific commands, hot reload, widget inspector
   - Syntax highlighting for Dart
   - Code completion and snippets

2. **Dart** (Dart-Code.dart-code)
   ```bash
   code --install-extension Dart-Code.dart-code
   ```
   - Dart language support
   - Debugging support
   - Code analysis and linting

#### Recommended Extensions

3. **Pubspec Assist** (jeroen-meijer.pubspec-assist)
   ```bash
   code --install-extension jeroen-meijer.pubspec-assist
   ```
   - Easily add dependencies to pubspec.yaml
   - Auto-completion for package names

4. **Awesome Flutter Snippets** (Nash.awesome-flutter-snippets)
   ```bash
   code --install-extension Nash.awesome-flutter-snippets
   ```
   - Code snippets for common Flutter widgets
   - Speeds up development

5. **Bracket Pair Colorizer 2** (CoenraadS.bracket-pair-colorizer-2)
   ```bash
   code --install-extension CoenraadS.bracket-pair-colorizer-2
   ```
   - Color-codes matching brackets for better readability

6. **Error Lens** (usernamehw.errorlens)
   ```bash
   code --install-extension usernamehw.errorlens
   ```
   - Highlights errors and warnings inline
   - Improves error visibility

7. **GitLens** (eamodio.gitlens)
   ```bash
   code --install-extension eamodio.gitlens
   ```
   - Enhanced Git integration
   - Blame annotations, commit history

8. **Better Comments** (aaron-bond.better-comments)
   ```bash
   code --install-extension aaron-bond.better-comments
   ```
   - Color-coded comments (TODO, FIXME, etc.)

9. **Todo Tree** (Gruntfuggly.todo-tree)
   ```bash
   code --install-extension Gruntfuggly.todo-tree
   ```
   - Tracks TODO, FIXME, and other tags in code

10. **Material Icon Theme** (PKief.material-icon-theme)
    ```bash
    code --install-extension PKief.material-icon-theme
    ```
    - Better file icons for project explorer

### 2.4 VS Code Settings Configuration

Create or update `.vscode/settings.json` in the project root:

```json
{
  // Dart & Flutter Settings
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.debugExternalPackageLibraries": false,
  "dart.debugSdkLibraries": false,
  "dart.previewLsp": true,
  "dart.lineLength": 80,
  
  // Editor Settings
  "editor.formatOnSave": true,
  "editor.formatOnType": true,
  "editor.rulers": [80, 120],
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.wordWrap": "on",
  "editor.suggestSelection": "first",
  
  // File Settings
  "files.autoSave": "onFocusChange",
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.exclude": {
    "**/.dart_tool": true,
    "**/.packages": true,
    "**/build": true,
    "**/*.freezed.dart": true,
    "**/*.g.dart": true
  },
  "files.watcherExclude": {
    "**/.dart_tool/**": true,
    "**/build/**": true
  },
  
  // Search Settings
  "search.exclude": {
    "**/.dart_tool": true,
    "**/build": true,
    "**/*.freezed.dart": true,
    "**/*.g.dart": true,
    "**/pubspec.lock": true
  },
  
  // Flutter-Specific Settings
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.formatOnType": true,
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": false,
    "editor.defaultFormatter": "Dart-Code.dart-code"
  },
  
  // Git Settings
  "git.autofetch": true,
  "git.enableSmartCommit": true,
  "git.confirmSync": false,
  
  // Terminal Settings
  "terminal.integrated.defaultProfile.osx": "zsh",
  "terminal.integrated.defaultProfile.linux": "bash",
  "terminal.integrated.defaultProfile.windows": "PowerShell",
  
  // Emmet for Dart files (optional)
  "emmet.includeLanguages": {
    "dart": "html"
  },
  
  // Color Theme (optional)
  "workbench.colorTheme": "Default Dark+",
  "workbench.iconTheme": "material-icon-theme"
}
```

### 2.5 VS Code Keyboard Shortcuts

Recommended keyboard shortcuts for Flutter development:

| Action | macOS | Windows/Linux | Description |
|--------|-------|---------------|-------------|
| Hot Reload | `Cmd+S` | `Ctrl+S` | Save file triggers hot reload |
| Hot Restart | `Shift+Cmd+P` → "Flutter: Hot Restart" | `Shift+Ctrl+P` → "Flutter: Hot Restart" | Full app restart |
| Open Widget Inspector | `Cmd+Shift+P` → "Flutter: Open DevTools" | `Ctrl+Shift+P` → "Flutter: Open DevTools" | Open Flutter DevTools |
| Format Document | `Shift+Option+F` | `Shift+Alt+F` | Format current file |
| Go to Definition | `F12` | `F12` | Jump to definition |
| Find References | `Shift+F12` | `Shift+F12` | Find all references |
| Rename Symbol | `F2` | `F2` | Rename variable/function |
| Quick Fix | `Cmd+.` | `Ctrl+.` | Show quick fixes |
| Toggle Terminal | `Ctrl+\`` | `Ctrl+\`` | Show/hide terminal |
| Run Debug | `F5` | `F5` | Start debugging |

### 2.6 VS Code Launch Configuration

Create or update `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Development)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=ENVIRONMENT=development"
      ]
    },
    {
      "name": "Flutter (Staging)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=ENVIRONMENT=staging"
      ]
    },
    {
      "name": "Flutter (Production)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=ENVIRONMENT=production"
      ]
    },
    {
      "name": "Flutter (Profile Mode)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "profile",
      "program": "lib/main.dart"
    },
    {
      "name": "Flutter (Release Mode)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "release",
      "program": "lib/main.dart"
    }
  ]
}
```

### 2.7 VS Code Tasks Configuration

Create or update `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Flutter: Analyze",
      "type": "shell",
      "command": "flutter analyze",
      "problemMatcher": []
    },
    {
      "label": "Flutter: Test",
      "type": "shell",
      "command": "flutter test",
      "problemMatcher": []
    },
    {
      "label": "Flutter: Build Runner",
      "type": "shell",
      "command": "flutter pub run build_runner build --delete-conflicting-outputs",
      "problemMatcher": []
    },
    {
      "label": "Flutter: Clean",
      "type": "shell",
      "command": "flutter clean && flutter pub get",
      "problemMatcher": []
    },
    {
      "label": "Flutter: Pub Get",
      "type": "shell",
      "command": "flutter pub get",
      "problemMatcher": []
    }
  ]
}
```

---

## 3. Android Studio Setup

### 3.1 Prerequisites

- Android Studio 2023.1 or later
- Flutter SDK installed (see Flutter Installation Verification Report)
- JDK 11 or later

### 3.2 Installation

**macOS:**
```bash
# Download from https://developer.android.com/studio
# Or install via Homebrew
brew install --cask android-studio
```

**Windows:**
```powershell
# Download from https://developer.android.com/studio
# Run the installer android-studio-<version>-windows.exe
```

**Linux:**
```bash
# Download from https://developer.android.com/studio
# Extract and run:
tar -xzf android-studio-<version>-linux.tar.gz
cd android-studio/bin
./studio.sh
```

### 3.3 Required Plugins

Install these plugins via **Preferences/Settings → Plugins**:

1. **Flutter Plugin**
   - Search for "Flutter" in Marketplace
   - Click Install
   - Restart Android Studio

2. **Dart Plugin**
   - Automatically installed with Flutter plugin
   - Provides Dart language support

#### Recommended Plugins

3. **Rainbow Brackets**
   - Better bracket visualization
   - Search: "Rainbow Brackets"

4. **Key Promoter X**
   - Learn keyboard shortcuts
   - Search: "Key Promoter X"

5. **GitToolBox**
   - Enhanced Git integration
   - Search: "GitToolBox"

6. **Material Theme UI**
   - Modern UI theme
   - Search: "Material Theme UI"

### 3.4 Android Studio Settings Configuration

Configure Android Studio for Flutter development:

**Preferences → Languages & Frameworks → Flutter**
- Set Flutter SDK path: `/path/to/flutter`
- Enable: "Perform hot reload on save"
- Enable: "Format code on save"

**Preferences → Editor → Code Style → Dart**
- Set line length: 80
- Enable: "Insert new line at end of file"
- Enable: "Remove trailing spaces on save"

**Preferences → Editor → General → Auto Import**
- Enable: "Optimize imports on the fly"
- Enable: "Add unambiguous imports on the fly"

**Preferences → Build, Execution, Deployment → Compiler**
- Increase Heap Size: 2048 MB (for better performance)

**Preferences → Appearance & Behavior → System Settings**
- Enable: "Reopen projects on startup"
- Enable: "Confirm application exit"

### 3.5 Android Studio Run Configurations

Configure run configurations for different environments:

1. **Edit Configurations** (top toolbar)
2. Click **+** → **Flutter**
3. Create configurations:

**Development Configuration:**
- Name: "Flutter (Development)"
- Dart entrypoint: `lib/main.dart`
- Additional run args: `--dart-define=ENVIRONMENT=development`

**Staging Configuration:**
- Name: "Flutter (Staging)"
- Dart entrypoint: `lib/main.dart`
- Additional run args: `--dart-define=ENVIRONMENT=staging`

**Production Configuration:**
- Name: "Flutter (Production)"
- Dart entrypoint: `lib/main.dart`
- Additional run args: `--dart-define=ENVIRONMENT=production`

---

## 4. Code Formatting and Linting

### 4.1 Dart Code Formatting

The Nonna App project follows standard Dart formatting guidelines.

**Format a single file:**
```bash
dart format lib/main.dart
```

**Format entire project:**
```bash
dart format .
```

**Check formatting without modifying:**
```bash
dart format --set-exit-if-changed .
```

### 4.2 Analysis Options Configuration

The project uses `analysis_options.yaml` for linting and analysis rules:

```yaml
# See analysis_options.yaml in project root
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "build/**"
  
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
  
  errors:
    missing_required_param: error
    missing_return: error
    todo: ignore

linter:
  rules:
    # Recommended rules for Nonna App
    - always_declare_return_types
    - always_require_non_null_named_parameters
    - avoid_print
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_single_quotes
    - sort_child_properties_last
    - use_key_in_widget_constructors
```

### 4.3 Running Linter

**Analyze entire project:**
```bash
flutter analyze
```

**Analyze with verbose output:**
```bash
flutter analyze --verbose
```

**Fix auto-fixable issues:**
```bash
dart fix --apply
```

### 4.4 Pre-commit Hooks

The project uses pre-commit hooks to enforce code quality (see `.pre-commit-config.yaml`):

```yaml
repos:
  - repo: local
    hooks:
      - id: flutter-format
        name: Flutter Format
        entry: dart format
        language: system
        files: \.dart$
        
      - id: flutter-analyze
        name: Flutter Analyze
        entry: flutter analyze
        language: system
        pass_filenames: false
        
      - id: flutter-test
        name: Flutter Test
        entry: flutter test
        language: system
        pass_filenames: false
```

**Install pre-commit hooks:**
```bash
pip install pre-commit
pre-commit install
```

---

## 5. Debugging Configuration

### 5.1 VS Code Debugging

**Start Debugging:**
1. Set breakpoints by clicking left gutter in code editor
2. Press `F5` or click "Run and Debug" in sidebar
3. Select device/emulator from bottom status bar
4. Use Debug Console for interactive debugging

**Debug Actions:**
- **Continue** (`F5`): Resume execution
- **Step Over** (`F10`): Execute next line
- **Step Into** (`F11`): Step into function
- **Step Out** (`Shift+F11`): Step out of function
- **Restart** (`Ctrl+Shift+F5`): Restart debug session
- **Stop** (`Shift+F5`): Stop debugging

### 5.2 Android Studio Debugging

**Start Debugging:**
1. Set breakpoints by clicking left gutter
2. Click "Debug" button (bug icon) in toolbar
3. Use "Debug" panel at bottom for variables, watches, console

**Advanced Debugging:**
- **Evaluate Expression** (`Alt+F8`): Evaluate expressions at runtime
- **Watch Variables**: Right-click variable → "Add to Watches"
- **Conditional Breakpoints**: Right-click breakpoint → "Edit Breakpoint"

### 5.3 Flutter DevTools

Flutter DevTools provides advanced debugging and profiling:

**Open DevTools:**
```bash
# From command line
flutter pub global activate devtools
flutter pub global run devtools

# Or from VS Code
Cmd/Ctrl+Shift+P → "Flutter: Open DevTools"
```

**DevTools Features:**
- **Widget Inspector**: Visualize widget tree
- **Performance View**: Identify performance bottlenecks
- **Memory View**: Track memory usage
- **Network View**: Monitor network requests
- **Logging View**: View app logs

---

## 6. Extension-Specific Features

### 6.1 Flutter Outline (VS Code)

The Flutter extension provides an Outline view:

1. Open any Dart file
2. Click "Flutter Outline" in sidebar
3. View widget hierarchy
4. Wrap/remove widgets with right-click menu

### 6.2 Widget Refactoring

Both IDEs support widget refactoring:

**Wrap with Widget:**
- Select widget
- Press `Cmd/Ctrl+.` (Quick Fix)
- Choose "Wrap with Widget"

**Extract to Method/Widget:**
- Select code
- Press `Cmd/Ctrl+.`
- Choose "Extract Method" or "Extract Widget"

**Remove Widget:**
- Place cursor on widget
- Press `Cmd/Ctrl+.`
- Choose "Remove this widget"

### 6.3 Code Snippets

Common Flutter snippets (VS Code):

| Trigger | Expansion |
|---------|-----------|
| `stless` | StatelessWidget |
| `stful` | StatefulWidget |
| `build` | Build method |
| `initState` | initState override |
| `dispose` | dispose override |
| `mounted` | if (mounted) check |
| `streambuilder` | StreamBuilder |
| `futurebuilder` | FutureBuilder |

---

## 7. Performance Optimization

### 7.1 IDE Performance Settings

**VS Code:**
```json
{
  "dart.analysisServerMaxOldSpaceMemory": 4096,
  "dart.maxLogLineLength": 2000,
  "files.watcherExclude": {
    "**/.dart_tool/**": true,
    "**/build/**": true
  }
}
```

**Android Studio:**
- Increase heap size: **Preferences → Build, Execution, Deployment → Compiler**
- Exclude build folders: **Preferences → Editor → File Types → Ignore files and folders**
  - Add: `.dart_tool;build;*.g.dart;*.freezed.dart`

### 7.2 Dart Analysis Server

The Dart Analysis Server can consume significant resources. Optimize it:

```bash
# Restart Dart Analysis Server (VS Code)
Cmd/Ctrl+Shift+P → "Dart: Restart Analysis Server"

# Increase memory limit (VS Code settings.json)
"dart.analysisServerMaxOldSpaceMemory": 4096
```

---

## 8. Team Synchronization

### 8.1 Shared Configuration Files

Commit these IDE configuration files to Git:

```
.vscode/
├── settings.json       # VS Code settings
├── launch.json         # Debug configurations
├── tasks.json          # Build tasks
└── extensions.json     # Recommended extensions

.idea/
├── codeStyles/         # Android Studio code styles (optional)
└── runConfigurations/  # Run configurations (optional)
```

### 8.2 Recommended Extensions File

Create `.vscode/extensions.json` for team recommendations:

```json
{
  "recommendations": [
    "dart-code.flutter",
    "dart-code.dart-code",
    "jeroen-meijer.pubspec-assist",
    "nash.awesome-flutter-snippets",
    "usernamehw.errorlens",
    "eamodio.gitlens",
    "gruntfuggly.todo-tree"
  ]
}
```

---

## 9. Troubleshooting

### 9.1 Common IDE Issues

#### Issue: "Dart SDK not found"

**Solution (VS Code):**
```json
// settings.json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.sdkPath": "/path/to/flutter/bin/cache/dart-sdk"
}
```

**Solution (Android Studio):**
- **Preferences → Languages & Frameworks → Flutter**
- Set Flutter SDK path manually

#### Issue: "Code completion not working"

**Solution:**
```bash
# Restart Dart Analysis Server
# VS Code: Cmd/Ctrl+Shift+P → "Dart: Restart Analysis Server"
# Android Studio: File → Invalidate Caches / Restart
```

#### Issue: "Hot reload not working"

**Solution:**
- Ensure "Format on save" is not causing syntax errors
- Check console for compilation errors
- Try hot restart instead: `Shift+Cmd/Ctrl+P` → "Flutter: Hot Restart"

#### Issue: "Extension not loading in VS Code"

**Solution:**
```bash
# Reinstall extension
code --uninstall-extension Dart-Code.flutter
code --install-extension Dart-Code.flutter

# Clear VS Code cache
rm -rf ~/.vscode/extensions/dart-code.*
```

### 9.2 Performance Issues

#### Issue: "IDE slow/unresponsive"

**Solution:**
- Exclude build folders from indexing
- Increase IDE heap size
- Disable unnecessary plugins
- Close unused projects

---

## 10. IDE Validation Checklist

Use this checklist to validate IDE configuration:

### VS Code Validation
- [ ] VS Code version ≥ 1.85.0 installed
- [ ] Flutter extension installed and enabled
- [ ] Dart extension installed and enabled
- [ ] `.vscode/settings.json` configured with project settings
- [ ] `.vscode/launch.json` contains debug configurations
- [ ] Code formatting works (`Shift+Alt+F`)
- [ ] Hot reload works on save (`Cmd/Ctrl+S`)
- [ ] Dart Analysis Server running (check status bar)
- [ ] Code completion working
- [ ] Debugging with breakpoints works

### Android Studio Validation
- [ ] Android Studio version ≥ 2023.1 installed
- [ ] Flutter plugin installed and enabled
- [ ] Dart plugin installed and enabled
- [ ] Flutter SDK path configured
- [ ] Code formatting configured (80 char line length)
- [ ] Run configurations created for dev/staging/prod
- [ ] Hot reload enabled in settings
- [ ] Code completion working
- [ ] Debugging with breakpoints works

---

## 11. Best Practices

### 11.1 Code Organization

- Use consistent folder structure (see Folder Structure document)
- Keep files under 300 lines
- Extract reusable widgets to separate files
- Use barrel exports for cleaner imports

### 11.2 IDE Usage

- Use keyboard shortcuts for faster development
- Leverage code snippets for common patterns
- Use widget refactoring tools instead of manual editing
- Keep DevTools open during development for profiling

### 11.3 Team Collaboration

- Commit `.vscode/` and `.idea/` config files (exclude user-specific files)
- Document custom IDE settings in team wiki
- Use consistent formatting across team (enforced by pre-commit hooks)
- Share useful snippets and templates

---

## 12. References and Resources

### 12.1 Official Documentation

- VS Code Flutter Setup: https://flutter.dev/docs/get-started/editor?tab=vscode
- Android Studio Flutter Setup: https://flutter.dev/docs/get-started/editor?tab=androidstudio
- Flutter DevTools: https://flutter.dev/docs/development/tools/devtools/overview
- Dart Code Style Guide: https://dart.dev/guides/language/effective-dart/style

### 12.2 Internal Resources

- `docs/03_environment_setup/01_Flutter_Installation_Verification_Report.md`
- `docs/03_environment_setup/03_Emulator_Simulator_Setup_Guide.md`
- `analysis_options.yaml` - Project linting rules
- `.pre-commit-config.yaml` - Pre-commit hook configuration

---

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Next Review**: Quarterly or when IDE versions update  
**Status**: ✅ Complete
