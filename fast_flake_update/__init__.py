#!/usr/bin/env python3

import argparse
import json
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Update flake.lock with the latest commit of a local checkout"
    )
    parser.add_argument(
        "--rev",
        help="Revision to use",
        default="HEAD",
    )
    parser.add_argument(
        "inputname",
        help="Name of the input in flake.lock to update",
    )
    parser.add_argument(
        "repo",
        help="Path to the local checkout",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    inputname = args.inputname
    local_checkout = Path(args.repo)

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
        res = subprocess.run(
            ["git", "-C", str(local_checkout), "rev-parse", args.rev],
            check=True,
            text=True,
            stdout=subprocess.PIPE,
        )
        rev = res.stdout.strip()
        if rev == flake_input["locked"]["rev"]:
            print(f"{inputname} already up to date")
            sys.exit(0)

        archive = Path(tmpdir) / "git-checkout.tar.gz"
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
        print(f"updated {inputname} to from {flake_input['locked']['rev']} to {rev}")
        flake_input["locked"]["rev"] = rev
    tmp = flake_lock.with_name("flake.lock.tmp")
    tmp.write_text(json.dumps(lock, indent=2, sort_keys=True) + "\n")
    tmp.rename(flake_lock)


if __name__ == "__main__":
    main()
