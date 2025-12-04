#!/bin/sh
#
# Copyright (c) 2025, Manlio Morini
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# POSIX-strict build script for `LLVM/Clang` under `/opt`.
# It assumes a source tree structured like the official LLVM monorepo.

# Abort on error and treat unset vars as errors.
# (Note: `set -u` is POSIX; `set -e` is POSIX but does not propagate into subshells).
set -eu

# Increase file descriptors to avoid LLVM link failures.
ulimit -n 65536 || echo "Warning: could not raise ulimit -n"

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 llvm-project-XX.Y.Z" >&2
  exit 1
fi

# Resolve directories.
VERSION=$(basename "$1")

# The primary use of `--` is to tell the shell that all following arguments
# should be treated as operands (like filenames or directory names), even if
# they begin with a hyphen.
# Without `--`, if your directory name began with a hyphen, the dirname command
# would incorrectly interpret it as an option or flag.
srcbase=$(dirname -- "$1")

srcdir=$(cd "$srcbase" && pwd)/"$VERSION"

# LLVM uses CMake, so check CMakeLists.txt instead of configure.
if [ ! -f "$srcdir/llvm/CMakeLists.txt" ]; then
  echo "Error: $srcdir does not look like an LLVM/Clang source tree" >&2
  exit 1
fi

# Install dir for final toolchain
destdir="/opt/$VERSION"

# Detect GCC toolchain (only if present under `/opt`).
set +e
GCC_CANDIDATES=$(ls -d /opt/gcc-* 2>/dev/null | sort -V)
set -e

FOUND_GCC=""
if [ -n "$GCC_CANDIDATES" ]; then
  FOUND_GCC=$(printf "%s\n" "$GCC_CANDIDATES" | tail -n 1)
fi

if [ -n "$FOUND_GCC" ]; then
  echo " Found GCC toolchain: $FOUND_GCC"
  EXTRA_CFLAGS="-I$FOUND_GCC/include"
  EXTRA_LDFLAGS="-L$FOUND_GCC/lib64 -Wl,-rpath,$FOUND_GCC/lib64"
  STD_CXX_LIB="libstdc++"
else
  echo " No /opt/gcc-* found, using system libraries"
  EXTRA_CFLAGS=""
  EXTRA_LDFLAGS=""
  STD_CXX_LIB=""   # use libc++ defaults
fi

# Stage-1 compiler (assumes clang is presentbuild with system Clang).
echo "=== Stage-1: system Clang bootstrap ==="

mkdir -p build-stage1
cd build-stage1

# Flags and build options
SLKCFLAGS="-O2 -fPIC -pipe -fno-plt"
LIBDIRSUFFIX="64"
NUMJOBS="-j8"

CFLAGS="$SLKCFLAGS"
CXXFLAGS="$SLKCFLAGS"

# Common CMake invocation
cmake -G "Unix Makefiles" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="/tmp/llvm-bootstrap-$VERSION" \
  -DCMAKE_INSTALL_LIBDIR="lib$LIBDIRSUFFIX" \
  -DCMAKE_C_COMPILER="clang" \
  -DCMAKE_CXX_COMPILER="clang++" \
  -DCMAKE_C_FLAGS="$CFLAGS" \
  -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
  -DLLVM_ENABLE_PROJECTS="clang;lld" \
  -DLLVM_TARGETS_TO_BUILD="X86" \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_ENABLE_EH=ON \
  -DLLVM_ENABLE_ASSERTIONS=OFF \
  -DLLVM_BUILD_LLVM_DYLIB=ON \
  -DLLVM_LINK_LLVM_DYLIB=ON \
  -DLLVM_USE_LINKER=lld \
  -DLLVM_USE_RELATIVE_PATHS_IN_FILES=ON \
  "$srcdir/llvm"

make $NUMJOBS
make install

cd ..

# Stage-2: final build linked against /opt/gcc-XX

echo "=== Stage-2: final Clang, optionally linked to $FOUND_GCC ==="

mkdir -p build-final
cd build-final

CFLAGS="$SLKCFLAGS $EXTRA_CFLAGS"
CXXFLAGS="$SLKCFLAGS $EXTRA_CFLAGS"
LDFLAGS="$EXTRA_LDFLAGS"

cmake -G "Unix Makefiles" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$destdir" \
  -DCMAKE_INSTALL_LIBDIR="lib$LIBDIRSUFFIX" \
  -DCMAKE_C_COMPILER="/tmp/llvm-bootstrap-$VERSION/bin/clang" \
  -DCMAKE_CXX_COMPILER="/tmp/llvm-bootstrap-$VERSION/bin/clang++" \
  -DCMAKE_C_FLAGS="$CFLAGS" \
  -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
  -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
  -DCMAKE_SHARED_LINKER_FLAGS="$LDFLAGS" \
  -DLLVM_ENABLE_PROJECTS="clang;lld;compiler-rt" \
  -DLLVM_TARGETS_TO_BUILD="X86" \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_ENABLE_EH=ON \
  -DLLVM_ENABLE_ASSERTIONS=OFF \
  -DLLVM_BUILD_LLVM_DYLIB=ON \
  -DLLVM_LINK_LLVM_DYLIB=ON \
  -DLLVM_USE_LINKER=lld \
  -DLLVM_ENABLE_TERMINFO=OFF \
  -DLLVM_ENABLE_ZLIB=ON \
  -DLLVM_ENABLE_ZSTD=OFF \
  -DLLVM_USE_RELATIVE_PATHS_IN_FILES=ON \
  -DCLANG_DEFAULT_CXX_STDLIB="$STD_CXX_LIB" \
  "$srcdir/llvm"

make $NUMJOBS
make install

echo "=== Installation completed successfully at $destdir ==="
