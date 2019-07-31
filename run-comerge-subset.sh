#!/bin/sh

#waittime=18000 # 60 * 60 * 5 = 5 hours
#echo sleep $waittime
#sleep $waittime

timestamp=`date '+%Y_%m_%d__%H_%M_%S'`;

./run-comerge-aep-subset.sh >& run-comerge-subset-$timestamp-run-1.log
./run-comerge-aep-subset.sh >& run-comerge-subset-$timestamp-run-2.log
./run-comerge-aep-subset.sh >& run-comerge-subset-$timestamp-run-3.log
./run-comerge-aep-subset.sh >& run-comerge-subset-$timestamp-run-4.log
./run-comerge-aep-subset.sh >& run-comerge-subset-$timestamp-run-5.log
