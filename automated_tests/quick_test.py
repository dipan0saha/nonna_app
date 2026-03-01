#!/usr/bin/env python3
"""
Quick test runner for specific test categories
Usage: python3 quick_test.py <category> [subcategory]
"""

import re
import subprocess
import sys
from pathlib import Path


def run_test(test_path: str) -> tuple:
    """Run a single test and return pass/fail counts."""
    try:
        cmd = f"flutter test {test_path} --reporter=compact 2>&1"
        result = subprocess.run(
            cmd, shell=True, capture_output=True, text=True, timeout=300
        )
        output = result.stdout + result.stderr

        # Parse output for test counts
        match = re.search(r"\+(\d+)(?:\s+~\d+)?\s+-(\d+):", output)
        if match:
            passed = int(match.group(1))
            failed = int(match.group(2))
            return passed, failed

        if "All tests passed" in output:
            match = re.search(r"\+(\d+):", output)
            if match:
                return int(match.group(1)), 0

        return 0, 0
    except Exception as e:
        print(f"Error: {e}")
        return 0, 0


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 quick_test.py <category> [subcategory]")
        print("\nCategories:")
        print("  core       - Run all core tests")
        print("  features   - Run all feature tests")
        print("  tiles      - Run all tiles tests")
        print("  all        - Run all tests at once")
        print("\nExamples:")
        print("  python3 quick_test.py core")
        print("  python3 quick_test.py core models")
        print("  python3 quick_test.py features auth")
        print("  python3 quick_test.py tiles checklist")
        sys.exit(1)

    category = sys.argv[1].lower()
    subcategory = sys.argv[2].lower() if len(sys.argv) > 2 else None

    if category == "all":
        print("🚀 Running ALL tests (this will take a while)...")
        test_path = "test"
    elif category == "core":
        if subcategory:
            test_path = f"test/core/{subcategory}"
        else:
            test_path = "test/core"
    elif category == "features":
        if subcategory:
            test_path = f"test/features/{subcategory}/presentation"
        else:
            test_path = "test/features"
    elif category == "tiles":
        if subcategory:
            test_path = f"test/tiles/{subcategory}"
        else:
            test_path = "test/tiles"
    elif category == "accessibility":
        test_path = "test/accessibility"
    elif category == "l10n":
        test_path = "test/l10n"
    else:
        print(f"Unknown category: {category}")
        sys.exit(1)

    print(f"🧪 Running: {test_path}\n")
    passed, failed = run_test(test_path)

    print("\n" + "=" * 50)
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")
    print("=" * 50)

    if failed > 0:
        print(f"\n⚠️  {failed} test(s) failed")
        sys.exit(1)
    else:
        print(f"\n✅ All {passed} tests passed!")
        sys.exit(0)


if __name__ == "__main__":
    main()
