# Building a custom GCC toolchain under `/opt`

This script automates the process of configuring, building, and installing a self-contained GCC toolchain under `/opt/<version>`.

It is intended for Slackware-like systems but works on any Linux environment with a POSIX shell, standard build tools, and the usual GCC dependencies installed.

The script performs a clean out-of-tree build, enables only the C, C++, and LTO front-ends, and uses conservative optimisation flags (`-O2 -fPIC -fno-plt -pipe`) suitable for generic distribution on x86-64.

## Overview

The script expects a single argument: the path to an extracted GCC source tree, e.g.:

```shell
./build-gcc.sh /path/to/gcc-14.2.0
```

It resolves the absolute source directory, creates a dedicated `build/` directory, configures a GCC build with the desired options, and performs a full bootstrap.
The resulting compiler and libraries are installed under:

```shell
/opt/<gcc-version>/
```

This avoids interfering with the system compiler and keeps multiple GCC versions neatly isolated.

## What the script does

The most relevant configure options are:

- `--enable-languages=c,c++,lto`
    Only the C compiler, C++ compiler, and link-time optimiser are built. Ada, Fortran, Go, and others remain disabled.
- `--disable-multilib`
    Builds a pure 64-bit toolchain, consistent with Slackware’s layout.
- `--enable-bootstrap`
    Builds GCC in three stages to verify correctness and improve optimisation.
- `--with-system-zlib`, `--with-isl`
    Uses system libraries where appropriate.
- Various smaller quality-of-life flags (plug-ins enabled, libssp disabled, no PCH for libstdc++ to reduce disk footprint...).

A dedicated build/ directory keeps everything tidy and avoids polluting the source tree.

The script performs:

```shell
make -jN bootstrap
```

to build a three-stage compiler.

After building, the script installs: compiler binaries, libraries, headers, manuals (via make info) into `/opt/<version>/` without affecting the system compiler.

This allows multiple coexisting toolchains simply by adjusting `$PATH` when needed.

## Side notes

### Why bootstrap?

A bootstrap build recompiles GCC using itself to ensure consistency and to squeeze out slightly better performance. It takes longer, but it is the standard method recommended by GCC developers.

### Why install under /opt?

This avoids:
- replacing the system compiler;
- conflicting with distribution packages;
- contaminating `/usr/local`'

Each version lives in its own prefix, and nothing else is modified.

## Adjusting your environment

To use the newly installed compiler, add the following lines to a user's `.bashrc`:

```
export PATH=/opt/<version>/bin:$PATH
export LD_LIBRARY_PATH=/opt/<version>/lib64:$LD_LIBRARY_PATH
```

## Licence

This script is released under a permissive BSD-style licence; see the script header for details.