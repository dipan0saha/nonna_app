#!/usr/bin/env bash
# Section 1 emulator walk-through with fixed pauses (watch the device; no integration harness).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEVICE="${ANDROID_SERIAL:-emulator-5554}"
APP=com.la_nonna.nonna_app
ACTIVITY=$APP/.MainActivity
PAUSE=2

sleep "$PAUSE"
echo "1.1 — pm clear + cold launch"
adb -s "$DEVICE" shell pm clear "$APP"
sleep "$PAUSE"
adb -s "$DEVICE" shell am start -n "$ACTIVITY"
sleep 5

echo "1.2–1.3 — use integration test OR tap Next/Skip on device manually"
echo "1.4 — airplane ON (watch offline banner)"
adb -s "$DEVICE" shell cmd connectivity airplane-mode enable
sleep "$PAUSE"
sleep 3

echo "1.5 — airplane OFF"
adb -s "$DEVICE" shell cmd connectivity airplane-mode disable
sleep "$PAUSE"
sleep 3

echo "1.6 — sign in as testuser_nonna@example.com on device, then re-run airplane ON/OFF on Home"
echo "Done. Prefer: flutter test integration_test/qa_manual_section_01_test.dart -d $DEVICE"
