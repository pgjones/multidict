#!/bin/bash
package_name="$1"
if [ -z "$package_name" ]
then
    &>2 echo "Please pass package name as a first argument of this script ($0)"
    exit 1
fi

dock_ext_args=""

for arch in x86_64 i686
do
    docker pull "quay.io/pypa/manylinux1_${arch}" &
    docker_pull_pid_${arch}=$!
done

for arch in x86_64 i686
do
    wait docker_pull_pid_${arch}
    [ $arch == "i686" ] && dock_ext_args="linux32"

    echo Building wheel for $arch arch
    docker run --rm -v `pwd`:/io "quay.io/pypa/manylinux1_${arch}" $dock_ext_args /io/tools/build-wheels.sh "$package_name"

    dock_ext_args=""  # Reset docker args, just in case
done