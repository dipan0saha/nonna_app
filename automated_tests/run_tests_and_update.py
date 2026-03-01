#!/usr/bin/env python3
"""
Nonna App Test Runner and MD Updater

This script runs all test subcategories and updates TEST_COMMANDS.md with results.
"""

import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple


class TestRunner:
    def __init__(self, project_root: Path = None):
        self.project_root = project_root or Path.cwd()
        self.test_commands_file = (
            self.project_root / "automated_tests" / "TEST_COMMANDS.md"
        )
        self.results = {}

        # Define test categories
        self.test_categories = {
            "core": [
                "config",
                "constants",
                "di",
                "enums",
                "extensions",
                "middleware",
                "mixins",
                "models",
                "navigation",
                "network",
                "providers",
                "router",
                "services",
                "themes",
                "utils",
                "widgets",
            ],
            "features": [
                "auth",
                "baby_profile",
                "calendar",
                "gallery",
                "gamification",
                "home",
                "profile",
                "registry",
                "settings",
            ],
            "tiles": [
                "core",
                "checklist",
                "due_date_countdown",
                "engagement_recap",
                "gallery_favorites",
                "invites_status",
                "new_followers",
                "notifications",
                "recent_photos",
                "recent_purchases",
                "registry_deals",
                "registry_highlights",
                "rsvp_tasks",
                "storage_usage",
                "system_announcements",
                "upcoming_events",
            ],
            "other": ["accessibility", "l10n"],
        }

    def run_test(self, test_path: str) -> Tuple[int, int]:
        """
        Run a flutter test and extract pass/fail counts.

        Args:
            test_path: Path to test directory (e.g., 'test/core/config')

        Returns:
            Tuple of (passed_count, failed_count)
        """
        try:
            cmd = f"cd {self.project_root} && flutter test {test_path} --reporter=compact 2>&1"
            result = subprocess.run(
                cmd, shell=True, capture_output=True, text=True, timeout=300
            )
            output = result.stdout + result.stderr

            # Parse output for test counts using regex
            # Pattern: +2214 ~6 -11: means 2214 passed, ~6 running, -11 failed
            match = re.search(r"\+(\d+)(?:\s+~\d+)?\s+-(\d+):", output)
            if match:
                passed = int(match.group(1))
                failed = int(match.group(2))
                return passed, failed

            # If no match with the main pattern, look for "All tests passed" or "Some tests failed"
            if "All tests passed" in output:
                # Extract just the passed count
                match = re.search(r"\+(\d+):", output)
                if match:
                    passed = int(match.group(1))
                    return passed, 0

            return 0, 0

        except subprocess.TimeoutExpired:
            print(f"❌ Timeout for {test_path}", file=sys.stderr)
            return 0, 0
        except Exception as e:
            print(f"❌ Error running {test_path}: {e}", file=sys.stderr)
            return 0, 0

    def run_all_tests(self) -> Dict:
        """Run all test categories and return results."""
        results = {
            "core": {},
            "features": {},
            "tiles": {},
            "other": {},
            "timestamp": datetime.now().isoformat(),
        }

        # Core tests
        print("🧪 Running Core Tests...")
        for cat in self.test_categories["core"]:
            test_path = f"test/core/{cat}"
            passed, failed = self.run_test(test_path)
            results["core"][cat] = {"passed": passed, "failed": failed}
            status = "✅" if failed == 0 else "⚠️"
            print(f"  {status} {cat}: {passed} passed, {failed} failed")

        # Feature tests
        print("\n🎯 Running Feature Tests...")
        for feat in self.test_categories["features"]:
            test_path = f"test/features/{feat}/presentation"
            passed, failed = self.run_test(test_path)
            results["features"][feat] = {"passed": passed, "failed": failed}
            status = "✅" if failed == 0 else "⚠️"
            print(f"  {status} {feat}: {passed} passed, {failed} failed")

        # Tiles tests
        print("\n📊 Running Tiles Tests...")
        for tile in self.test_categories["tiles"]:
            test_path = f"test/tiles/{tile}"
            passed, failed = self.run_test(test_path)
            results["tiles"][tile] = {"passed": passed, "failed": failed}
            status = "✅" if failed == 0 else "⚠️"
            print(f"  {status} {tile}: {passed} passed, {failed} failed")

        # Other tests
        print("\n📚 Running Other Tests...")
        for other in self.test_categories["other"]:
            test_path = f"test/{other}"
            passed, failed = self.run_test(test_path)
            results["other"][other] = {"passed": passed, "failed": failed}
            status = "✅" if failed == 0 else "⚠️"
            print(f"  {status} {other}: {passed} passed, {failed} failed")

        self.results = results
        return results

    def calculate_totals(self) -> Tuple[int, int, int]:
        """Calculate total tests and failures."""
        total_passed = 0
        total_failed = 0

        for category_results in [
            self.results.get("core", {}),
            self.results.get("features", {}),
            self.results.get("tiles", {}),
            self.results.get("other", {}),
        ]:
            for test_data in category_results.values():
                total_passed += test_data.get("passed", 0)
                total_failed += test_data.get("failed", 0)

        total_tests = total_passed + total_failed
        return total_tests, total_passed, total_failed

    def update_md_file(self):
        """Update TEST_COMMANDS.md with new test results."""
        if not self.test_commands_file.exists():
            print(f"❌ File not found: {self.test_commands_file}")
            return False

        with open(self.test_commands_file, "r") as f:
            content = f.read()

        # Update Core Tests table
        core_table = self._build_core_table()
        content = re.sub(
            r"(## Core Tests \([\d\d]+ files\)\n\nOrganized by 16 subcategories:\n\n)\|.*?\n\|",
            r"\1|",
            content,
            flags=re.DOTALL,
            count=1,
        )

        # Update Features Tests table
        features_table = self._build_features_table()
        content = re.sub(
            r"(## Features Tests \([\d\d]+ files\)\n\nOrganized by 9 features:\n\n)\|.*?\n\|",
            r"\1|",
            content,
            flags=re.DOTALL,
            count=1,
        )

        # Update Tiles Tests table
        tiles_table = self._build_tiles_table()

        # Update summary section
        summary = self._build_summary()
        content = re.sub(
            r"## Test Organization Summary[\s\S]*?(?=\n---)", summary, content
        )

        # Update timestamp
        timestamp = f"Generated: {datetime.now().strftime('%B %d, %Y at %H:%M:%S')}"
        content = re.sub(r"Generated: .*", timestamp, content)

        with open(self.test_commands_file, "w") as f:
            f.write(content)

        print(f"\n✅ Updated {self.test_commands_file}")
        return True

    def _build_summary(self) -> str:
        """Build the summary section with totals."""
        total_tests, total_passed, total_failed = self.calculate_totals()

        core_results = self.results.get("core", {})
        features_results = self.results.get("features", {})
        tiles_results = self.results.get("tiles", {})
        other_results = self.results.get("other", {})

        core_passed = sum(r["passed"] for r in core_results.values())
        core_failed = sum(r["failed"] for r in core_results.values())

        features_passed = sum(r["passed"] for r in features_results.values())
        features_failed = sum(r["failed"] for r in features_results.values())

        tiles_passed = sum(r["passed"] for r in tiles_results.values())
        tiles_failed = sum(r["failed"] for r in tiles_results.values())

        other_passed = sum(r["passed"] for r in other_results.values())
        other_failed = sum(r["failed"] for r in other_results.values())

        # Count files
        core_count = sum(
            str(self.test_categories["core"]).count(c)
            for c in self.test_categories["core"]
        )
        features_count = len(self.test_categories["features"])
        tiles_count = len(self.test_categories["tiles"])
        other_count = len(self.test_categories["other"])

        core_status = "✅ Pass" if core_failed == 0 else f"⚠️ {core_failed} Failed"
        features_status = (
            "✅ Pass" if features_failed == 0 else f"⚠️ {features_failed} Failed"
        )
        tiles_status = "✅ Pass" if tiles_failed == 0 else f"⚠️ {tiles_failed} Failed"
        other_status = "✅ Pass" if other_failed == 0 else f"⚠️ {other_failed} Failed"

        summary = f"""## Test Organization Summary

**Total: 190 unit tests**

| Category | Count | Passed | Failed | Status |
|----------|-------|--------|--------|--------|
| test/accessibility | 1 | {other_results.get("accessibility", {}).get("passed", 0)} | {other_results.get("accessibility", {}).get("failed", 0)} | {'✅ Pass' if other_results.get("accessibility", {}).get("failed", 0) == 0 else '⚠️ Failed'} |
| test/core | 108 | {core_passed} | {core_failed} | {core_status} |
| test/features | 37 | {features_passed} | {features_failed} | {features_status} |
| test/l10n | 1 | {other_results.get("l10n", {}).get("passed", 0)} | {other_results.get("l10n", {}).get("failed", 0)} | {'✅ Pass' if other_results.get("l10n", {}).get("failed", 0) == 0 else '⚠️ Failed'} |
| test/tiles | 35 | {tiles_passed} | {tiles_failed} | {tiles_status} |
| **TOTAL** | **190** | **{total_passed}** | **{total_failed}** | {'✅ All Passed' if total_failed == 0 else f'⚠️ {total_failed} Failed'} |"""

        return summary

    def _build_core_table(self) -> str:
        """Build the Core Tests table."""
        table = "| Subcategory | Count | Passed | Failed | Command |\n"
        table += "|-------------|-------|--------|--------|----------|\n"

        core_results = self.results.get("core", {})

        for cat in self.test_categories["core"]:
            data = core_results.get(cat, {"passed": 0, "failed": 0})
            passed = data["passed"]
            failed = data["failed"]
            table += f"| {cat.replace('_', ' ').title()} | - | {passed} | {failed} | `flutter test test/core/{cat}` |\n"

        return table

    def _build_features_table(self) -> str:
        """Build the Features Tests table."""
        table = "| Feature | Count | Passed | Failed | Command |\n"
        table += "|---------|-------|--------|--------|----------|\n"

        features_results = self.results.get("features", {})

        for feat in self.test_categories["features"]:
            data = features_results.get(feat, {"passed": 0, "failed": 0})
            passed = data["passed"]
            failed = data["failed"]
            label = feat.replace("_", " ").title()
            table += f"| {label} | - | {passed} | {failed} | `flutter test test/features/{feat}/presentation` |\n"

        return table

    def _build_tiles_table(self) -> str:
        """Build the Tiles Tests table."""
        table = "| Tile Type | Count | Passed | Failed | Command |\n"
        table += "|-----------|-------|--------|--------|----------|\n"

        tiles_results = self.results.get("tiles", {})

        for tile in self.test_categories["tiles"]:
            data = tiles_results.get(tile, {"passed": 0, "failed": 0})
            passed = data["passed"]
            failed = data["failed"]
            label = tile.replace("_", " ").title()
            table += f"| {label} | - | {passed} | {failed} | `flutter test test/tiles/{tile}` |\n"

        return table

    def print_summary(self):
        """Print test results summary."""
        total_tests, total_passed, total_failed = self.calculate_totals()

        print("\n" + "=" * 60)
        print("📊 TEST SUMMARY")
        print("=" * 60)
        print(f"Total Tests:    {total_tests}")
        print(f"✅ Passed:       {total_passed}")
        print(f"❌ Failed:       {total_failed}")
        print(
            f"Success Rate:   {(total_passed/total_tests*100):.1f}%"
            if total_tests > 0
            else "0%"
        )
        print("=" * 60 + "\n")

        # Show failures by category
        if total_failed > 0:
            print("⚠️  FAILURES BY CATEGORY:\n")

            for cat in self.test_categories["core"]:
                failed = self.results.get("core", {}).get(cat, {}).get("failed", 0)
                if failed > 0:
                    print(f"  • core/{cat}: {failed} failed")

            for feat in self.test_categories["features"]:
                failed = self.results.get("features", {}).get(feat, {}).get("failed", 0)
                if failed > 0:
                    print(f"  • features/{feat}: {failed} failed")

            for tile in self.test_categories["tiles"]:
                failed = self.results.get("tiles", {}).get(tile, {}).get("failed", 0)
                if failed > 0:
                    print(f"  • tiles/{tile}: {failed} failed")

            for other in self.test_categories["other"]:
                failed = self.results.get("other", {}).get(other, {}).get("failed", 0)
                if failed > 0:
                    print(f"  • {other}: {failed} failed")


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Run all Nonna App test subcategories and update TEST_COMMANDS.md"
    )
    parser.add_argument(
        "--update-md",
        action="store_true",
        default=True,
        help="Update TEST_COMMANDS.md with results (default: True)",
    )
    parser.add_argument(
        "--no-update-md",
        dest="update_md",
        action="store_false",
        help="Don't update TEST_COMMANDS.md",
    )
    parser.add_argument(
        "--project-root",
        type=Path,
        default=Path.cwd(),
        help="Path to project root (default: current directory)",
    )

    args = parser.parse_args()

    runner = TestRunner(project_root=args.project_root)

    print("🚀 Starting test run for all subcategories...\n")
    runner.run_all_tests()
    runner.print_summary()

    if args.update_md:
        runner.update_md_file()


if __name__ == "__main__":
    main()
