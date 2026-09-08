#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

: "${SUPABASE_URL:?Missing SUPABASE_URL in .env}"
: "${SUPABASE_SERVICE_ROLE_KEY:?Missing SUPABASE_SERVICE_ROLE_KEY in .env}"

DEVICE="${ANDROID_SERIAL:-emulator-5554}"
if ! adb devices | grep -q "${DEVICE}[[:space:]]*device"; then
  echo "❌ No device at ${DEVICE}"
  exit 1
fi

echo "📦 Installing debug APK on ${DEVICE}..."
flutter build apk --debug
adb -s "$DEVICE" install -r build/app/outputs/flutter-apk/app-debug.apk

echo "🧪 Running OPS-010 + OPS-P1-012 integration sign-off..."
ANDROID_SERIAL="$DEVICE" flutter test integration_test/ops_device_signoff_test.dart \
  -d "$DEVICE" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_SERVICE_ROLE_KEY="$SUPABASE_SERVICE_ROLE_KEY"

echo "🧪 Running full onboarding E2E sign-off (owner + follower + co-owner)..."
ANDROID_SERIAL="$DEVICE" flutter test integration_test/onboarding_e2e_signoff_test.dart \
  -d "$DEVICE" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_SERVICE_ROLE_KEY="$SUPABASE_SERVICE_ROLE_KEY"

echo "✅ OPS emulator sign-off tests passed"
