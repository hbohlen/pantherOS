#!/usr/bin/env python3
import subprocess
import sys

try:
    result = subprocess.run(
        [sys.executable, "/home/hbohlen/dev/OpenAgents/scripts/validate-repo.py"],
        capture_output=True,
        text=True,
        cwd="/home/hbohlen/dev/OpenAgents",
    )
    print(result.stdout)
    if result.stderr:
        print("STDERR:", result.stderr, file=sys.stderr)
    sys.exit(result.returncode)
except Exception as e:
    print(f"Error running validation: {e}")
    sys.exit(1)
