#!/bin/bash

BUILD_DIR=../platforms/ubuntu_touch/build

mkdir -p $BUILD_DIR
cd $BUILD_DIR
qt5-qmake-arm-linux-gnueabihf ..
make -j

cd ../../../build
rm -rf tmp
mkdir -p tmp
cd tmp

pwd
cp ../$BUILD_DIR/manifest.json .
cp ../$BUILD_DIR/gearboy .
cp ../$BUILD_DIR/../gearboy-content.json .
cp ../$BUILD_DIR/../gearboy.svg .
cp ../$BUILD_DIR/../gearboy.apparmor .
cp ../$BUILD_DIR/../gearboy.rpattison.desktop .
