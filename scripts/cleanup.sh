#!/bin/bash
# this script cleans up all the temporary files that can always be generated by hooks/pre-commit

WORKING_DIR=$(pwd)
echo "working dir=${WORKING_DIR}"

set -x

# clean up CMake-related files
find . -type d -name CMakeFiles -print0 | xargs -0 rm -rf CMakeFiles
find . -type f -name CMakeCache.txt -print0 | xargs -0 rm

# clean up compiled binaries and libraries
rm -rf build

# clean up files generated by protobuf
rm -rf src/app_demo/generated
rm -rf src/app_util/generated
rm -rf src/infra/es/store/generated
rm -rf src/infra/raft/generated

# clean up files generated by test
rm -rf test/test_coverage_lcov
rm -f test/test_coverage_lcov.info
rm -f test/test_coverage_cobertura.xml
rm -rf test/target
rm -f test/bullseye.cov
rm -f test/bullseye.xml

# clean up docs
rm -rf docs/doxygen
