#!/bin/bash

set -e  # Exit on any error

# Configuration
EMULATOR_NAME="${EMULATOR_NAME:-Pixel_5_API_33}"
TIMEOUT_BOOT=120
TIMEOUT_SETTLE=3

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Main script
main() {
    log_info "🚀 Nonna App Integration Tests Automation"
    echo ""
    
    # Step 1: Get device information
    log_info "Step 1: Checking for available devices..."
    DEVICE_COUNT=$(adb devices | grep -c "device$" || true)
    
    if [ "$DEVICE_COUNT" -eq 0 ]; then
        log_warning "No emulator/device connected. Starting emulator: $EMULATOR_NAME"
        
        # Check if emulator exists
        if ! emulator -list-avds | grep -q "^${EMULATOR_NAME}$"; then
            log_error "Emulator '$EMULATOR_NAME' not found. Available emulators:"
            emulator -list-avds
            exit 1
        fi
        
        # Start emulator
        log_info "Starting Android Emulator..."
        emulator -avd "$EMULATOR_NAME" -wipe-data &
        EMULATOR_PID=$!
        log_success "Emulator process started (PID: $EMULATOR_PID)"
        
        # Wait for emulator to boot
        log_info "Waiting for emulator to boot (max ${TIMEOUT_BOOT}s)..."
        BOOT_SUCCESS=0
        for ((i=0; i<TIMEOUT_BOOT; i+=5)); do
            if adb shell getprop sys.boot_completed 2>/dev/null | grep -q 1; then
                BOOT_SUCCESS=1
                break
            fi
            echo -ne "⏳ $((TIMEOUT_BOOT - i))s remaining...\r"
            sleep 5
        done
        
        if [ $BOOT_SUCCESS -eq 0 ]; then
            log_error "Emulator failed to boot within ${TIMEOUT_BOOT}s"
            kill $EMULATOR_PID 2>/dev/null || true
            exit 1
        fi
        
        log_success "Emulator booted successfully"
        sleep 5  # Additional stabilization
    else
        log_success "Found $DEVICE_COUNT connected device(s)"
    fi
    
    echo ""
    
    # Step 2: Get device ID
    log_info "Step 2: Identifying device..."
    DEVICE_ID=$(adb devices | grep "device$" | awk '{print $1}' | head -1)
    
    if [ -z "$DEVICE_ID" ]; then
        log_error "No valid device found after boot"
        exit 1
    fi
    
    log_success "Using device: $DEVICE_ID"
    echo ""
    
    # Step 3: Set up environment
    log_info "Step 3: Setting up environment..."
    
    if [ ! -f ".env" ]; then
        log_warning ".env file not found. Copying from .env.example..."
        if [ -f ".env.example" ]; then
            cp .env.example .env
            log_success "Created .env from .env.example"
            log_warning "⚠️  Please ensure you fill in actual credentials if needed"
        else
            log_warning ".env.example not found either. Proceeding without .env"
        fi
    else
        log_success ".env file exists"
    fi
    
    echo ""
    
    # Step 4: Verify Flutter environment
    log_info "Step 4: Verifying Flutter environment..."
    
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter not found in PATH"
        exit 1
    fi
    
    log_success "Flutter SDK found: $(flutter --version | head -1)"
    
    if ! flutter pub get > /dev/null 2>&1; then
        log_warning "Could not update pub dependencies, attempting to continue with existing..."
    fi
    
    echo ""
    
    # Step 5: Run integration tests
    log_info "Step 5: Running Flutter Integration Tests..."
    log_info "This may take several minutes on first run..."
    echo ""
    
    if flutter test integration_test/app_test.dart -d "$DEVICE_ID" --verbose; then
        log_success "All integration tests passed! 🎉"
        echo ""
        log_success "Test Summary:"
        log_success "  ✓ Authentication flows"
        log_success "  ✓ Baby profile management"
        log_success "  ✓ Dashboard functionality"
        log_success "  ✓ Gallery features"
        log_success "  ✓ Events management"
        log_success "  ✓ Registry features"
        log_success "  ✓ Gamification"
        log_success "  ✓ Notifications"
        echo ""
        return 0
    else
        log_error "Integration tests failed!"
        echo ""
        log_info "Debugging tips:"
        log_info "  1. Check Android emulator logs: adb logcat | grep flutter"
        log_info "  2. Verify test credentials: seed+10000000@example.local / password123"
        log_info "  3. Ensure .env file has required configuration"
        log_info "  4. Restart emulator: emulator -avd $EMULATOR_NAME"
        echo ""
        return 1
    fi
}

# Cleanup on exit
cleanup() {
    if [ ! -z "$EMULATOR_PID" ] && kill -0 "$EMULATOR_PID" 2>/dev/null; then
        log_info "Shutting down emulator..."
        kill $EMULATOR_PID 2>/dev/null || true
        wait $EMULATOR_PID 2>/dev/null || true
        log_success "Emulator stopped"
    fi
}

trap cleanup EXIT

# Run main function
main
