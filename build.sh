#!/bin/sh

VER=$1

if [ -z "$VER" ] ; then
    echo "build.sh (tag)"
    echo "    e.g. build.sh v0.6"
    exit 1
fi

if [ ! -d build ] ; then
    mkdir build
fi

# redis.tar
target="redis:7.0.2-bullseye"
tarball="build/redis.tar"
if [ ! -f $tarball ] ; then
    image=$(docker images -q $target)
    if [ -z "$image" ] ; then
        docker pull $target
    fi
    docker save $target -o $tarball
fi

# slmpclient.tgz
if [ ! -f build/slmpclient.tgz ] ; then
    curl -L -o build/slmpclient.tgz https://github.com/tanupoo/PySLMPClient/archive/refs/tags/v0.0.1.tar.gz
fi

# ciox_exa.tar
tarball="build/ciox_exa-${VER}.tgz"
if [ ! -f $tarball ] ; then
    curl -f -L -o $tarball \
        https://github.com/tanupoo/ciox_exa/archive/refs/tags/${VER}.tar.gz
    if [ $? -ne 0 ] ; then
        exit $?
    fi
fi

target="ciox_exa:${VER}"
tarball="build/ciox_exa.tar"
if [ ! -f $tarball ] ; then
    docker build --build-arg VER="${VER}" -t $target .
    docker save $target -o $tarball
fi

