#!/usr/bin/env bash
# Integration smoke aligned with full_emulator_manual_qa_checklist.md automation table.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

DEVICE="${ANDROID_SERIAL:-emulator-5554}"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

if ! adb devices 2>/dev/null | grep -qE "^${DEVICE}[[:space:]]+device$"; then
  echo "❌ No adb device ${DEVICE}"
  exit 1
fi

APP_ID="com.la_nonna.nonna_app"
echo "Clearing app data on ${DEVICE} (${APP_ID}) for consistent auth routing..."
adb -s "$DEVICE" shell pm clear "$APP_ID" >/dev/null 2>&1 || true

DART_DEFINES=()
if [[ -n "${SUPABASE_URL:-}" ]] && [[ -n "${SUPABASE_SERVICE_ROLE_KEY:-}" ]]; then
  DART_DEFINES=(
    --dart-define=SUPABASE_URL="$SUPABASE_URL"
    --dart-define=SUPABASE_SERVICE_ROLE_KEY="$SUPABASE_SERVICE_ROLE_KEY"
  )
fi

run_test() {
  local file="$1"
  echo ""
  echo "🧪 flutter test ${file} -d ${DEVICE}"
  # shellcheck disable=SC2068
  ANDROID_SERIAL="$DEVICE" flutter test "$file" -d "$DEVICE" ${DART_DEFINES[@]:-}
  return $?
}

TESTS=(
  integration_test/onboarding_owner_flow_test.dart
  integration_test/fd_00_auth_navigation_test.dart
  integration_test/fd_01_profile_followers_test.dart
  integration_test/fd_02_feature_flows_test.dart
  integration_test/fd_03_settings_logout_test.dart
  integration_test/fd_04_gallery_notifications_test.dart
  integration_test/fd_05_context_constraints_test.dart
  integration_test/auth_integration_test.dart
  integration_test/baby_profile_integration_test.dart
  integration_test/dashboard_integration_test.dart
  integration_test/gallery_integration_test.dart
  integration_test/events_integration_test.dart
  integration_test/registry_integration_test.dart
  integration_test/gamification_integration_test.dart
  integration_test/notifications_integration_test.dart
)

FAILED=()
for t in "${TESTS[@]}"; do
  if ! run_test "$t"; then
    FAILED+=("$t")
  fi
done

if [[ ${#DART_DEFINES[@]} -gt 0 ]]; then
  for t in integration_test/ops_device_signoff_test.dart integration_test/onboarding_e2e_signoff_test.dart; do
    if ! run_test "$t"; then
      FAILED+=("$t")
    fi
  done
else
  echo ""
  echo "⚠️  Skipping ops_device_signoff + onboarding_e2e_signoff (need SUPABASE_SERVICE_ROLE_KEY in .env)"
fi

echo ""
if [[ ${#FAILED[@]} -eq 0 ]]; then
  echo "✅ Automation gates finished — all passed"
else
  echo "❌ Failed (${#FAILED[@]}):"
  printf '   - %s\n' "${FAILED[@]}"
  exit 1
fi
