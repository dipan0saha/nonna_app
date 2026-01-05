#!/bin/bash

# Flutter Installation Verification Report
echo "Flutter Installation Verification Report - $(date)"
echo "---------------------------------------------------------------------"

echo -e "\033[1mVerifying installation of Xcode Command Line Tools...\033[0m"
xcode-select -p > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "\033[32m✓ Installed.\033[0m"
else
    echo -e "\033[31m✗ Not installed.\033[0m"
fi
echo ""

echo -e "\033[1mVerifying installation of Flutter SDK...\033[0m"
flutter --version
if [ $? -eq 0 ]; then
    echo -e "\033[32m✓ Installed.\033[0m"
else
    echo -e "\033[31m✗ Not installed.\033[0m"
fi
echo ""

echo -e "\033[1mVerifying installation of dart SDK...\033[0m"
dart --version
if [ $? -eq 0 ]; then
    echo -e "\033[32m✓ Installed.\033[0m"
else
    echo -e "\033[31m✗ Not installed.\033[0m"
fi
echo ""

# # Run Flutter doctor
# echo -e "\033[1mFlutter Doctor Report:\033[0m"
# flutter doctor > flutter_doctor_report.txt
# cat flutter_doctor_report.txt
# echo ""

echo -e "\033[1mVerifying installation of CocoaPods...\033[0m"
pod --version > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "\033[32m✓ Installed.\033[0m"
else
    echo -e "\033[31m✗ Not installed.\033[0m"
fi
echo ""

echo -e "\033[1mEnvironment Variables:\033[0m"
if [ -n "$FLUTTER_ROOT" ]; then
    echo -e "\033[32m✓ FLUTTER_ROOT: $FLUTTER_ROOT\033[0m"
else
    echo -e "\033[31m✗ FLUTTER_ROOT: Not set\033[0m"
fi
if [ -n "$ANDROID_HOME" ]; then
    echo -e "\033[32m✓ ANDROID_HOME: $ANDROID_HOME\033[0m"
else
    echo -e "\033[31m✗ ANDROID_HOME: Not set\033[0m"
fi
if [ -n "$JAVA_HOME" ]; then
    echo -e "\033[32m✓ JAVA_HOME: $JAVA_HOME\033[0m"
else
    echo -e "\033[31m✗ JAVA_HOME: Not set\033[0m"
fi
echo ""

# echo -e "\033[1mFixing "Slow Flutter pub get" issues...\033[0m"
# # Clear pub cache
# flutter pub cache clean > /dev/null 2>&1

# # Use pub cache repair
# flutter pub cache repair > /dev/null 2>&1

# # Clean build artifacts (weekly)
# flutter clean > /dev/null 2>&1

# # Re-run pub get
# flutter pub get

# Document current Flutter version in project
echo -e "\033[1mDocumenting current Flutter version in FLUTTER_VERSION.txt\033[0m"
flutter --version > FLUTTER_VERSION.txt
echo ""

# Verify no issues with flutter analyze
echo -e "\033[1mVerifying flutter analyze...\033[0m"
flutter analyze
echo ""

# Verify git configuration
echo -e "\033[1mGlobal Git Configuration:\033[0m"
git --version
git config --list --global
echo ""

git status --short
echo ""
echo -e "\033[1mEnd of Flutter Development Environment Verification Report\033[0m"
echo ""

# List remote repositories
git remote -v
echo ""

# Set default branch name
git config --global init.defaultBranch main

# Set default editor
git config --global core.editor "code --wait"  # VS Code
# Or: git config --global core.editor "vim"    # Vim

# Enable color output
git config --global color.ui auto

# Set merge strategy
git config --global merge.ff false

# Enable rerere (reuse recorded resolution)
git config --global rerere.enabled true

# Set pull strategy (rebase by default)
git config --global pull.rebase true

# Set push strategy (current branch only)
git config --global push.default current

# Enable credential caching (macOS)
git config --global credential.helper osxkeychain

# Set line ending handling (cross-platform)
git config core.autocrlf input

# View all local config
echo -e "\033[1mLocal Git Configuration:\033[0m"
git config --list --local
echo ""

# View all global config
echo -e "\033[1mGlobal Git Configuration:\033[0m"
git config --list --global
echo ""

# View all system config
echo -e "\033[1mSystem Git Configuration:\033[0m"
git config --list --system
echo ""

# Verify pre-commit hooks
echo -e "\033[1mVerifying pre-commit hooks...\033[0m"
pre-commit --version
echo ""
# Optional: Remove pauses if you want automated output, or keep for manual review
# read -p "Press [Enter] to continue..."
