#!/usr/bin/env python3
"""Create a modern macOS ICNS container from a square PNG master."""

from __future__ import annotations

import argparse
import struct
import subprocess
import tempfile
from pathlib import Path


# ICNS chunk identifiers for standard and Retina representations.
REPRESENTATIONS = (
    ("icp4", 16),
    ("ic11", 32),   # 16 pt @2x
    ("icp5", 32),
    ("ic12", 64),   # 32 pt @2x
    ("ic07", 128),
    ("ic13", 256),  # 128 pt @2x
    ("ic08", 256),
    ("ic14", 512),  # 256 pt @2x
    ("ic09", 512),
    ("ic10", 1024), # 512 pt @2x
)


def png_at_size(source: Path, size: int, directory: Path) -> bytes:
    destination = directory / f"icon-{size}.png"
    subprocess.run(
        [
            "/usr/bin/sips",
            "-z",
            str(size),
            str(size),
            str(source),
            "--out",
            str(destination),
        ],
        check=True,
        stdout=subprocess.DEVNULL,
    )
    return destination.read_bytes()


def build_icns(source: Path, destination: Path) -> None:
    with tempfile.TemporaryDirectory(prefix="stopapp-icon-") as temp:
        temp_directory = Path(temp)
        images = {
            size: png_at_size(source, size, temp_directory)
            for size in sorted({size for _, size in REPRESENTATIONS})
        }

    chunks = []
    for icon_type, size in REPRESENTATIONS:
        payload = images[size]
        chunks.append(icon_type.encode("ascii") + struct.pack(">I", len(payload) + 8) + payload)

    body = b"".join(chunks)
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(b"icns" + struct.pack(">I", len(body) + 8) + body)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    arguments = parser.parse_args()

    build_icns(arguments.source.resolve(), arguments.destination.resolve())


if __name__ == "__main__":
    main()
