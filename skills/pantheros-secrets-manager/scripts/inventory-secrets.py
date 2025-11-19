#!/usr/bin/env python3
"""
Secrets Inventory for pantherOS
Scans Nix files for op: secrets references
Generates inventory report
Usage: ./inventory-secrets.py [path]
"""

import re
import os
import sys
import json
from pathlib import Path
from collections import defaultdict, Counter
from typing import Dict, List, Set, Tuple

# Pattern to match op: references
OP_PATTERN = re.compile(r'op:([^/\s]+)/([^/\s]+)/([^/\s]+)')


def scan_directory(path: str) -> Tuple[Dict[str, List[str]], Counter]:
    """
    Scan directory for op: references
    Returns: (references, stats)
    """
    references = defaultdict(list)
    stats = Counter()

    for root, dirs, files in os.walk(path):
        # Skip hidden dirs and common build directories
        dirs[:] = [d for d in dirs if not d.startswith('.') and d not in ['result', 'node_modules']]

        for file in files:
            if file.endswith(('.nix', '.sh', '.md', '.txt', '.json')):
                filepath = os.path.join(root, file)
                relpath = os.path.relpath(filepath, path)

                try:
                    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()

                    # Find all op: references
                    matches = OP_PATTERN.findall(content)

                    for match in matches:
                        vault, item, field = match
                        secret_ref = f"op:{vault}/{item}/{field}"

                        # Store reference with location
                        references[secret_ref].append({
                            'file': relpath,
                            'context': content[max(0, content.find(match[0])-50):
                                              content.find(match[0])+len(match[0])+50]
                        })

                        stats['total_refs'] += 1
                        stats['unique_secrets'] = len(references)

                except Exception as e:
                    stats['errors'] += 1
                    print(f"Error reading {filepath}: {e}", file=sys.stderr)

    return references, stats


def inventory_secrets(path: str) -> None:
    """Generate complete secrets inventory"""
    print("=== PantherOS Secrets Inventory ===\n")

    print(f"Scanning: {path}")
    print(f"Started: {Path(__file__).stat().st_mtime}\n")

    references, stats = scan_directory(path)

    if not references:
        print("No op: references found")
        return

    # Summary
    print("=== Summary ===")
    print(f"Total references found: {stats['total_refs']}")
    print(f"Unique secrets: {stats['unique_secrets']}")
    print(f"Files scanned: {stats.get('files', 'N/A')}")
    print(f"Errors: {stats.get('errors', 0)}\n")

    # Group by vault
    print("=== By Vault ===")
    by_vault = defaultdict(list)
    for secret_ref, locations in references.items():
        vault = secret_ref.split('/')[1]
        by_vault[vault].append((secret_ref, locations))

    for vault, items in sorted(by_vault.items()):
        print(f"\n{vault} ({len(items)} secrets):")
        for secret_ref, locations in sorted(items):
            print(f"  • {secret_ref.split('/', 2)[2]}  (referenced in {len(locations)} files)")

    # Detailed report
    print("\n=== Detailed References ===")
    for secret_ref in sorted(references.keys()):
        vault, item, field = secret_ref.split('/', 2)
        print(f"\n{vault}/{item}/{field}:")
        for loc in references[secret_ref]:
            print(f"  → {loc['file']}")

    # Export to JSON
    output_file = "secrets-inventory.json"
    export_data = {
        'generated': str(Path(__file__).stat().st_mtime),
        'scan_path': path,
        'stats': dict(stats),
        'references': {k: v for k, v in references.items()}
    }

    with open(output_file, 'w') as f:
        json.dump(export_data, f, indent=2)

    print(f"\n=== Export ===")
    print(f"Inventory exported to: {output_file}")


