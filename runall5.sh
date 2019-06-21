#!/bin/sh

timestamp=`date '+%Y_%m_%d__%H_%M_%S'`;

./runall.sh >& runall-$timestamp-run-1.log
./runall.sh >& runall-$timestamp-run-2.log
./runall.sh >& runall-$timestamp-run-3.log
./runall.sh >& runall-$timestamp-run-4.log
./runall.sh >& runall-$timestamp-run-5.log

