#/bin/sh

export PATH=~tony/projects/polly/llvm_build/bin:$PATH

VMMALLOC_POOL_SIZE=$((5*1024*1024*1024))

#LD_PRELOAD=libvmmalloc.so.1 grep "pmem" /proc/mounts
node_pmem6=1
timestamp=`date '+%Y_%m_%d__%H_%M_%S'`;
hostname=`hostname`

# log files
RESULTS_DIR="./comerge-pb-poly-results-"$timestamp
MAKE_LOG=$RESULTS_DIR"/pb-make-"$hostname"-"$timestamp".log"
PMEM64K_FILE=$RESULTS_DIR"/pb-pmem64K-"$hostname"-"$timestamp".log"
PMEM62M_FILE=$RESULTS_DIR"/pb-pmem62M-"$hostname"-"$timestamp".log"

PMEM64K_POOL_DIR="/mnt/pmem6/fsgeek"
PMEM62M_POOL_DIR="/mnt/pmem6/fsgeek"

BENCH="
./linear-algebra/kernels/2mm/2mm_time
./linear-algebra/kernels/2mm/2mm_poly_time
./linear-algebra/kernels/3mm/3mm_time
./linear-algebra/kernels/3mm/3mm_poly_time
./linear-algebra/kernels/atax/atax_time
./linear-algebra/kernels/atax/atax_poly_time
./linear-algebra/kernels/bicg/bicg_time
./linear-algebra/kernels/bicg/bicg_poly_time
./linear-algebra/kernels/cholesky/cholesky_time
./linear-algebra/kernels/cholesky/cholesky_poly_time
./linear-algebra/kernels/doitgen/doitgen_time
./linear-algebra/kernels/doitgen/doitgen_poly_time
./linear-algebra/kernels/gemm/gemm_time
./linear-algebra/kernels/gemm/gemm_poly_time
./linear-algebra/kernels/gemver/gemver_time
./linear-algebra/kernels/gemver/gemver_poly_time
./linear-algebra/kernels/gesummv/gesummv_time
./linear-algebra/kernels/gesummv/gesummv_poly_time
./linear-algebra/kernels/mvt/mvt_time 
./linear-algebra/kernels/mvt/mvt_poly_time 
./linear-algebra/kernels/symm/symm_time
./linear-algebra/kernels/symm/symm_poly_time
./linear-algebra/kernels/syr2k/syr2k_time
./linear-algebra/kernels/syr2k/syr2k_poly_time
./linear-algebra/kernels/syrk/syrk_time
./linear-algebra/kernels/syrk/syrk_poly_time
./linear-algebra/kernels/trisolv/trisolv_time
./linear-algebra/kernels/trisolv/trisolv_poly_time
./linear-algebra/kernels/trmm/trmm_time
./linear-algebra/kernels/trmm/trmm_poly_time
./linear-algebra/solvers/durbin/durbin_time
./linear-algebra/solvers/durbin/durbin_poly_time
./linear-algebra/solvers/dynprog/dynprog_time
./linear-algebra/solvers/dynprog/dynprog_poly_time
./linear-algebra/solvers/gramschmidt/gramschmidt_time
./linear-algebra/solvers/gramschmidt/gramschmidt_poly_time
./linear-algebra/solvers/lu/lu_time
./linear-algebra/solvers/lu/lu_poly_time
./linear-algebra/solvers/ludcmp/ludcmp_time
./linear-algebra/solvers/ludcmp/ludcmp_poly_time
./datamining/correlation/correlation_time
./datamining/correlation/correlation_poly_time
./datamining/covariance/covariance_time
./datamining/covariance/covariance_poly_time
./medley/floyd-warshall/floyd-warshall_time
./medley/floyd-warshall/floyd-warshall_poly_time
./medley/reg_detect/reg_detect_time
./medley/reg_detect/reg_detect_poly_time
./stencils/adi/adi_time
./stencils/adi/adi_poly_time
./stencils/fdtd-2d/fdtd-2d_time
./stencils/fdtd-2d/fdtd-2d_poly_time
./stencils/fdtd-apml/fdtd-apml_time
./stencils/fdtd-apml/fdtd-apml_poly_time
./stencils/jacobi-1d-imper/jacobi-1d-imper_time
./stencils/jacobi-1d-imper/jacobi-1d-imper_poly_time
./stencils/jacobi-2d-imper/jacobi-2d-imper_time
./stencils/jacobi-2d-imper/jacobi-2d-imper_poly_time
./stencils/seidel-2d/seidel-2d_time
./stencils/seidel-2d/seidel-2d_poly_time
"

[ ! -d $RESULTS_DIR ] && mkdir $RESULTS_DIR && echo "mkdir $RESULTS_DIR"

## Rebuild
#make -f Makefile-clang-comerge >> $MAKE_LOG 2>&1

# Partition the disk
umount /mnt/pmem6
parted -s -a optimal -- /dev/pmem6 mklabel gpt mkpart primary 2MiB -4096s >> $PMEM62M_FILE 2>&1
mkfs.ext4 -b 4096 -E stride=512 -F /dev/pmem6p1 >> $PMEM62M_FILE 2>&1
fdisk -l /dev/pmem6 >> $PMEM62M_FILE 2>&1
mount -o dax /dev/pmem6p1 /mnt/pmem6

[ ! -d $PMEM62M_POOL_DIR ] && mkdir $PMEM62M_POOL_DIR && echo "mkdir $PMEM62M_POOL_DIR"

# Make sure the huge tlb sizes are set up properly
#hugeadm --pool-list >> $DRAM2M_FILE 2>&1
#hugeadm --pool-pages-max 2MB:8192 >> $DRAM2M_FILE 2>&1

## Run all benchmarks
for b in $BENCH
do
    echo $b >> $PMEM62M_FILE
    hwloc-bind --single node:$node_pmem6 --verbose -- perf stat -B -d -d -d ./wrapper-comerge.sh $PMEM62M_POOL_DIR $VMMALLOC_POOL_SIZE $b $PMEM62M_FILE >> $PMEM62M_FILE 2>&1
    echo finished >> $PMEM62M_FILE
    echo "End $b"
done

# Now, do it again on pmem6 with 4KB pages
umount /mnt/pmem6
parted -s -a optimal -- /dev/pmem6 mklabel gpt mkpart primary ext4 1MiB -4096s >> $PMEM64K_FILE 2>&1
mkfs.ext4 -b 4096 -F /dev/pmem6p1 >> $PMEM64K_FILE 2>&1
fdisk -l /dev/pmem4 >> $PMEM64K_FILE 2>&1
mount -o dax /dev/pmem6p1 /mnt/pmem6

[ ! -d $PMEM64K_POOL_DIR ] && mkdir $PMEM64K_POOL_DIR && echo "mkdir $PMEM64K_POOL_DIR"

for b in $BENCH
do
    echo "Start $b"
    echo $b >> $PMEM64K_FILE
    hwloc-bind --single node:$node_pmem6 --verbose -- perf stat -B -d -d -d ./wrapper-comerge.sh $PMEM64K_POOL_DIR $VMMALLOC_POOL_SIZE $b $PMEM64K_FILE >> $PMEM64K_FILE 2>&1
    echo finished >> $PMEM64K_FILE
    echo "End $b"
done