def validate_secrets(path: str) -> None:
    """Validate secrets against 1Password"""
    print("=== PantherOS Secrets Validation ===\n")

    references, stats = scan_directory(path)

    if not references:
        print("No op: references found")
        return

    print(f"Found {len(references)} unique secrets\n")

    # Check which secrets actually exist
    print("=== Validation Results ===\n")

    validated = 0
    missing = 0
    errors = 0

    for secret_ref in sorted(references.keys()):
        vault, item, field = secret_ref.split('/', 2)[1:]
        op_ref = f"{vault}/{item}/{field}"

        # Try to get secret with op
        import subprocess
        try:
            result = subprocess.run(
                ['op', 'item', 'get', op_ref, '--fields', field],
                capture_output=True,
                text=True,
                timeout=10
            )

            if result.returncode == 0:
                print(f"✓ {vault}/{item}/{field}")
                validated += 1
            else:
                print(f"✗ {vault}/{item}/{field} (not found)")
                missing += 1

        except subprocess.TimeoutExpired:
            print(f"⚠ {vault}/{item}/{field} (timeout)")
            errors += 1
        except Exception as e:
            print(f"✗ {vault}/{item}/{field} (error: {e})")
            errors += 1

    print(f"\n=== Summary ===")
    print(f"Validated: {validated}")
    print(f"Missing: {missing}")
    print(f"Errors: {errors}")
    print(f"Total: {len(references)}")

    if missing > 0 or errors > 0:
        print("\n⚠ Some secrets are missing or invalid")
        sys.exit(1)
    else:
        print("\n✓ All secrets validated")


def find_usage(item_name: str, path: str) -> None:
    """Find all usages of a specific secret"""
    references, _ = scan_directory(path)

    print(f"=== Usage of {item_name} ===\n")

    found = False
    for secret_ref, locations in references.items():
        if item_name in secret_ref:
            found = True
            vault, item, field = secret_ref.split('/', 2)
            print(f"\n{vault}/{item}/{field}:")

            for loc in locations:
                print(f"  {loc['file']}")

    if not found:
        print(f"No references to '{item_name}' found")


def refactor_secrets(path: str, old_prefix: str, new_prefix: str) -> None:
    """Refactor secret references"""
    print(f"=== Refactoring Secrets ===\n")
    print(f"Old prefix: {old_prefix}")
    print(f"New prefix: {new_prefix}\n")

    # Get list of files to modify
    files_to_modify = []

    for root, dirs, files in os.walk(path):
        for file in files:
            if file.endswith('.nix'):
                filepath = os.path.join(root, file)

                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()

                    if old_prefix in content:
                        files_to_modify.append(filepath)

                except Exception as e:
                    print(f"Error reading {filepath}: {e}")

    if not files_to_modify:
        print("No files found to modify")
        return

    print(f"Files to modify: {len(files_to_modify)}")
    for f in files_to_modify:
        print(f"  • {f}")

    # Confirm
    print("\nConfirm? (yes/no) ", end='')
    if input().lower() != 'yes':
        print("Cancelled")
        return

    # Make changes
    for filepath in files_to_modify:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        new_content = content.replace(old_prefix, new_prefix)

        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"✓ Modified: {filepath}")

    print("\nRefactoring complete")


def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print("Usage:")
        print("  inventory  - Generate secrets inventory")
        print("  validate   - Validate secrets against 1Password")
        print("  find <name> - Find usage of secret")
        print("  refactor <old> <new> - Refactor secret references")
        sys.exit(1)

    command = sys.argv[1].lower()

    # Default path to scan
    path = sys.argv[2] if len(sys.argv) > 2 else "."

    if command == "inventory":
        inventory_secrets(path)
    elif command == "validate":
        validate_secrets(path)
    elif command == "find":
        if len(sys.argv) < 3:
            print("Usage: find <secret-name>")
            sys.exit(1)
        find_usage(sys.argv[2], path)
    elif command == "refactor":
        if len(sys.argv) < 4:
            print("Usage: refactor <old-prefix> <new-prefix>")
            sys.exit(1)
        refactor_secrets(path, sys.argv[2], sys.argv[3])
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == '__main__':
    main()
