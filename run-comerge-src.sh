#/bin/sh

VMMALLOC_POOL_SIZE=$((5*1024*1024*1024))

#LD_PRELOAD=libvmmalloc.so.1 grep "pmem" /proc/mounts
node_pmem4=0
node_pmem3=0
timestamp=`date '+%Y_%m_%d__%H_%M_%S'`;
hostname=`hostname`

# log files
RESULTS_DIR="./comerge-pb-src-results-"$timestamp
MAKE_LOG=$RESULTS_DIR"/pb-make-"$hostname"-"$timestamp".log"
DRAM0_FILE=$RESULTS_DIR"/pb-dram0-"$hostname"-"$timestamp".log"
DRAM1_FILE=$RESULTS_DIR"/pb-dram1-"$hostname"-"$timestamp".log"
PMEM4_FILE=$RESULTS_DIR"/pb-pmem4-"$hostname"-"$timestamp".log"
PMEM3_FILE=$RESULTS_DIR"/pb-pmem3-"$hostname"-"$timestamp".log"
PMEM4_POOL_DIR="/mnt/pmem4/fsgeek"
PMEM3_POOL_DIR="/mnt/pmem3/fsgeek"

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

# Partition the disk
umount /mnt/pmem4
umount /mnt/pmem3
parted -s -a optimal -- /dev/pmem4 mklabel gpt mkpart primary 2MiB -4096s >> $PMEM4_FILE 2>&1
mkfs.ext4 -b 4096 -E stride=512 -F /dev/pmem4p1 >> $PMEM4_FILE 2>&1
fdisk -l /dev/pmem4 >> $PMEM4_FILE 2>&1
parted -s -a optimal -- /dev/pmem3 mklabel gpt mkpart primary ext4 1MiB -4096s >> $PMEM3_FILE 2>&1
mkfs.ext4 -b 4096 -F /dev/pmem3p1 >> $PMEM3_FILE 2>&1
fdisk -l /dev/pmem3 >> $PMEM3_FILE 2>&1
mount -o dax /dev/pmem4p1 /mnt/pmem4
mount -o dax /dev/pmem3p1 /mnt/pmem3

[ ! -d $PMEM4_POOL_DIR ] && mkdir $PMEM4_POOL_DIR && echo "mkdir $PMEM4_POOL_DIR"
[ ! -d $PMEM3_POOL_DIR ] && mkdir $PMEM3_POOL_DIR && echo "mkdir $PMEM3_POOL_DIR"


## Run all benchmarks
for b in $BENCH
do
    echo "Start $b"
    echo $b >> $PMEM4_FILE
    hwloc-bind --single node:$node_pmem4 --verbose -- perf stat -B -d -d -d ./wrapper-comerge.sh $PMEM4_POOL_DIR $VMMALLOC_POOL_SIZE $b $PMEM4_FILE >> $PMEM4_FILE 2>&1
    echo finished >> $PMEM4_FILE
    echo $b >> $PMEM3_FILE
    hwloc-bind --single node:$node_pmem3 --verbose -- perf stat -B -d -d -d ./wrapper-comerge.sh $PMEM3_POOL_DIR $VMMALLOC_POOL_SIZE $b $PMEM3_FILE >> $PMEM3_FILE 2>&1
    echo finished >> $PMEM3_FILE
    # echo $b >> $DRAM0_FILE
    # hwloc-bind --single node:0  --verbose -- perf stat -B -d -d -d $b >>$DRAM0_FILE 2>&1
    # echo finished >> $DRAM0_FILE
    # echo $b >> $DRAM1_FILE
    # hwloc-bind --single node:1 --verbose -- perf stat -B -d -d -d $b >>$DRAM1_FILE 2>&1
    # echo finished >> $DRAM1_FILE
    echo "End $b"
done


