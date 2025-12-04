# Building a custom CLANG toolchain under `/opt`

## Overview

This script builds an LLVM/Clang toolchain under `/opt` in a SlackBuild-style, POSIX-compliant manner.
Its purpose is to provide an isolated, reproducible Clang installation that does not interfere with the system compiler.
The script supports optional integration with a GCC toolchain previously installed under `/opt/gcc-XX.Y.Z`, allowing Clang to link against a non-system libstdc++ when available.

The build relies on the system Clang to compile the first stage (stage-1).
A second stage (stage-2) is then produced using the stage-1 compiler, ensuring that the final installation is fully self-hosted and independent from the system compiler's behaviour.
This two-stage approach is the standard bootstrap mode used by LLVM in most practical scenarios.

## Features

- POSIX-compliant shell script (/bin/sh only).
- SlackBuild-style structure with clear variables and minimal assumptions.
- Installs Clang under `/opt/llvm-XX.Y.Z` without modifying system paths.
- Automatically detects a GCC toolchain installed under `/opt/gcc-XX.Y.Z` and uses it for C++ linking, injects correct include/library search paths, adds the required runtime rpath.
- Uses the LLVM monorepo structure (`llvm/`, `clang/`, `lld/`...).
- Relies on the system Clang for stage-1 compilation, guaranteeing portability.

## Directory layout

The script expects:

```
llvm-XX.Y.Z/
    llvm/
    clang/
    lld/
    compiler-rt/
    ...
```

The final toolchain is installed in:

```
/opt/llvm-XX/
    bin/
    lib64/
    include/
    ...
```

If a GCC toolchain is present:

```
/opt/gcc-XX/
    bin/gcc
    bin/g++
    lib64/libstdc++.so
    include/c++/...
```

the script will automatically configure Clang to use that libstdc++ instead of the system one.

## Usage
```shell
$ ./clang_build.sh llvm-XX.Y.Z
```

After installation:

```shell
/opt/llvm-XX.Y.Z/bin/clang++
```

can be used directly, or a user can add:

```shell
export PATH=/opt/llvm-XX.Y.Z/bin:$PATH
```

to adopt it as their default compiler.

## Bootstrap model

The script implements a two-stage bootstrap:

1. **stage-1** is built with the system Clang (`/usr/bin/clang`).
2. **stage-2** is built with the stage-1 compiler and is the final installed toolchain.

This is the standard bootstrap configuration used by most Linux distributions.
A three-stage bootstrap is optional and intended primarily for compiler development or reproducibility testing; it is not required for normal production use.

## Notes and recommendations

Building LLVM/Clang is resource-intensive; expect long compile times.

If linking against `/opt/gcc-XX`:

- ensure it was built with the same architecture options;
- ensure that `libstdc++` is visible at runtime (the script adds an `rpath`).

The installation under `/opt` avoids conflicts with the system toolchain.

The script does not modify system paths, packages or libraries.

## Adjusting your environment

To use the newly installed compiler, add the following line to a user's `.bashrc`:

```shell
export PATH=/opt/llvm-XX.Y.Z/bin:$PATH
```

or

```shell
export PATH="/opt/gcc-XX.Y.Z/bin:/opt/llvm-AA.B.C/bin:$PATH"
export LD_LIBRARY_PATH="/opt/gcc-XX.Y.Z/lib64:${LD_LIBRARY_PATH:-}"
```

This means:

- `/opt/gcc-XX.Y.Z/bin` has highest priority;
- `/opt/llvm-AA.B.C/bin` is the next;
- system tools are last.

Also

- Clang finds the `/opt/gcc-XX.Y.Z/lib64/libstdc++.so`;
- GCC finds its own libraries;
- No need to add `/opt/llvm-AA.B.C/lib` because executables in LLVM use `RUNPATH` and do not depend on custom system libs.

## Licence

This script is released under a permissive BSD-style licence; see the script header for details.