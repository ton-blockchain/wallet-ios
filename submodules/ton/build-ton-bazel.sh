#/bin/sh

set -x
set -e

OUT_DIR="$(pwd)/$1"
SOURCE_DIR="$(pwd)/$2"
openssl_base_path="$(pwd)/$3"
mac_openssl_path="$4"
arch="$5"


if [ ! -d "$openssl_base_path" ]; then
  echo "$openssl_base_path not found"
  exit 1
fi

if [ ! -d "$mac_openssl_path" ]; then
  echo "$mac_openssl_path not found"
  exit 1
fi

ARCHIVE_PATH="$SOURCE_DIR/tonlib.zip"
td_path="$SOURCE_DIR/tonlib-src"
APPLE_TOOLCHAIN="$SOURCE_DIR/Apple-bazel.cmake"
iOS_TOOLCHAIN="$SOURCE_DIR/iOS-bazel.cmake"

mkdir -p "$OUT_DIR"
mkdir -p "$OUT_DIR/build"
cd "$OUT_DIR/build"

git_executable_path="/usr/bin/git"

openssl_path="$openssl_base_path"
echo "OpenSSL path = ${openssl_path}"

mac_opensslpath="$mac_openssl_path"
echo "macOS OpenSSL path = ${mac_opensslpath}"

options="$options -DOPENSSL_FOUND=1"
options="$options -DCMAKE_BUILD_TYPE=Release"
options="$options -DGIT_EXECUTABLE=${git_executable_path}"
options="$options -DTON_ONLY_TONLIB=ON"
options="$options -DTON_ARCH="

build="build-${arch}"
install="install-${arch}"

if [ "$arch" == "armv7" ]; then
  ios_platform="OSV7"
elif [ "$arch" == "arm64" ]; then
  ios_platform="OS64"
elif [ "$arch" == "x86_64" ]; then
  ios_platform="SIMULATOR"
else
  echo "Unsupported architecture $arch"
  exit 1
fi

# Expose homebrew bundles to ENV
if [[ $(uname -m) == 'arm64' ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)" || true
fi

# Prepare build and generate [auto] code
rm -rf $build
mkdir -p $build
cd $build

CORE_COUNT=`sysctl -n hw.logicalcpu`

cmake $td_path $options -DCMAKE_TOOLCHAIN_FILE="$APPLE_TOOLCHAIN" -DOPENSSL_INCLUDE_DIR=${mac_opensslpath}/include -DOPENSSL_CRYPTO_LIBRARY=${mac_opensslpath}/lib/libcrypto.a
cmake --build . --target prepare_cross_compiling

cd ..

# Build for specific target
rm -rf $build
mkdir -p $build
mkdir -p $install
cd $build

cmake $td_path $options -DCMAKE_TOOLCHAIN_FILE="$iOS_TOOLCHAIN" -DOPENSSL_INCLUDE_DIR=${openssl_path}/include -DOPENSSL_CRYPTO_LIBRARY=${openssl_path}/lib/libcrypto.a -DIOS_PLATFORM=${ios_platform} -DCMAKE_INSTALL_PREFIX=../${install}
make -j$CORE_COUNT install || exit

cd ..

mkdir -p "out"
cp -r "$install/include" "out/"
mkdir -p "out/lib"

for f in $install/lib/*.a; do
  lib_name=$(basename "$f")
  cp "$install/lib/$lib_name" "out/lib/$lib_name"
done
