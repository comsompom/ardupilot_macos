# Building and Running ArduPlane on macOS

This document describes how the ArduPilot project is structured and how to build and run **ArduPlane** in SITL (Software-In-The-Loop) on macOS. All commands below are run from the **repository root** (the directory that contains `ArduPlane/`, `MacOS/`, `Tools/`, etc.).

## Project structure (relevant to ArduPlane)

- **`ArduPlane/`** – ArduPlane application source: `Plane.cpp`, mode_*.cpp, GCS_MAVLink_Plane.cpp, etc. The build is defined in `ArduPlane/wscript` and produces the `arduplane` binary.
- **`libraries/`** – Shared libraries: `AP_HAL_SITL` (desktop SITL HAL), `SITL` (simulation models), `AP_TECS`, `AP_L1_Control`, etc. SITL uses the same ArduPlane code as real hardware; only the HAL (hardware abstraction) changes.
- **`Tools/ardupilotwaf/`** – Waf build logic: `boards.py` (board definitions, including `sitl` and SITLBoard), `toolchain.py` (native toolchain uses clang on macOS).
- **`Tools/autotest/`** – `sim_vehicle.py` launches SITL and MAVProxy; `arduplane.py` is the ArduPlane autotest suite. `pysim/vehicleinfo.py` defines vehicle/frame options (e.g. `plane`, `plane-elevon`) and waf targets (`bin/arduplane`).
- **Build output** – For board `sitl`, binaries go to `build/sitl/bin/`, e.g. `build/sitl/bin/arduplane`.
- **`MacOS/`** – This folder: macOS-specific documentation and the `run_arduplane.sh` script for ArduPlane on macOS.

## How ArduPlane runs on macOS (SITL)

1. **Board**: `sitl` – Software-in-the-loop. Uses the **native** toolchain (on macOS, **clang**).
2. **Binary**: `arduplane` – Same code as for real boards; it links against `AP_HAL_SITL` and the `SITL` library instead of a hardware HAL.
3. **Simulation**: The SITL layer provides simulated sensors, GPS, and physics (e.g. `SIM_Plane`). No real hardware is needed.
4. **Launch**: `sim_vehicle.py -v ArduPlane` builds (if needed) and runs `build/sitl/bin/arduplane`, then starts MAVProxy so you can connect a GCS (e.g. Mission Planner, QGroundControl).

macOS is explicitly supported: the CI workflow `.github/workflows/macos_build.yml` builds `sitl` (and other boards) on `macos-latest`, and `libraries/AP_HAL_SITL` contains `__APPLE__` handling where needed (e.g. UART, Scheduler).

**Note:** On macOS, SITL is built with clang; the lwIP networking stack is not enabled for clang builds, so some networking-related SITL features may be disabled. Core ArduPlane SITL (simulation + MAVProxy) works without it.

## Prerequisites (macOS)

1. **Xcode Command Line Tools**  
   ```bash
   xcode-select --install
   ```

2. **Homebrew** (for Python, pymavlink, MAVProxy, etc.)  
   Install from https://brew.sh if needed.

3. **ArduPilot environment script** (recommended; installs Python deps, MAVProxy, etc.):  
   From the repository root:
   ```bash
   Tools/environment_install/install-prereqs-mac.sh -y
   ```  
   Then open a new terminal or `source ~/.bash_profile` (or `~/.zshrc`).

4. **Submodules**  
   ```bash
   git submodule update --init --recursive
   ```

## Build ArduPlane (SITL) on macOS

From the repository root:

```bash
./waf configure --board sitl
./waf plane
```

Or build only the ArduPlane binary:

```bash
./waf configure --board sitl
./waf --targets bin/arduplane
```

The executable will be at **`build/sitl/bin/arduplane`**.

- **Debug build:**  
  `./waf configure --board sitl --debug` then `./waf plane`

## Run ArduPlane SITL on macOS

**Option A – Using the MacOS run script (recommended)**  
From the repository root, run the script inside the `MacOS` folder:

```bash
MacOS/run_arduplane.sh
```

Optional frame name: `MacOS/run_arduplane.sh plane-elevon`

**Option B – Using sim_vehicle.py directly**  
From the repository root:

```bash
Tools/autotest/sim_vehicle.py -v ArduPlane
```

Default frame is `plane`. To use a different frame (e.g. quadplane, plane-elevon):

```bash
Tools/autotest/sim_vehicle.py -v ArduPlane -f plane-elevon
```

**Option C – Run the binary directly**  
If you already built with the commands above:

```bash
./build/sitl/bin/arduplane --help
./build/sitl/bin/arduplane -S
```

For a full sim with MAVProxy and correct parameters, Option A or B is recommended.

## Quick one-liner (after prereqs and submodules)

From the repo root:

```bash
./waf configure --board sitl && ./waf plane && Tools/autotest/sim_vehicle.py -v ArduPlane
```

Or use the MacOS script:

```bash
MacOS/run_arduplane.sh
```

## Summary

| Item | Location / Command |
|------|--------------------|
| macOS ArduPlane docs & script | `MacOS/` (this folder) |
| ArduPlane app code | `ArduPlane/` |
| SITL HAL (macOS-friendly) | `libraries/AP_HAL_SITL/` |
| Build config (sitl board) | `Tools/ardupilotwaf/boards.py` (SITLBoard) |
| Configure | `./waf configure --board sitl` |
| Build plane | `./waf plane` or `./waf --targets bin/arduplane` |
| Binary | `build/sitl/bin/arduplane` |
| Run script (macOS) | `MacOS/run_arduplane.sh` |
| Run with MAVProxy (direct) | `Tools/autotest/sim_vehicle.py -v ArduPlane` |

ArduPlane is supported on macOS via the `sitl` board and native (clang) toolchain; the contents of this `MacOS` folder make it straightforward to build and run ArduPlane on macOS laptops.
