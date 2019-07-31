#/bin/sh

export VMMALLOC_POOL_SIZE=$((10*1024*1024*1024))

node_pmem7=1
node_pmem1=0
node_dram0=0
node_dram1=1
timestamp=`date '+%Y_%m_%d__%H_%M_%S'`;
hostname=`hostname`

# log files
RESULTS_DIR="./comerge-pb-subset-numactl-results-"$timestamp
MAKE_LOG=$RESULTS_DIR"/pb-make-"$hostname"-"$timestamp".log"
DRAM0_FILE=$RESULTS_DIR"/pb-dram0-"$hostname"-"$timestamp".log"
DRAM1_FILE=$RESULTS_DIR"/pb-dram1-"$hostname"-"$timestamp".log"
PMEM7_FILE=$RESULTS_DIR"/pb-pmem7-"$hostname"-"$timestamp".log"
PMEM1_FILE=$RESULTS_DIR"/pb-pmem1-"$hostname"-"$timestamp".log"
PMEM7_POOL_DIR="/mnt/pmem7/fsgeek"
PMEM1_POOL_DIR="/mnt/pmem1/fsgeek"

[ ! -d $PMEM7_POOL_DIR ] && mkdir $PMEM7_POOL_DIR && echo "mkdir $PMEM7_POOL_DIR"
[ ! -d $PMEM1_POOL_DIR ] && mkdir $PMEM1_POOL_DIR && echo "mkdir $PMEM1_POOL_DIR"
[ ! -d $RESULTS_DIR ] && mkdir $RESULTS_DIR && echo "mkdir $RESULTS_DIR"

BENCH="
./linear-algebra/kernels/gemm/gemm_time
./linear-algebra/kernels/mvt/mvt_time 
./linear-algebra/kernels/symm/symm_time
./linear-algebra/solvers/gramschmidt/gramschmidt_time
./datamining/covariance/covariance_time
./medley/floyd-warshall/floyd-warshall_time
./medley/reg_detect/reg_detect_time
"
## Rebuild
make -f Makefile.comerge >> $MAKE_LOG 2>&1

## Run all benchmarks
for b in $BENCH
do
    echo "Start $b"
    aeplog=$RESULTS_DIR"/aep-pmem7-"$(basename -- $b)"-"$timestamp".csv"
    echo "AEPWatch 1 -f "$aeplog >> $PMEM7_FILE
    AEPWatch 1 -f $aeplog &
    echo VMMALLOC_POOL_DIR=$PMEM7_POOL_DIR LD_PRELOAD=libvmmalloc.so.1 perf stat -B -d -d -d numactl --cpunodebind=$node_pmem7 --membind=$node_pmem7 $b >>$PMEM7_FILE 2>&1
    VMMALLOC_POOL_DIR=$PMEM7_POOL_DIR LD_PRELOAD=libvmmalloc.so.1 perf stat -B -d -d -d numactl --cpunodebind=$node_pmem7 --membind=$node_pmem7 $b >>$PMEM7_FILE 2>&1
    sleep 128
    echo "AEPWatch-stop" >>$PMEM7_FILE 2>&1
    AEPWatch-stop >> $PMEM7_FILE 2>&1
    echo finished >> $PMEM7_FILE

    echo hwloc-bind --single node:$node_pmem1 --verbose -- perf stat -B -d -d -d ./wrapper-comerge.sh $PMEM1_POOL_DIR $VMMALLOC_POOL_SIZE $b $PMEM1_FILE >> $PMEM1_FILE
    aeplog=$RESULTS_DIR"/aep-pmem1-"$(basename -- $b)"-"$timestamp".csv"
    echo "AEPWatch 1 -f "$aeplog >> $PMEM1_FILE
    AEPWatch 1 -f $aeplog &
    echo VMMALLOC_POOL_DIR=$PMEM1_POOL_DIR LD_PRELOAD=libvmmalloc.so.1 perf stat -B -d -d -d numactl --cpunodebind=$node_pmem1 --membind=$node_pmem1 $b >>$PMEM1_FILE 2>&1
    VMMALLOC_POOL_DIR=$PMEM1_POOL_DIR LD_PRELOAD=libvmmalloc.so.1 perf stat -B -d -d -d numactl --cpunodebind=$node_pmem1 --membind=$node_pmem1 $b >>$PMEM1_FILE 2>&1
    sleep 128
    echo "AEPWatch-stop" >>$PMEM1_FILE
    AEPWatch-stop >> $PMEM1_FILE 2>&1
    echo finished >> $PMEM1_FILE
    
    echo perf stat -B -d -d -d numactl --cpunodebind=$node_dram0 --membind=$node_dram0 $b >>$DRAM0_FILE 2>&1
    perf stat -B -d -d -d numactl --cpunodebind=$node_dram0 --membind=$node_dram0 $b >>$DRAM0_FILE 2>&1
    echo finished >> $DRAM0_FILE

    echo perf stat -B -d -d -d numactl --cpunodebind=$node_dram1 --membind=$node_dram1 $b >>$DRAM1_FILE 2>&1
    perf stat -B -d -d -d numactl --cpunodebind=$node_dram1 --membind=$node_dram1 $b >>$DRAM1_FILE 2>&1
    echo finished >> $DRAM1_FILE
    echo "End $b"
done


