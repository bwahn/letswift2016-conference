#!/bin/bash

echo "abc"
/root/clone_build_test_kitura.sh

cd /letswift-api
swift build -Xcc -fblocks
./build/debug/myFirstProject
