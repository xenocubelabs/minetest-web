#!/bin/bash -eux

source common.sh

UPSTREAM="https://curl.se/download/curl-7.82.0.tar.bz2"
TARBALL="curl-7.82.0.tar.bz2"
TARDIR="curl-7.82.0"

if [ ! -f sources/"$TARBALL" ]; then
  pushd sources
  wget "$UPSTREAM" -O "$TARBALL"
  popd
fi

if ! sha256sum sources/"$TARBALL" | grep -q 46d9a0400a33408fd992770b04a44a7434b3036f2e8089ac28b57573d59d371f; then
  echo "Wrong checksum for $TARDIR"
  exit 1
fi

pushd build
rm -rf "$TARDIR"
tar -jxvf "$SRC_DIR/$TARBALL"

# Wrap socket ops
$SRC_DIR/webshims/src/emsocket/wrap.py "$TARDIR"

rm -rf curl-build
mkdir curl-build
pushd curl-build

# For emsocket.h
export CFLAGS="-I${INSTALL_DIR}/include"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-L${INSTALL_DIR}/lib -lemsocket"

emcmake cmake \
  -DCURL_ENABLE_SSL=OFF \
  -DBUILD_CURL_EXE=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
  ../"$TARDIR"

emmake make -j4
emmake make install

echo "curl OK"