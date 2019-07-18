#!/bin/sh

echo $4
perf stat -B -d -d -d VMMALLOC_POOL_DIR=$1 VMMALLOC_POOL_SIZE=$2 LD_PRELOAD=libvmmalloc.so.1 $3 >> $4 2>&1

