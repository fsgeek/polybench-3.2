#!/bin/bash


VMMALLOC_POOL_DIR=$1 export VMMALLOC_POOL_SIZE=$2 LD_PRELOAD=libvmmalloc.so.1 $3 &>> $4

