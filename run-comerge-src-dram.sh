#/bin/sh

node_dram1=1
timestamp=`date '+%Y_%m_%d__%H_%M_%S'`;
hostname=`hostname`

# log files
RESULTS_DIR="./comerge-pb-src-dram-results-"$timestamp
MAKE_LOG=$RESULTS_DIR"/pb-make-"$hostname"-"$timestamp".log"
DRAM0_FILE=$RESULTS_DIR"/pb-dram1-"$hostname"-"$timestamp".log"
DRAM0H_FILE=$RESULTS_DIR"/pb-dram1-h-"$hostname"-"$timestamp".log"

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

[ ! -d $RESULTS_DIR ] && mkdir $RESULTS_DIR && echo "mkdir $RESULTS_DIR"

## Rebuild
make -f Makefile.comerge >> $MAKE_LOG 2>&1

# Make sure the huge tlb sizes are set up properly
hugeadm --pool-list >> $DRAM0H_FILE 2>&1
hugeadm --pool-pages-max 2MB:8192 >> $DRAM0H_FILE 2>&1

## Run all benchmarks
for b in $BENCH
do
    echo "Start $b"
    echo hwloc-bind --single node:$node_dram1 --verbose -- perf stat -B -d -d -d ./wrapper-hugetlb.sh $b $DRAM0H_FILE >> $DRAM0H_FILE
    hwloc-bind --single node:$node_dram1 --verbose -- perf stat -B -d -d -d ./wrapper-hugetlb.sh $b $DRAM0H_FILE >> $DRAM0H_FILE 2>&1
    echo finished >> $DRAM0H_FILE
    echo hwloc-bind --single node:$node_dram1 --verbose -- perf stat -B -d -d -d $b >> $DRAM0_FILE
    hwloc-bind --single node:$node_dram1 --verbose -- perf stat -B -d -d -d $b >> $DRAM0_FILE 2>&1
    echo finished >> $DRAM0_FILE
    echo "End $b"
done


