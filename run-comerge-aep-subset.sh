#/bin/sh

VMMALLOC_POOL_SIZE=$((10*1024*1024*1024))

node_pmem7=1
node_pmem1=0
timestamp=`date '+%Y_%m_%d__%H_%M_%S'`;
hostname=`hostname`

# log files
RESULTS_DIR="./comerge-pb-subset-results-"$timestamp
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
    echo hwloc-bind --single node:$node_pmem7 --verbose -- perf stat -B -d -d -d ./wrapper-comerge.sh $PMEM7_POOL_DIR $VMMALLOC_POOL_SIZE $b $PMEM7_FILE >> $PMEM7_FILE 2>&1
    aeplog=$RESULTS_DIR"/aep-pmem7-"$(basename -- $b)"-"$timestamp".csv"
    echo "AEPWatch 1 -f "$aeplog >> $PMEM7_FILE
    AEPWatch 1 -f $aeplog &
    hwloc-bind --single node:$node_pmem7 --verbose -- perf stat -B -d -d -d ./wrapper-comerge.sh $PMEM7_POOL_DIR $VMMALLOC_POOL_SIZE $b $PMEM7_FILE >> $PMEM7_FILE 2>&1
    sleep 128
    echo "AEPWatch-stop" >>$PMEM7_FILE 2>&1
    AEPWatch-stop >> $PMEM7_FILE 2>&1
    echo finished >> $PMEM7_FILE

    echo hwloc-bind --single node:$node_pmem1 --verbose -- perf stat -B -d -d -d ./wrapper-comerge.sh $PMEM1_POOL_DIR $VMMALLOC_POOL_SIZE $b $PMEM1_FILE >> $PMEM1_FILE
    aeplog=$RESULTS_DIR"/aep-pmem1-"$(basename -- $b)"-"$timestamp".csv"
    echo "AEPWatch 1 -f "$aeplog >> $PMEM1_FILE
    AEPWatch 1 -f $aeplog &
    hwloc-bind --single node:$node_pmem1 --verbose -- perf stat -B -d -d -d ./wrapper-comerge.sh $PMEM1_POOL_DIR $VMMALLOC_POOL_SIZE $b $PMEM1_FILE >> $PMEM1_FILE 2>&1
    sleep 128
    echo "AEPWatch-stop" >>$PMEM1_FILE
    AEPWatch-stop >> $PMEM1_FILE 2>&1
    echo finished >> $PMEM1_FILE
    
    echo hwloc-bind --single node:0  --verbose -- perf stat -B -d -d -d $b >>$DRAM0_FILE 2>&1
    hwloc-bind --single node:0  --verbose -- perf stat -B -d -d -d $b >>$DRAM0_FILE 2>&1
    echo finished >> $DRAM0_FILE

    echo hwloc-bind --single node:1 --verbose -- perf stat -B -d -d -d $b >>$DRAM1_FILE 2>&1
    hwloc-bind --single node:1 --verbose -- perf stat -B -d -d -d $b >>$DRAM1_FILE 2>&1
    echo finished >> $DRAM1_FILE
    echo "End $b"
done


