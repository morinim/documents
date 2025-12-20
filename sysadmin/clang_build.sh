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

# ------------------------------------------------------------------------
# Setup environment
# ------------------------------------------------------------------------
# Abort on error and treat unset vars as errors.
# (Note: `set -u` is POSIX; `set -e` is POSIX but does not propagate into
# subshells).
set -eu

command -v ninja >/dev/null 2>&1 || {
  echo "Error: ninja not found" >&2
  exit 1
}

# Increase file descriptors to avoid LLVM link failures.
ulimit -n 65536 || echo "Warning: could not raise ulimit -n"

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 llvm-project-XX.Y.Z" >&2
  exit 1
fi

LLVM_BASENAME=$(basename "$1")

case "$LLVM_BASENAME" in
  llvm-project-*)
    LLVM_VERSION=${LLVM_BASENAME#llvm-project-}
    ;;
  *)
    echo "Error: expected llvm-project-<version>" >&2
    exit 1
    ;;
esac

# Install dir for final toolchain
PREFIX="/opt/clang-${LLVM_VERSION}"

BUILD_STAGE1="$PWD/build-stage1"
BUILD_STAGE2="$PWD/build-stage2"
STAGE1_PREFIX="$PWD/stage1-install"

# The primary use of `--` is to tell the shell that all following arguments
# should be treated as operands (like filenames or directory names), even if
# they begin with a hyphen.
# Without `--`, if your directory name began with a hyphen, the dirname command
# would incorrectly interpret it as an option or flag.
SRCBASE=$(dirname -- "$1")

SRCDIR=$(cd "$SRCBASE" && pwd)/"$LLVM_BASENAME"

# Check for directory clashes.
case "$PWD" in
  "$SRCDIR"/*)
    echo "Error: build directory must not be inside the source tree." >&2
    exit 1
    ;;
esac

# LLVM uses CMake, so check CMakeLists.txt instead of configure.
if [ ! -f "$SRCDIR/llvm/CMakeLists.txt" ]; then
  echo "Error: $SRCDIR does not look like an LLVM/Clang source tree" >&2
  exit 1
fi

echo "Using sources from: $SRCDIR (containing version $LLVM_VERSION)"
echo "Destination directory: $PREFIX"

# ------------------------------------------------------------------------
# Stage 1 – bootstrap Clang using system libc++/libstdc++
# ------------------------------------------------------------------------
rm -rf "$BUILD_STAGE1"
cmake -G Ninja -S "$SRCDIR/llvm" -B "$BUILD_STAGE1" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$STAGE1_PREFIX" \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DLLVM_ENABLE_ZLIB=OFF \
    -DLLVM_ENABLE_ZSTD=OFF

ninja -C "$BUILD_STAGE1"
ninja -C "$BUILD_STAGE1" install

if [ ! -x "$STAGE1_PREFIX/bin/clang" ]; then
  echo "Error: stage-1 clang not found" >&2
  exit 1
fi

# ------------------------------------------------------------------------
# Stage 2 – final Clang built with libc++, libc++abi, compiler-rt
# ------------------------------------------------------------------------
rm -rf "$BUILD_STAGE2"

cmake -G Ninja -S "$SRCDIR/llvm" -B "$BUILD_STAGE2" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
    -DLLVM_USE_LINKER=lld \
    -DCMAKE_INSTALL_LIBDIR=lib64 \
    -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld" \
    -DLLVM_ENABLE_RUNTIMES="compiler-rt;libcxx;libcxxabi;libunwind" \
    -DLIBCXX_ENABLE_THREADS=ON \
    -DLIBCXX_HAS_PTHREAD_API=ON \
    -DLIBCXX_ENABLE_SHARED=ON \
    -DLIBCXXABI_ENABLE_THREADS=ON \
    -DLIBCXX_HAS_PTHREAD_API=ON \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DLLVM_ENABLE_ZLIB=ON \
    -DLLVM_ENABLE_ZSTD=ON \
-DCMAKE_INSTALL_RPATH='$ORIGIN/../lib64:$ORIGIN/../lib64/x86_64-unknown-linux-gnu' \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_C_COMPILER="$STAGE1_PREFIX/bin/clang" \
    -DCMAKE_CXX_COMPILER="$STAGE1_PREFIX/bin/clang++" \
    -DLIBCXX_USE_COMPILER_RT=ON \
    -DLIBCXXABI_USE_COMPILER_RT=ON \
    -DCOMPILER_RT_USE_LIBCXX=ON \
    -DLLVM_ENABLE_LIBCXX=ON \
    -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
    -DLIBCXX_INCLUDE_TESTS=OFF \
    -DLIBCXXABI_INCLUDE_TESTS=OFF \
    -DLLVM_ENABLE_LTO=Thin \
    -DLIBUNWIND_USE_COMPILER_RT=ON \
    -DCOMPILER_RT_BUILD_SANITIZERS=ON

ninja -C "$BUILD_STAGE2"
ninja -C "$BUILD_STAGE2" install

echo
echo "Clang installed in:"
echo "  $PREFIX"
echo
echo "Add to PATH:"
echo "  export PATH=\"$PREFIX/bin:\$PATH\""
echo
echo "clang++ defaults to libc++ instead of libstdc++"
