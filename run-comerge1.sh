#!/bin/sh

#waittime=18000 # 60 * 60 * 5 = 5 hours
#echo sleep $waittime
#sleep $waittime

timestamp=`date '+%Y_%m_%d__%H_%M_%S'`;

./run-comerge-aep.sh >& run-comerge-$timestamp-run-1.log

