#!/usr/bin/env python3
"""
RLS Test Runner - Executes all RLS policy tests and generates a comprehensive report
"""

import os
import re
import subprocess
from collections import defaultdict
from datetime import datetime
from pathlib import Path

# Configuration
TEST_DIR = "/Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/supabase/tests/rls_policies"
CONNECTION_STRING = "postgresql://postgres.ubptybhhrgdiyfkcqgwu:LaNonnaApp24!!@aws-1-us-east-2.pooler.supabase.com:5432/postgres"
TIMEOUT = 30


def run_test(test_file_path):
    """Run a single test file and return (passed, failed, error_msg)"""
    try:
        result = subprocess.run(
            ["psql", CONNECTION_STRING, "-f", test_file_path],
            capture_output=True,
            text=True,
            timeout=TIMEOUT,
        )

        output = result.stdout + result.stderr

        # Count 'ok' tests (successful)
        ok_count = len(re.findall(r"^\s*ok\s+\d+", output, re.MULTILINE))

        # Count 'not ok' tests (failures)
        not_ok_count = len(re.findall(r"^\s*not ok\s+\d+", output, re.MULTILINE))

        # Check for recursion or other errors
        error_msg = ""
        if "infinite recursion" in output.lower():
            error_msg = "INFINITE RECURSION DETECTED"
        elif "permission denied" in output.lower():
            error_msg = "Permission denied"
        elif result.returncode != 0 and not ok_count:
            # Extract meaningful error
            error_lines = [l for l in output.split("\n") if "ERROR:" in l]
            if error_lines:
                error_msg = error_lines[0].strip()[:80]

        return ok_count, not_ok_count, error_msg

    except subprocess.TimeoutExpired:
        return 0, 0, "TIMEOUT (30s)"
    except Exception as e:
        return 0, 0, f"Exception: {str(e)[:60]}"


def main():
    print("=" * 100)
    print("RLS POLICY TEST SUITE RUNNER")
    print("=" * 100)
    print(f"\nTest Directory: {TEST_DIR}")
    print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

    # Get all test files
    test_files = sorted([f for f in os.listdir(TEST_DIR) if f.endswith("_test.sql")])

    if not test_files:
        print("❌ No test files found!")
        return

    print(f"Found {len(test_files)} test files\n")
    print("-" * 100)

    # Run all tests
    results = {}
    total_passed = 0
    total_failed = 0

    for i, test_file in enumerate(test_files, 1):
        test_path = os.path.join(TEST_DIR, test_file)
        test_name = test_file.replace("_rls_test.sql", "").replace("_", " ").title()

        print(
            f"[{i:2d}/{len(test_files)}] Running {test_name:40s} ... ",
            end="",
            flush=True,
        )

        passed, failed, error = run_test(test_path)

        if error:
            status = "❌ ERROR"
            print(f"{status:30s} {error}")
        elif passed > 0:
            status = "✅ PASS"
            total = passed + failed
            print(f"{status:30s} {passed}/{total} tests passed")
            total_passed += passed
            total_failed += failed
        else:
            status = "⚠️  SKIP"
            print(f"{status:30s} No tests detected")

        results[test_file] = {
            "passed": passed,
            "failed": failed,
            "error": error,
            "status": status,
        }

    # Generate summary report
    print("\n" + "=" * 100)
    print("TEST SUMMARY REPORT")
    print("=" * 100 + "\n")

    # Statistics
    passed_count = sum(
        1 for r in results.values() if r["passed"] > 0 and not r["error"]
    )
    failed_count = sum(1 for r in results.values() if r["failed"] > 0)
    error_count = sum(1 for r in results.values() if r["error"])

    print(f"Total Test Files:     {len(test_files)}")
    print(f"  ✅ Passing:         {passed_count}")
    print(f"  ⚠️  With Failures:   {failed_count}")
    print(f"  ❌ With Errors:     {error_count}")
    print(f"\nTotal Tests Executed: {total_passed + total_failed}")
    print(f"  ✅ Passed:          {total_passed}")
    print(f"  ❌ Failed:          {total_failed}")

    if total_passed + total_failed > 0:
        success_rate = (total_passed / (total_passed + total_failed)) * 100
        print(f"  📊 Success Rate:    {success_rate:.1f}%")

    # Detailed results by status
    print("\n" + "-" * 100)
    print("DETAILED RESULTS BY STATUS")
    print("-" * 100 + "\n")

    # Passing tests
    passing = [(f, r) for f, r in results.items() if r["passed"] > 0 and not r["error"]]
    if passing:
        print("✅ PASSING TESTS:")
        for test_file, result in passing:
            test_name = test_file.replace("_rls_test.sql", "")
            total = result["passed"] + result["failed"]
            print(f"  • {test_name:40s} {result['passed']}/{total} tests passed")

    # Tests with failures
    failing = [(f, r) for f, r in results.items() if r["failed"] > 0]
    if failing:
        print("\n⚠️  TESTS WITH FAILURES:")
        for test_file, result in failing:
            test_name = test_file.replace("_rls_test.sql", "")
            total = result["passed"] + result["failed"]
            print(f"  • {test_name:40s} {result['failed']}/{total} tests failed")

    # Tests with errors
    errors = [(f, r) for f, r in results.items() if r["error"]]
    if errors:
        print("\n❌ TESTS WITH ERRORS:")
        for test_file, result in errors:
            test_name = test_file.replace("_rls_test.sql", "")
            print(f"  • {test_name:40s} {result['error']}")

    # Tests with no detection (likely empty or syntax error)
    no_tests = [
        (f, r)
        for f, r in results.items()
        if r["passed"] == 0 and r["failed"] == 0 and not r["error"]
    ]
    if no_tests:
        print("\n⏭️  TESTS WITH NO DETECTION:")
        for test_file, result in no_tests:
            test_name = test_file.replace("_rls_test.sql", "")
            print(f"  • {test_name:40s} (No tests found)")

    # Final status
    print("\n" + "=" * 100)
    if error_count == 0 and failed_count == 0:
        print("🎉 ALL TESTS PASSED SUCCESSFULLY!")
    elif error_count > 0:
        print("⚠️  SOME TESTS HAVE ERRORS - REVIEW REQUIRED")
    else:
        print(f"📊 {failed_count} test files have failures - Review required")
    print("=" * 100)

    return results


if __name__ == "__main__":
    main()
