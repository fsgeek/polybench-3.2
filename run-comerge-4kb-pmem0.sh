#/bin/sh

# May 6, 2021
# Testing with a kernel that does not support 2MB PMEM pages at all on AEP01.

VMMALLOC_POOL_SIZE=$((5*1024*1024*1024))
#export VMMALLOC_POOL_DIR="/mnt/pmem7/fsgeek"

#LD_PRELOAD=libvmmalloc.so.1 grep "pmem" /proc/mounts
node_pmem0=0
timestamp=`date '+%Y_%m_%d__%H_%M_%S'`;
hostname=`hostname`

# log files
RESULTS_DIR="./comerge-pb-4kb-results-"$timestamp
MAKE_LOG=$RESULTS_DIR"/pb-make-"$hostname"-"$timestamp".log"
DRAM0_FILE=$RESULTS_DIR"/pb-dram0-"$hostname"-"$timestamp".log"
PMEM0_FILE=$RESULTS_DIR"/pb-pmem0-"$hostname"-"$timestamp".log"
PMEM0_POOL_DIR="/mnt/pmem0/fsgeek"

# create results directory
[ ! -d $RESULTS_DIR ] && mkdir $RESULTS_DIR && echo "mkdir $RESULTS_DIR"

# record kernel
uname -a >> $PMEM0_FILE

# partition the disk - this aligns to the 2MB boundary
echo umount /mnt/pmem0 >> $PMEM0_FILE
umount /mnt/pmem0 >> $PMEM0_FILE 2>&1
echo parted -s -a optimal -- /dev/pmem0 mklabel gpt mkpart primary ext4 1MiB -4096s >> $PMEM0_FILE
parted -s -a optimal -- /dev/pmem0 mklabel gpt mkpart primary ext4 1MiB -4096s >> $PMEM0_FILE
echo mkfs.ext4 -b 4096 -E stride=512 -F /dev/pmem0p1 >> $PMEM0_FILE
mkfs.ext4 -b 4096 -E stride=512 -F /dev/pmem0p1 >> $PMEM0_FILE 2>&1
echo fdisk -l /dev/pmem0 >> $PMEM0_FILE
fdisk -l /dev/pmem0 >> $PMEM0_FILE 2>&1
echo mount -o dax /dev/pmem0p1 /mnt/pmem0 >> $PMEM0_FILE
mount -o dax /dev/pmem0p1 /mnt/pmem0 >> PMEM0_FILE 2>&1

# make sure the working directories exist
[ ! -d $PMEM0_POOL_DIR ] && mkdir $PMEM0_POOL_DIR && echo "mkdir $PMEM0_POOL_DIR"

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
make -f Makefile.comerge >> $MAKE_LOG 2>&1



## Run all benchmarks
for b in $BENCH
do
    echo "Start $b"
    echo $b >> $PMEM0_FILE
    hwloc-bind --single node:$node_pmem0 -- perf stat -B -d -d -d ./wrapper-comerge.sh $PMEM0_POOL_DIR $VMMALLOC_POOL_SIZE $b $PMEM0_FILE >> $PMEM0_FILE 2>&1
    echo finished >> $PMEM0_FILE
    echo $b >> $DRAM0_FILE
    hwloc-bind --single node:0 -- perf stat -B -d -d -d $b >>$DRAM0_FILE 2>&1
    echo finished >> $DRAM0_FILE
    echo "End $b"
done


