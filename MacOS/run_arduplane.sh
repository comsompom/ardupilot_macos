#!/usr/bin/env bash
#
# Build and run ArduPlane SITL on macOS.
# Run from the repository root, e.g.:
#   MacOS/run_arduplane.sh
#   MacOS/run_arduplane.sh plane-elevon
#
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# MacOS folder is inside repo root
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FRAME="${1:-plane}"

cd "$ROOT_DIR"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "This script is intended for macOS. On other systems use from repo root:"
    echo "  ./waf configure --board sitl && ./waf plane"
    echo "  Tools/autotest/sim_vehicle.py -v ArduPlane -f $FRAME"
    exit 1
fi

echo "Configuring SITL (native/clang on macOS)..."
./waf configure --board sitl

echo "Building ArduPlane..."
./waf plane

echo "Starting ArduPlane SITL (frame: $FRAME) with MAVProxy..."
exec Tools/autotest/sim_vehicle.py -v ArduPlane -f "$FRAME" "${@:2}"
