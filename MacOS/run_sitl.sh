#!/usr/bin/env bash
#
# Build and run any ArduPilot vehicle in SITL on macOS.
# Run from the repository root.
#
# Usage:
#   MacOS/run_sitl.sh <Vehicle> [frame] [-- sim_vehicle.py options...]
#
# Vehicles: ArduCopter | ArduPlane | Rover | ArduSub | AntennaTracker | Helicopter | Blimp
#
# Examples:
#   MacOS/run_sitl.sh ArduPlane
#   MacOS/run_sitl.sh ArduPlane plane-elevon
#   MacOS/run_sitl.sh ArduCopter quad
#   MacOS/run_sitl.sh Rover
#   MacOS/run_sitl.sh ArduSub
#   MacOS/run_sitl.sh ArduPlane -- --no-mavproxy
#
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

VALID_VEHICLES="ArduCopter ArduPlane Rover ArduSub AntennaTracker Helicopter Blimp"

usage() {
    echo "Usage: MacOS/run_sitl.sh <Vehicle> [frame] [-- extra options for sim_vehicle.py]"
    echo "  Vehicles: $VALID_VEHICLES"
    echo "  Examples:"
    echo "    MacOS/run_sitl.sh ArduPlane"
    echo "    MacOS/run_sitl.sh ArduCopter quad"
    echo "    MacOS/run_sitl.sh Rover"
    exit 1
}

if [[ $# -lt 1 ]]; then
    usage
fi

VEHICLE="$1"
shift

# Check vehicle is valid
if [[ " $VALID_VEHICLES " != *" $VEHICLE "* ]]; then
    echo "Unknown vehicle: $VEHICLE"
    usage
fi

# Optional frame: if next arg is not -- and not empty, treat as frame
FRAME=""
EXTRA=()
while [[ $# -gt 0 ]]; do
    if [[ "$1" == "--" ]]; then
        shift
        EXTRA=("$@")
        break
    fi
    # If first remaining arg looks like a frame (no leading -), use as frame
    if [[ -z "$FRAME" && "$1" != -* ]]; then
        FRAME="$1"
        shift
    else
        EXTRA+=("$1")
        shift
    fi
done

cd "$ROOT_DIR"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "This script is intended for macOS. On other systems run from repo root:"
    echo "  ./waf configure --board sitl && ./waf <vehicle>"
    echo "  Tools/autotest/sim_vehicle.py -v $VEHICLE ${FRAME:+-f $FRAME} ${EXTRA[*]}"
    exit 1
fi

echo "Vehicle: $VEHICLE ${FRAME:+ (frame: $FRAME)}"
echo "Configuring SITL (native/clang on macOS)..."
./waf configure --board sitl

# Build the vehicle group that produces this vehicle's binary
case "$VEHICLE" in
    ArduCopter)   ./waf copter ;;
    ArduPlane)    ./waf plane ;;
    Rover)        ./waf rover ;;
    ArduSub)      ./waf sub ;;
    AntennaTracker) ./waf antennatracker ;;
    Helicopter)   ./waf heli ;;
    Blimp)        ./waf blimp ;;
    *)            echo "No waf target for $VEHICLE"; exit 1 ;;
esac

CMD=(Tools/autotest/sim_vehicle.py -v "$VEHICLE")
[[ -n "$FRAME" ]] && CMD+=(-f "$FRAME")
CMD+=("${EXTRA[@]}")

echo "Starting SITL with MAVProxy..."
exec "${CMD[@]}"
