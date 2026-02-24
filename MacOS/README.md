# Running the Full ArduPilot Project on macOS

This folder contains instructions and scripts to **build and run the entire ArduPilot project** (all vehicles) in SITL (Software-In-The-Loop) on macOS. All commands are run from the **repository root** (the directory that contains `ArduPlane/`, `ArduCopter/`, `MacOS/`, `Tools/`, etc.).

## Contents of the MacOS Folder

| File | Purpose |
|------|--------|
| **README.md** (this file) | Instructions to run the whole ArduPilot project on macOS |
| **run_sitl.sh** | Build and run any vehicle (ArduCopter, ArduPlane, Rover, ArduSub, AntennaTracker, Helicopter, Blimp) |
| **run_arduplane.sh** | Shortcut for ArduPlane only |

---

## Quick Start: Run Any Vehicle

From the repository root:

```bash
# Run ArduPlane (default frame: plane)
MacOS/run_sitl.sh ArduPlane

# Run ArduCopter (default frame: quad)
MacOS/run_sitl.sh ArduCopter

# Run Rover, ArduSub, AntennaTracker, Helicopter, or Blimp
MacOS/run_sitl.sh Rover
MacOS/run_sitl.sh ArduSub
MacOS/run_sitl.sh AntennaTracker
MacOS/run_sitl.sh Helicopter
MacOS/run_sitl.sh Blimp
```

With an optional frame (vehicle-specific):

```bash
MacOS/run_sitl.sh ArduPlane plane-elevon
MacOS/run_sitl.sh ArduCopter hexa
MacOS/run_sitl.sh Rover sailboat
```

The script will configure SITL, build the chosen vehicle, and start the simulator with MAVProxy so you can connect a GCS (e.g. Mission Planner, QGroundControl).

---

## Prerequisites (macOS)

1. **Xcode Command Line Tools**
   ```bash
   xcode-select --install
   ```

2. **Homebrew**  
   Install from https://brew.sh if needed.

3. **ArduPilot environment** (Python, pymavlink, MAVProxy, etc.)  
   From the repository root:
   ```bash
   Tools/environment_install/install-prereqs-mac.sh -y
   ```
   Then open a new terminal or run `source ~/.bash_profile` (or `~/.zshrc`).

4. **Submodules**
   ```bash
   git submodule update --init --recursive
   ```

---

## Building the Whole Project (All Vehicles)

To build **all** ArduPilot SITL binaries (all vehicles) in one go:

```bash
./waf configure --board sitl
./waf
```

Or build the main vehicle binaries only (bin group):

```bash
./waf configure --board sitl
./waf bin
```

This produces (among others):

- `build/sitl/bin/arducopter`
- `build/sitl/bin/arduplane`
- `build/sitl/bin/ardurover`
- `build/sitl/bin/ardusub`
- `build/sitl/bin/antennatracker`
- plus helicopter and blimp binaries as applicable.

You only need to run this once (or when you change code). After that, `MacOS/run_sitl.sh <Vehicle>` will use the existing build; it can also rebuild that vehicle if needed.

---

## Building a Single Vehicle

From the repository root:

```bash
./waf configure --board sitl
./waf plane      # ArduPlane
./waf copter     # ArduCopter
./waf rover      # Rover
./waf sub        # ArduSub
./waf antennatracker
./waf heli       # Helicopter
./waf blimp      # Blimp
```

---

## Running Vehicles (Without the MacOS Script)

You can also run SITL directly with `sim_vehicle.py`. From the repository root:

```bash
Tools/autotest/sim_vehicle.py -v ArduPlane
Tools/autotest/sim_vehicle.py -v ArduCopter
Tools/autotest/sim_vehicle.py -v Rover
Tools/autotest/sim_vehicle.py -v ArduSub
Tools/autotest/sim_vehicle.py -v AntennaTracker
Tools/autotest/sim_vehicle.py -v Helicopter
Tools/autotest/sim_vehicle.py -v Blimp
```

With a specific frame:

```bash
Tools/autotest/sim_vehicle.py -v ArduPlane -f plane-elevon
Tools/autotest/sim_vehicle.py -v ArduCopter -f hexa
```

`sim_vehicle.py` will configure and build the right binary if needed (unless you pass `--no-rebuild`).

---

## Vehicles and Default Frames

| Vehicle | Default frame | Example other frames |
|---------|----------------|----------------------|
| **ArduCopter** | quad | X, hexa, octa, tri, heli |
| **ArduPlane** | plane | plane-elevon, plane-vtail, quadplane |
| **Rover** | rover | balancebot, sailboat, motorboat |
| **ArduSub** | vectored | — |
| **AntennaTracker** | tracker | — |
| **Helicopter** | heli | — |
| **Blimp** | Blimp | — |

To list all frames for a vehicle:

```bash
Tools/autotest/sim_vehicle.py -v ArduPlane --list-frames
Tools/autotest/sim_vehicle.py -v ArduCopter --list-frames
```

---

## Run Script Reference

**MacOS/run_sitl.sh**

- **Usage:** `MacOS/run_sitl.sh <Vehicle> [frame] [-- extra options for sim_vehicle.py]`
- **Vehicles:** `ArduCopter`, `ArduPlane`, `Rover`, `ArduSub`, `AntennaTracker`, `Helicopter`, `Blimp`
- **Examples:**
  - `MacOS/run_sitl.sh ArduPlane`
  - `MacOS/run_sitl.sh ArduPlane plane-elevon`
  - `MacOS/run_sitl.sh ArduCopter quad`
  - `MacOS/run_sitl.sh ArduPlane -- --no-mavproxy`

**MacOS/run_arduplane.sh**

- Shortcut for ArduPlane: `MacOS/run_arduplane.sh` or `MacOS/run_arduplane.sh plane-elevon`

---

## Project Layout (Relevant to Running on macOS)

- **Vehicle apps:** `ArduPlane/`, `ArduCopter/`, `Rover/`, `ArduSub/`, `AntennaTracker/`, `Blimp/`, `Helicopter/` (part of ArduCopter).
- **Shared libraries:** `libraries/` (e.g. `AP_HAL_SITL`, `SITL`). SITL uses the same vehicle code as real hardware; only the HAL (hardware abstraction) changes.
- **Build system:** `./waf configure --board sitl` then `./waf` or `./waf <vehicle>`. On macOS the native toolchain uses **clang**.
- **SITL launcher:** `Tools/autotest/sim_vehicle.py` – builds (if needed) and runs the binary, then MAVProxy.
- **Build output:** `build/sitl/bin/` – e.g. `arduplane`, `arducopter`, `ardurover`, `ardusub`, `antennatracker`.

---

## One-Liner: Build All and Run One Vehicle

From the repository root (after prerequisites and submodules):

```bash
./waf configure --board sitl && ./waf && MacOS/run_sitl.sh ArduPlane
```

Or build only that vehicle:

```bash
./waf configure --board sitl && MacOS/run_sitl.sh ArduPlane
```

---

## Note on Networking (macOS SITL)

On macOS, SITL is built with clang and the lwIP networking stack is not enabled for clang builds, so some networking-related SITL features may be disabled. Core simulation and MAVProxy for all vehicles work as expected.

These instructions and scripts allow you to run the **entire ArduPilot project** on macOS: build all vehicles or a single vehicle, then run any of them via `MacOS/run_sitl.sh` or `sim_vehicle.py`.
