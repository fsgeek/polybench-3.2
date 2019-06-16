#/bin/sh

VMMALLOC_POOL_SIZE=$((170*1024*1024*1024))
#export VMMALLOC_POOL_DIR="/mnt/pmem7/fsgeek"

#LD_PRELOAD=libvmmalloc.so.1 grep "pmem" /proc/mounts
node_pmem7=1
node_pmem1=0
timestamp=`date '+%Y_%m_%d__%H_%M_%S'`;
hostname=`hostname`

# log files
RESULTS_DIR="./pb-results-"$timestamp
MAKE_LOG=$RESULTS_DIR"/pb-make-"$hostname"-"$timestamp".log"
DRAM_FILE=$RESULTS_DIR"/pb-dram-"$hostname"-"$timestamp".log"
PMEM7_FILE=$RESULTS_DIR"/pb-pmem7-"$hostname"-"$timestamp".log"
PMEM1_FILE=$RESULTS_DIR"/pb-pmem1-"$hostname"-"$timestamp".log"
PMEM7_POOL_DIR="/mnt/pmem7/fsgeek"
PMEM1_POOL_DIR="/mnt/pmem1/fsgeek"

[ ! -d $PMEM7_POOL_DIR ] && mkdir $PMEM7_POOL_DIR && echo "mkdir $PMEM7_POOL_DIR"
[ ! -d $PMEM1_POOL_DIR ] && mkdir $PMEM1_POOL_DIR && echo "mkdir $PMEM1_POOL_DIR"
[ ! -d $RESULTS_DIR ] && mkdir $RESULTS_DIR && echo "mkdir $RESULTS_DIR"

BENCH="
./linear-algebra/kernels/gesummv/gesummv_time
./linear-algebra/solvers/durbin/durbin_time
"
## Rebuild
make -f Makefile.extralarge &>>$MAKE_LOG

## Run all benchmarks
for b in $BENCH
do
    echo "Start $b"
    #echo $b >> $DRAM_FILE
    #$b &>>$DRAM_FILE
    #aeplog=$RESULTS_DIR"/aep-pmem7-"$(basename -- $b)"-"$timestamp".csv"
    #AEPWatch 1 -f $aeplog &
    #echo $b >> $PMEM7_FILE
    #hwloc-bind node:$node_pmem7 -- VMMALLOC_POOL_DIR=$PMEM7_POOL_DIR LD_PRELOAD=libvmmalloc.so.1 $b &>>$PMEM7_FILE
    #AEPWatch-stop
    #sleep 1
    #aeplog=$RESULTS_DIR"/aep-pmem1-"$(basename -- $b)"-"$timestamp".csv"
    #AEPWatch 1 -f $aeplog &
    echo $b >> $PMEM1_FILE
    hwloc-bind node:$node_pmem1 -- ./wrapper.sh $PMEM1_POOL_DIR $VMMALLOC_POOL_SIZE $b PMEM1_FILE
    #VMMALLOC_POOL_DIR=$PMEM1_POOL_DIR LD_PRELOAD=libvmmalloc.so.1 hwloc-bind node:$node_pmem1 -- $b &>>$PMEM1_FILE
    #AEPWatch-stop
    echo "End $b"
done


