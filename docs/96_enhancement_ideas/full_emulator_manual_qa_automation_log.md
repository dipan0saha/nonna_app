# Full emulator QA — automation gate log

Append a row after each `./scripts/qa_run_automation_gates.sh` run. Manual checklist items stay in [full_emulator_manual_qa_checklist.md](./full_emulator_manual_qa_checklist.md).

| Date | Device | Result | Notes |
|------|--------|--------|-------|
| 2026-09-19 | emulator-5554 | partial | Preflight OK; `onboarding_owner_flow` + route/deep_link unit tests pass; E2E/OPS had carousel Skip flake before `test_helper` + OPS fixes — re-run gates after pull |

**Re-run:**

```bash
cd nonna_app
./scripts/qa_emulator_preflight.sh
./scripts/qa_run_automation_gates.sh
```
