#!/usr/bin/env bash
# Section 0 preflight for full emulator manual QA (see docs/96_enhancement_ideas/full_emulator_manual_qa_checklist.md)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

APP_ID="com.la_nonna.nonna_app"
DEVICE="${ANDROID_SERIAL:-emulator-5554}"

echo "=== Nonna QA preflight (Section 0) ==="

echo ""
echo "0.1 Flutter / adb devices"
if adb devices 2>/dev/null | grep -qE "^${DEVICE}[[:space:]]+device$"; then
  echo "✅ adb device ${DEVICE}"
elif flutter devices --machine 2>/dev/null | grep -q "\"${DEVICE}\""; then
  echo "✅ Flutter device ${DEVICE}"
else
  echo "❌ Expected device ${DEVICE} not found. Start emulator or set ANDROID_SERIAL."
  exit 1
fi

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
else
  echo "❌ Missing .env at ${ROOT}/.env"
  exit 1
fi

echo ""
echo "0.2 verify_config.py"
VERIFY_PY="python3"
for candidate in "${ROOT}/.venv-qa/bin/python" "${ROOT}/.venv/bin/python"; do
  if [[ -x "$candidate" ]]; then
    VERIFY_PY="$candidate"
    break
  fi
done
if "$VERIFY_PY" scripts/verify_config.py; then
  echo "✅ verify_config passed (${VERIFY_PY})"
else
  echo "⚠️  verify_config failed — run: python3 -m venv .venv-qa && .venv-qa/bin/pip install python-dotenv"
fi

echo ""
echo "0.3 Supabase auth endpoint"
if [[ -z "${SUPABASE_URL:-}" ]]; then
  echo "❌ SUPABASE_URL not set"
  exit 1
fi
HTTP_LINE="$(curl -sI "${SUPABASE_URL}/auth/v1/health" | head -1 || true)"
echo "   ${HTTP_LINE}"
if echo "$HTTP_LINE" | grep -qE 'HTTP/[0-9.]+ [23]'; then
  echo "✅ Auth health returned 2xx/3xx"
elif echo "$HTTP_LINE" | grep -qE 'HTTP/[0-9.]+ 401'; then
  echo "✅ Auth endpoint reachable (401 without credentials is OK)"
else
  echo "❌ Unexpected auth health response — check project not paused / DNS"
  exit 1
fi

echo ""
echo "0.4 SUPABASE_URL host"
REF="${SUPABASE_PROJECT_ID:-}"
if [[ -n "$REF" ]] && [[ "$SUPABASE_URL" == *"${REF}"* ]]; then
  echo "✅ SUPABASE_URL contains project ref ${REF}"
else
  echo "⚠️  Confirm SUPABASE_URL matches SUPABASE_PROJECT_ID in dashboard"
fi

echo ""
echo "0.6–0.8 Helpers (copy/paste)"
echo "   Returning user: testuser_nonna@example.com (see skill reference.md)"
echo "   E2E disposable: qa-e2e-*@nonna.qa / Password123!"
echo "   Cold start: adb -s ${DEVICE} shell pm clear ${APP_ID}"
echo "   Deep link:  adb -s ${DEVICE} shell am start -a android.intent.action.VIEW -d \"nonna://app/invite-accept?token=TOKEN\""

if adb devices 2>/dev/null | grep -q "${DEVICE}[[:space:]]*device"; then
  echo ""
  echo "✅ adb sees ${DEVICE}"
else
  echo ""
  echo "⚠️  adb does not list ${DEVICE} as device (deep links / pm clear need adb)"
fi

echo ""
echo "=== Preflight done. Run manual checklist or: ./scripts/qa_run_automation_gates.sh ==="
