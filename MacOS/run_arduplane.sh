#!/usr/bin/env bash
#
# Build and run ArduPlane SITL on macOS (convenience wrapper).
# Run from the repository root, e.g.:
#   MacOS/run_arduplane.sh
#   MacOS/run_arduplane.sh plane-elevon
#
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/run_sitl.sh" ArduPlane "$@"
