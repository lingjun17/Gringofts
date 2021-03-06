#!/bin/bash
# This script installs all external dependencies

checkLastSuccess() {
  # shellcheck disable=SC2181
  if [[ $? -ne 0 ]]; then
    echo "Install Error: $1"
    exit 1
  fi
}

# install cmake 3.12
CMAKE=$(cmake --version | grep "3.12")
if [ -z "$CMAKE" ]; then
  cd ~/temp/cmake &&
    ./bootstrap && make -j4 && make install
  checkLastSuccess "install cmake 3.12 fails"
else
  echo "cmake 3.12 has been installed, skip"
fi
# install prometheus cpp client
PROMETHEUS=$(find /usr -name *prometheus*)
if [ -z "$PROMETHEUS" ]; then
  cd ~/temp/prometheus-cpp/ &&
    cmake CMakeLists.txt && make -j 4 && make install
  checkLastSuccess "install prometheus cpp client fails"
else
  echo "prometheus client has been installed, skip"
fi
# install grpc and related components
# 1. install cares
CARES=$(find /usr -name *c-ares*)
if [ -z "$CARES" ]; then
  cd ~/temp/grpc/third_party/cares/cares &&
    CXX=g++-7 CC=gcc-7 cmake -DCMAKE_BUILD_TYPE=Debug &&
    make && make install
  checkLastSuccess "install cares fails"
else
  echo "c-ares has been installed, skip"
fi
# 2. install protobuf
PROTOBUF=$(protoc --version | grep "3.6")
if [ -z "$PROTOBUF" ]; then
  cd ~/temp/grpc/third_party/protobuf/cmake &&
    mkdir -p build && cd build &&
    # use cmake instead of autogen.sh so that protobuf-config.cmake can be installed
    CXX=g++-7 CC=gcc-7 cmake -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Debug .. &&
    make && make install && make clean && ldconfig
  checkLastSuccess "install protobuf fails"
else
  echo "protobuf v3.6 has been installed, skip"
fi
# 3. install grpc
# install libssl-dev to skip installing boringssl
GRPC=$(grep "1.16" /usr/local/lib/cmake/grpc/gRPCConfigVersion.cmake)
if [ -z "$GRPC" ]; then
  cd ~/temp/grpc &&
    sed -i -E "s/(gRPC_ZLIB_PROVIDER.*)module(.*CACHE)/\1package\2/" CMakeLists.txt &&
    sed -i -E "s/(gRPC_CARES_PROVIDER.*)module(.*CACHE)/\1package\2/" CMakeLists.txt &&
    sed -i -E "s/(gRPC_SSL_PROVIDER.*)module(.*CACHE)/\1package\2/" CMakeLists.txt &&
    sed -i -E "s/(gRPC_PROTOBUF_PROVIDER.*)module(.*CACHE)/\1package\2/" CMakeLists.txt &&
    CXX=g++-7 CC=gcc-7 cmake -DCMAKE_BUILD_TYPE=Debug &&
    make && make install && make clean && ldconfig
  checkLastSuccess "install grpc fails"
else
  echo "gRPC v1.16 has been installed, skip"
fi
# install rocksdb
ROCKSDB=$(find /usr -name *rocksdb*)
if [ -z "$ROCKSDB" ]; then
  cd ~/temp/rocksdb &&
    # enable portable due to https://github.com/benesch/cockroach/commit/0e5614d54aa9a11904f59e6316cfabe47f46ce02
    export PORTABLE=1 && export FORCE_SSE42=1 &&
    make static_lib &&
    make install-static
  checkLastSuccess "install rocksdb fails"
else
  echo "RocksDB has been installed, skip"
fi
# install abseil-cpp
ABSL=$(find /usr -name *absl*)
if [ -z "$ABSL" ]; then
  cd ~/temp/abseil-cpp &&
    # explicitly set DCMAKE_CXX_STANDARD due to https://github.com/abseil/abseil-cpp/issues/218
    CXX=g++-7 CC=gcc-7 cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=17 &&
    make && make install
  checkLastSuccess "install abseil-cpp fails"
else
  echo "abseil has been installed, skip"
fi
# install go v1.11
# shellcheck disable=SC1090
GO=$(go version | grep "1.1")
if [ -z "$GO" ]; then
  cd ~/temp/ &&
    rm -rf /usr/local/go && mv -f go /usr/local &&
    if ! grep "export PATH=/usr/local/go/bin:$PATH" ~/.profile; then echo "export PATH=/usr/local/go/bin:$PATH" >>~/.profile; fi &&
    source ~/.profile
  checkLastSuccess "install golang fails"
else
  echo "go v1.1 has been installed, skip"
fi
# give read access to cmake modules
chmod o+rx -R /usr/local/lib/cmake
chmod o+rx -R /usr/local/include/
