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

# Abort on error and treat unset vars as errors.
# (Note: `set -u` is POSIX; `set -e` is POSIX but does not propagate into
# subshells).
set -eu

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 gcc-XX.Y.Z" >&2
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
destdir="/opt/$VERSION"

if [ ! -f "$srcdir/configure" ] || [ ! -r "$srcdir/configure" ]; then
  echo "Error: $srcdir does not look like a GCC source tree" >&2
  exit 1
fi

echo "Source directory: $srcdir"
echo "Destination directory: $destdir"

SLKCFLAGS="-O2 -fPIC -fno-plt -pipe"
LIBDIRSUFFIX="64"
LIB_ARCH="amd64"
TARGET="x86_64-slackware-linux"
NUMJOBS="-j8"

mkdir -p build
cd build

GCC_ARCHOPTS="--disable-multilib"

CFLAGS="$SLKCFLAGS" \
CXXFLAGS="$SLKCFLAGS" \
"$srcdir/configure" \
  --prefix="$destdir" \
  --libdir="$destdir/lib$LIBDIRSUFFIX" \
  --enable-shared \
  --enable-bootstrap \
  --enable-languages=c,c++,lto \
  --enable-threads=posix \
  --enable-checking=release \
  --with-system-zlib \
  --disable-libstdcxx-pch \
  --enable-__cxa_atexit \
  --disable-libssp \
  --enable-gnu-unique-object \
  --enable-plugin \
  --enable-lto \
  --disable-install-libiberty \
  --disable-werror \
  --with-gnu-ld \
  --with-isl \
  --verbose \
  --with-arch-directory="$LIB_ARCH" \
  --disable-gtktest \
  --enable-clocale=gnu \
  $GCC_ARCHOPTS \
  --target=${TARGET} \
  --build=${TARGET} \
  --host=${TARGET}

make $NUMJOBS bootstrap
make info
make install
