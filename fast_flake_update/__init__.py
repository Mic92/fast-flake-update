#!/usr/bin/env python3

import json
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory


def main() -> None:
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <inputname> <repo>")
        sys.exit(1)
    inputname = sys.argv[1]
    local_checkout = Path(sys.argv[2])

    flake_lock = Path("flake.lock")
    if not flake_lock.exists():
        print("flake.lock not found")
        sys.exit(1)
    lock = json.load(flake_lock.open())
    flake_input = lock["nodes"].get(inputname)
    if not flake_input:
        print(f"input {inputname} not found in flake.lock")
        print(f"available inputs: {lock['nodes'].keys()}")
        sys.exit(1)
    with TemporaryDirectory() as tmpdir:
        archive = Path(tmpdir) / "latest.tar.gz"
        res = subprocess.run(
            ["git", "-C", str(local_checkout), "rev-parse", "HEAD"],
            check=True,
            text=True,
            stdout=subprocess.PIPE,
        )
        rev = res.stdout.strip()
        subprocess.run(
            ["git", "-C", str(local_checkout), "archive", "-o", archive, rev]
        )
        res = subprocess.run(
            ["nix-prefetch-url", "--unpack", f"file://{archive}", "--name", "source"],
            stdout=subprocess.PIPE,
            text=True,
            check=True,
        )
        source_hash = res.stdout.strip()
        res = subprocess.run(
            ["nix", "hash", "to-sri", "--type", "sha256", source_hash],
            check=True,
            stdout=subprocess.PIPE,
            text=True,
        )
        flake_input["locked"]["narHash"] = res.stdout.strip()
        flake_input["locked"]["rev"] = rev
    tmp = flake_lock.with_name("flake.lock.tmp")
    tmp.write_text(json.dumps(lock, indent=2, sort_keys=True) + "\n")
    tmp.rename(flake_lock)


if __name__ == "__main__":
    main()
