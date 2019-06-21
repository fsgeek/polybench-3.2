#/bin/sh

VMMALLOC_POOL_SIZE=$((90*1024*1024*1024))
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
./linear-algebra/kernels/2mm/2mm_time
./linear-algebra/kernels/3mm/3mm_time
./linear-algebra/kernels/atax/atax_time
./linear-algebra/kernels/bicg/bicg_time
./linear-algebra/kernels/cholesky/cholesky_time
./linear-algebra/kernels/doitgen/doitgen_time
./linear-algebra/kernels/gemm/gemm_time
./linear-algebra/kernels/gemver/gemver_time
./linear-algebra/kernels/gesummv/gesummv_time
./linear-algebra/kernels/mvt/mvt_time 
./linear-algebra/kernels/symm/symm_time
./linear-algebra/kernels/syr2k/syr2k_time
./linear-algebra/kernels/syrk/syrk_time
./linear-algebra/kernels/trisolv/trisolv_time
./linear-algebra/kernels/trmm/trmm_time
./linear-algebra/solvers/durbin/durbin_time
./linear-algebra/solvers/dynprog/dynprog_time
./linear-algebra/solvers/gramschmidt/gramschmidt_time
./linear-algebra/solvers/lu/lu_time
./linear-algebra/solvers/ludcmp/ludcmp_time
./datamining/correlation/correlation_time
./datamining/covariance/covariance_time
./medley/floyd-warshall/floyd-warshall_time
./medley/reg_detect/reg_detect_time
./stencils/adi/adi_time
./stencils/fdtd-2d/fdtd-2d_time
./stencils/fdtd-apml/fdtd-apml_time
./stencils/jacobi-1d-imper/jacobi-1d-imper_time
./stencils/jacobi-2d-imper/jacobi-2d-imper_time
./stencils/seidel-2d/seidel-2d_time
"
## Rebuild
make -f Makefile.standard &>>$MAKE_LOG

## Run all benchmarks
for b in $BENCH
do
    echo "Start $b"
    echo $b >> $DRAM_FILE
    $b &>>$DRAM_FILE
    aeplog=$RESULTS_DIR"/aep-pmem7-"$(basename -- $b)"-"$timestamp".csv"
    AEPWatch 1 -f $aeplog &
    sleep 2
    echo $b >> $PMEM7_FILE
    hwloc-bind node:$node_pmem7 -- ./wrapper.sh $PMEM7_POOL_DIR $VMMALLOC_POOL_SIZE $b $PMEM7_FILE
    sleep 150
    AEPWatch-stop
    sleep 1
    aeplog=$RESULTS_DIR"/aep-pmem1-"$(basename -- $b)"-"$timestamp".csv"
    AEPWatch 1 -f $aeplog &
    sleep 2
    echo $b >> $PMEM1_FILE
    hwloc-bind node:$node_pmem1 -- ./wrapper.sh $PMEM1_POOL_DIR $VMMALLOC_POOL_SIZE $b $PMEM1_FILE
    sleep 150
    AEPWatch-stop
    echo "End $b"
done


