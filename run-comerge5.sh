#!/bin/sh

timestamp=`date '+%Y_%m_%d__%H_%M_%S'`;

./run-comerge.sh >& run-comerge-$timestamp-run-1.log
./run-comerge.sh >& run-comerge-$timestamp-run-2.log
./run-comerge.sh >& run-comerge-$timestamp-run-3.log
./run-comerge.sh >& run-comerge-$timestamp-run-4.log
./run-comerge.sh >& run-comerge-$timestamp-run-5.log

