#!/bin/bash -eux

# Incremental build for making changes to only minetest / irrlicht

export INCREMENTAL=true
./build_webshims.sh
./build_minetest.sh
./build_www.sh
