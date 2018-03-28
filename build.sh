#!/bin/sh
dist=$1
shift
tag=""

case "$dist" in
    "debian")
        tag="debian:lates"
        ;;
    "ubuntu")
        tag="ubuntu:latest"
        ;;
    "precise")
        tag="ubuntu:precise"
        ;;
    "trusty")
        tag="ubuntu:trusty"
        ;;
    "utopic")
        tag="ubuntu:utopic"
        ;;
    "xenial")
        tag="ubuntu:xenial"
        ;;
esac

docker build \
    --build-arg name="Jared Johnson" \
    --build-arg email="jjohnson@efolder.net" \
    --build-arg version="efs1204+0" \
    --build-arg distribution="rb-precise-alpha" \
    -t \
    build-dkms-$tag \
    .

docker run --rm -it -v "${PWD}/output:/out" build-dkms-$tag
