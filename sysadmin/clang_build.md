# Building a self-contained Clang toolchain under /opt’

## Overview

This script builds a self-contained LLVM/Clang toolchain under `/opt`, using a clean two-stage bootstrap and the LLVM-native runtime stack (`libc++`, `libc++abi`, `libunwind`, `compiler-rt`).

The resulting installation is fully isolated from the system compiler and does not depend on any external GCC toolchain or system `libstdc++`.
Its primary goals are reproducibility, clarity, and long-term maintainability rather than maximum system integration.

The build uses Ninja and modern CMake practices and follows LLVM's recommended bootstrap model.

## Features

- POSIX shell script (/bin/sh).
- Two-stage bootstrap build:
  - stage 1: minimal Clang built with the system toolchain;
  - stage 2: final toolchain built with stage-1 Clang.
- Uses Ninja for faster and more reliable builds.
- Builds and installs:
  - `clang`, `clang++`
  - `lld`
  - `compiler-rt` (including sanitizers)
  - `libc++`, `libc++abi`, `libunwind`
  - `clang++` defaults to `libc++` (no wrapper scripts required).
- Explicit versioned installation prefix under `/opt`.

## Source tree layout

The script expects the official LLVM monorepo layout:

```shell
llvm-project-XX.Y.Z/
    llvm/
    clang/
    clang-tools-extra/
    lld/
    compiler-rt/
    libcxx/
    libcxxabi/
    libunwind/
    ...
```

The build directory must not be inside the source tree.

## Installation layout

The final toolchain is installed in:

```shell
/opt/clang-XX.Y.Z/
    bin/
    lib64/
    include/
    lib64/x86_64-unknown-linux-gnu/
    ...
```

All required runtimes are installed alongside Clang.
No external compiler or runtime libraries are required at build time or runtime.

## Requirements

- A working C/C++ toolchain (system Clang or GCC) to bootstrap stage 1.
- CMake (recent version recommended).
- Ninja (mandatory).
- Sufficient disk space and memory (LLVM builds are resource-intensive).

The script will abort early if Ninja is not available.

## Usage

```shell
$ ./clang_build.sh llvm-project-XX.Y.Z
```

On success, the script prints the installation prefix and suggested environment updates.

## Bootstrap model

The script implements a two-stage bootstrap, which is LLVM's standard production configuration:

- Stage 1
  - Built using the system compiler.
  - Builds only essential components (`clang`, `lld`).
  - Installed into a private staging directory.
- Stage 2
  - Built using the stage-1 Clang.
  - Produces the final toolchain.
  - Includes LLVM runtimes and sets `libc++` as the default C++ standard library.

A three-stage bootstrap is intentionally not used, as it mainly serves compiler validation and reproducibility testing rather than practical deployment.

## Runtime and linking behaviour

- `clang++` defaults to `libc++`, not `libstdc++`.
- The toolchain uses `lld` by default.
- Install-time `RPATH`s are set so binaries find their matching runtimes without environment variables.

## Using the installed compiler

To use the new toolchain, add the following to your shell configuration:

```shell
export PATH="/opt/clang-XX.Y.Z/bin:$PATH"
```

After that:

```shell
clang++
```

will use `libc++` and the bundled LLVM runtimes automatically.

## Notes and recommendations

LLVM builds take a long time; expect significant compile times.

This toolchain is intended for development, CI, and controlled environments, not as a drop-in replacement for a distribution compiler.

Projects that explicitly require `libstdc++` should continue using a GCC-based toolchain.

## Licence

This script is released under a permissive BSD-style licence.
See the script header for full licence terms.