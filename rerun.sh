#/bin/sh

export VMMALLOC_POOL_SIZE=$((90*1024*1024*1024))
#export VMMALLOC_POOL_DIR="/mnt/pmem7/fsgeek"

#LD_PRELOAD=libvmmalloc.so.1 grep "pmem" /proc/mounts
node7=1
node1=0
timestamp=`date '+%Y_%m_%d__%H_%M_%S'`;
hostname=`hostname`
DRAM_FILE="./pb-dram-"$hostname"-"$timestamp".log"
PMEM7_FILE="./pb-pmem7-"$hostname"-"$timestamp".log"
PMEM1_FILE="./pb-pmem1-"$hostname"-"$timestamp".log"
PMEM7_POOL_DIR="/mnt/pmem7/fsgeek"
PMEM1_POOL_DIR="/mnt/pmem1/fsgeek"

# make sure working directory exists
mkdir $PMEM7_POOL_DIR
mkdir $PMEM1_POOL_DIR

BENCH="
./linear-algebra/kernels/atax/atax_time
"

## Run all benchmarks
for b in $BENCH
do
    #echo $b >> $DRAM_FILE
    #$b &>>$DRAM_FILE
    #aeplog7="./aep-pmem7-"$(basename -- $b)"-"$timestamp".csv"
    #AEPWatch 1 -f $aeplog7 &
    #echo $b >> $PMEM7_FILE
    #VMMALLOC_POOL_DIR="/mnt/pmem7/fsgeek" LD_PRELOAD=libvmmalloc.so.1 hwloc-bind node:$node7 -- $b &>>$PMEM7_FILE
    #AEPWatch-stop
    #sleep 1
    aeplog1="./aep-pmem1-"$(basename -- $b)"-"$timestamp".csv"
    AEPWatch 1 -f $aeplog1 &
    echo $b >> $PMEM1_FILE
    VMMALLOC_POOL_DIR="/mnt/pmem1/fsgeek" LD_PRELOAD=libvmmalloc.so.1 hwloc-bind node:$node1 -- $b &>>$PMEM1_FILE
    AEPWatch-stop
done

