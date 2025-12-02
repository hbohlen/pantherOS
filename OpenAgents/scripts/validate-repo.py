#!/usr/bin/env python3
"""
OpenAgents Repository Validation Script
Comprehensive validation of repository consistency between CLI, documentation, registry, and components.
"""

import json
import os
import re
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any, Set, Tuple


class RepositoryValidator:
    def __init__(self, repo_root: str = "/home/hbohlen/dev/OpenAgents"):
        self.repo_root = Path(repo_root)
        self.registry_path = self.repo_root / "registry.json"
        self.errors = []
        self.warnings = []
        self.successes = []
        self.stats = {
            "total_components": 0,
            "files_found": 0,
            "files_missing": 0,
            "valid_dependencies": 0,
            "broken_dependencies": 0,
            "profiles_validated": 0,
            "documentation_matches": 0,
        }

    def log_success(self, message: str):
        """Log a successful validation"""
        self.successes.append(message)

    def log_warning(self, message: str):
        """Log a warning"""
        self.warnings.append(message)

    def log_error(self, message: str):
        """Log an error"""
        self.errors.append(message)

    def load_registry(self) -> Dict[str, Any]:
        """Load and validate registry JSON"""
        try:
            with open(self.registry_path, "r") as f:
                data = json.load(f)
            self.log_success("Registry JSON syntax valid")
            return data
        except json.JSONDecodeError as e:
            self.log_error(f"Invalid JSON in registry.json: {e}")
            return {}
        except FileNotFoundError:
            self.log_error("registry.json not found")
            return {}

    def validate_registry_schema(self, registry: Dict[str, Any]) -> bool:
        """Validate registry has all required fields"""
        required_fields = [
            "version",
            "repository",
            "categories",
            "components",
            "profiles",
            "metadata",
        ]
        missing_fields = []

        for field in required_fields:
            if field not in registry:
                missing_fields.append(field)

        if missing_fields:
            self.log_error(
                f"Registry missing required fields: {', '.join(missing_fields)}"
            )
            return False
        else:
            self.log_success("All required registry fields present")

        # Validate component types
        component_types = [
            "agents",
            "subagents",
            "commands",
            "tools",
            "plugins",
            "contexts",
            "config",
        ]
        for comp_type in component_types:
            if comp_type not in registry["components"]:
                self.log_error(f"Registry missing component type: {comp_type}")
            else:
                self.log_success(f"Component type '{comp_type}' present")

        return len(missing_fields) == 0

    def validate_component_definitions(
        self, registry: Dict[str, Any]
    ) -> Dict[str, Set[str]]:
        """Validate component definitions and return ID map"""
        all_components = {}
        required_fields = ["id", "name", "type", "path", "description", "category"]

        for comp_type, components in registry["components"].items():
            component_ids = set()

            for comp in components:
                # Check required fields
                missing_fields = [
                    field for field in required_fields if field not in comp
                ]
                if missing_fields:
                    self.log_error(
                        f"{comp_type.rstrip('s')} '{comp.get('id', 'unknown')}' missing fields: {', '.join(missing_fields)}"
                    )
                    continue

                # Check for duplicate IDs within type
                if comp["id"] in component_ids:
                    self.log_error(
                        f"Duplicate {comp_type.rstrip('s')} ID: {comp['id']}"
                    )
                component_ids.add(comp["id"])

                # Store for cross-reference
                full_id = f"{comp['type']}:{comp['id']}"
                all_components[full_id] = comp

            self.stats["total_components"] += len(components)

        # Validate categories exist
        defined_categories = set(registry["categories"].keys())
        for comp_type, components in registry["components"].items():
            for comp in components:
                if comp.get("category") not in defined_categories:
                    self.log_error(
                        f"Unknown category '{comp.get('category')}' in {comp_type.rstrip('s')}:{comp['id']}"
                    )

        return all_components

    def validate_component_files(
        self, registry: Dict[str, Any]
    ) -> Dict[str, Dict[str, int]]:
        """Validate all referenced files exist"""
        file_stats = {}

        for comp_type, components in registry["components"].items():
            found = 0
            missing = 0

            for comp in components:
                path = comp.get("path", "")
                full_path = self.repo_root / path

                if full_path.exists():
                    found += 1
                    self.stats["files_found"] += 1
                else:
                    missing += 1
                    self.stats["files_missing"] += 1
                    self.log_error(
                        f"Missing file: {path} (referenced by {comp_type.rstrip('s')}:{comp['id']})"
                    )

            file_stats[comp_type] = {"found": found, "missing": missing}

        for comp_type, stats in file_stats.items():
            total = stats["found"] + stats["missing"]
            if stats["missing"] == 0:
                self.log_success(
                    f"{comp_type.title()}: {stats['found']}/{total} files exist"
                )
            else:
                self.log_warning(
                    f"{comp_type.title()}: {stats['found']}/{total} files exist ({stats['missing']} missing)"
                )

        return file_stats

    def validate_profiles(
        self, registry: Dict[str, Any], all_components: Dict[str, Any]
    ) -> bool:
        """Validate profile definitions"""
        profiles_valid = True
        expected_counts = {
            "essential": 9,
            "developer": 19,
            "business": 15,
            "full": 25,
            "advanced": 32,
        }

        for profile_name, profile_data in registry["profiles"].items():
            # Count components
            component_count = len(profile_data.get("components", []))
            expected_count = expected_counts.get(profile_name)

            # Check if count matches README
            if expected_count and component_count != expected_count:
                self.log_warning(
                    f"Profile '{profile_name}': {component_count} components (README says {expected_count})"
                )
            else:
                self.log_success(
                    f"Profile '{profile_name}': {component_count} components"
                )

            # Validate all components exist
            missing_components = []
            duplicate_components = set()

            for comp_ref in profile_data.get("components", []):
                if comp_ref in duplicate_components:
                    self.log_warning(
                        f"Profile '{profile_name}': duplicate component {comp_ref}"
                    )
                duplicate_components.add(comp_ref)

                if comp_ref not in all_components:
                    missing_components.append(comp_ref)

            if missing_components:
                self.log_error(
                    f"Profile '{profile_name}': missing components {', '.join(missing_components)}"
                )
                profiles_valid = False

            self.stats["profiles_validated"] += 1

        return profiles_valid

    def validate_dependencies(
        self, registry: Dict[str, Any], all_components: Dict[str, Any]
    ) -> bool:
        """Validate all dependencies exist"""
        deps_valid = True
        total_deps = 0

        for comp_type, components in registry["components"].items():
            for comp in components:
                comp_id = f"{comp['type']}:{comp['id']}"
                dependencies = comp.get("dependencies", [])

                for dep in dependencies:
                    total_deps += 1

                    if dep not in all_components:
                        self.log_error(f"Broken dependency: {comp_id} -> {dep}")
                        self.stats["broken_dependencies"] += 1
                        deps_valid = False
                    else:
                        self.stats["valid_dependencies"] += 1

        if deps_valid:
            self.log_success(
                f"Dependencies valid: {self.stats['valid_dependencies']}/{total_deps}"
            )
        else:
            self.log_error(
                f"Dependencies broken: {self.stats['broken_dependencies']}/{total_deps}"
            )

        return deps_valid

    def validate_documentation(self, registry: Dict[str, Any]) -> bool:
        """Validate documentation matches registry"""
        # Read README
        readme_path = self.repo_root / "README.md"
        if not readme_path.exists():
            self.log_error("README.md not found")
            return False

        with open(readme_path, "r") as f:
            readme_content = f.read()

        # Extract profile counts from README
        readme_counts = {}
        for profile in ["essential", "developer", "business", "full", "advanced"]:
            pattern = rf"{profile}.*?(\d+)\s*components"
            match = re.search(pattern, readme_content, re.IGNORECASE)
            if match:
                readme_counts[profile] = int(match.group(1))

        # Compare with registry
        matches = 0
        for profile_name, profile_data in registry["profiles"].items():
            registry_count = len(profile_data.get("components", []))
            readme_count = readme_counts.get(profile_name)

            if readme_count is None:
                self.log_warning(f"Profile '{profile_name}' count not found in README")
            elif readme_count != registry_count:
                self.log_error(
                    f"Profile '{profile_name}': README says {readme_count}, registry has {registry_count}"
                )
            else:
                matches += 1

        self.stats["documentation_matches"] = matches
        total_profiles = len(registry["profiles"])

        if matches == total_profiles:
            self.log_success(
                f"Documentation matches: {matches}/{total_profiles} profiles"
            )
        else:
            self.log_warning(
                f"Documentation mismatches: {matches}/{total_profiles} profiles"
            )

        return matches == total_profiles

    def find_orphaned_files(self, registry: Dict[str, Any]) -> None:
        """Find files that exist but aren't referenced in registry"""
        registry_paths = set()

        # Collect all registry paths
        for comp_type, components in registry["components"].items():
            for comp in components:
                registry_paths.add(comp.get("path", ""))

        # Find files in .opencode directory
        opencode_dir = self.repo_root / ".opencode"
        if not opencode_dir.exists():
            return

        orphaned_files = []
        for file_path in opencode_dir.rglob("*"):
            if file_path.is_file():
                relative_path = str(file_path.relative_to(self.repo_root))
                if relative_path not in registry_paths and not relative_path.startswith(
                    ".git"
                ):
                    orphaned_files.append(relative_path)

        if orphaned_files:
            self.log_warning(f"Found {len(orphaned_files)} orphaned files:")
            for orphan in orphaned_files[:10]:  # Show first 10
                self.log_warning(f"  - {orphan}")
            if len(orphaned_files) > 10:
                self.log_warning(f"  ... and {len(orphaned_files) - 10} more")
        else:
            self.log_success("No orphaned files found")

    def run_validation(self) -> Dict[str, Any]:
        """Run complete validation and return report"""
        print("🔍 Starting OpenAgents Repository Validation...")
        print(f"Repository root: {self.repo_root}")
        print(f"Registry path: {self.registry_path}")
        print("-" * 60)

        # Load and validate registry
        registry = self.load_registry()
        if not registry:
            return self.generate_report()

        # Validate registry schema
        self.validate_registry_schema(registry)

        # Validate components
        all_components = self.validate_component_definitions(registry)

        # Check file existence
        self.validate_component_files(registry)

        # Validate profiles
        self.validate_profiles(registry, all_components)

        # Validate dependencies
        self.validate_dependencies(registry, all_components)

        # Validate documentation
        self.validate_documentation(registry)

        # Find orphaned files
        self.find_orphaned_files(registry)

        return self.generate_report()

    def generate_report(self) -> Dict[str, Any]:
        """Generate comprehensive validation report"""
        report = {
            "timestamp": datetime.now().isoformat(),
            "summary": {
                "total_errors": len(self.errors),
                "total_warnings": len(self.warnings),
                "total_successes": len(self.successes),
                "validation_score": self.calculate_score(),
            },
            "errors": self.errors,
            "warnings": self.warnings,
            "successes": self.successes,
            "statistics": self.stats,
            "recommendations": self.generate_recommendations(),
        }

        return report

    def calculate_score(self) -> float:
        """Calculate overall validation score"""
        total_issues = len(self.errors) + len(self.warnings)
        total_items = len(self.errors) + len(self.warnings) + len(self.successes)

        if total_items == 0:
            return 100.0

        # Weight errors heavily, warnings lightly
        weighted_issues = len(self.errors) * 3 + len(self.warnings)
        base_score = max(0, (total_items - weighted_issues) / total_items * 100)

        return round(base_score, 1)

    def generate_recommendations(self) -> Dict[str, List[str]]:
        """Generate actionable recommendations"""
        recommendations = {
            "high_priority": [],
            "medium_priority": [],
            "low_priority": [],
        }

        # High priority - Errors
        if self.errors:
            recommendations["high_priority"].extend(
                [
                    "Fix all registry errors before proceeding",
                    "Create missing files or update registry references",
                    "Resolve broken dependencies",
                ]
            )

        # Medium priority - Warnings
        if self.warnings:
            recommendations["medium_priority"].extend(
                [
                    "Address profile count mismatches in documentation",
                    "Add missing component descriptions or tags",
                    "Consider updating metadata dates",
                ]
            )

        # Low priority - Improvements
        recommendations["low_priority"].extend(
            [
                "Add more detailed tags for better searchability",
                "Consider adding component usage examples",
                "Document component categories in README",
            ]
        )

        return recommendations

    def print_report(self, report: Dict[str, Any]):
        """Print formatted validation report"""
        print("\n" + "=" * 80)
        print("🔍 OpenAgents Repository Validation Report")
        print("=" * 80)
        print(f"Generated: {report['timestamp']}")

        # Summary
        summary = report["summary"]
        print(f"\n📊 Summary")
        print(f"Validation Score: {summary['validation_score']}%")
        print(f"✅ Successes: {len(report['successes'])}")
        print(f"⚠️  Warnings: {len(report['warnings'])}")
        print(f"❌ Errors: {len(report['errors'])}")

        # Successes
        if report["successes"]:
            print(f"\n✅ Validated Successfully ({len(report['successes'])})")
            for success in report["successes"][:10]:  # Show first 10
                print(f"  • {success}")
            if len(report["successes"]) > 10:
                print(f"  ... and {len(report['successes']) - 10} more")

        # Errors
        if report["errors"]:
            print(f"\n❌ Errors ({len(report['errors'])})")
            for error in report["errors"]:
                print(f"  • {error}")

        # Warnings
        if report["warnings"]:
            print(f"\n⚠️  Warnings ({len(report['warnings'])})")
            for warning in report["warnings"][:10]:  # Show first 10
                print(f"  • {warning}")
            if len(report["warnings"]) > 10:
                print(f"  ... and {len(report['warnings']) - 10} more")

        # Statistics
        stats = report["statistics"]
        print(f"\n📊 Statistics")
        print(f"Total components: {stats['total_components']}")
        print(f"Files found: {stats['files_found']}")
        print(f"Files missing: {stats['files_missing']}")
        print(f"Valid dependencies: {stats['valid_dependencies']}")
        print(f"Broken dependencies: {stats['broken_dependencies']}")

        # Recommendations
        recommendations = report["recommendations"]
        if any(recommendations.values()):
            print(f"\n🔧 Recommendations")
            if recommendations["high_priority"]:
                print("High Priority:")
                for rec in recommendations["high_priority"]:
                    print(f"  • {rec}")
            if recommendations["medium_priority"]:
                print("Medium Priority:")
                for rec in recommendations["medium_priority"]:
                    print(f"  • {rec}")
            if recommendations["low_priority"]:
                print("Low Priority:")
                for rec in recommendations["low_priority"]:
                    print(f"  • {rec}")

        print("\n" + "=" * 80)
        print(
            "Validation Complete" + " ✓"
            if report["summary"]["total_errors"] == 0
            else " ⚠️"
        )
        print("=" * 80)


if __name__ == "__main__":
    validator = RepositoryValidator()
    report = validator.run_validation()
    validator.print_report(report)

    # Exit with error code if critical issues found
    exit(1 if report["summary"]["total_errors"] > 0 else 0)
