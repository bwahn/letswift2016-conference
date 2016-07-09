#!/bin/bash

/root/clone_build_test_kitura.sh

cd /letswift-server
swift build -Xcc -fblocks
./build/debug/letswift-api
