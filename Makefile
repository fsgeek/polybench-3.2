all: atax 2mm 3mm bicg cholesky doitgen gemm gemver gesummv mvt symm syr2k syrk trisolv trmm durbin dynprog gramschmidt lu ludcmp correlation covariance floyd-warshall reg_detect adi fdtd-2d fdtd-apml jacobi-1d-imper jacobi-2d-imper seidel-2d

LIB = #utilities/lib_my_malloc.a -lnuma

#They are all passed as macro definitions during compilation time (e.g,
#-Dname_of_the_option).
#
#- POLYBENCH_TIME: output execution time (gettimeofday) [default: off]
#
#- POLYBENCH_NO_FLUSH_CACHE: don't flush the cache before calling the
#  timer [default: flush the cache]
#
#- POLYBENCH_LINUX_FIFO_SCHEDULER: use FIFO real-time scheduler for the
#  kernel execution, the program must be run as root, under linux only,
#  and compiled with -lc [default: off]
#
#- POLYBENCH_CACHE_SIZE_KB: cache size to flush, in kB [default: 33MB]
#
#- POLYBENCH_STACK_ARRAYS: use stack allocation instead of malloc [default: off]
#
#- POLYBENCH_DUMP_ARRAYS: dump all live-out arrays on stderr [default: off]
#
#- POLYBENCH_CYCLE_ACCURATE_TIMER: Use Time Stamp Counter to monitor
#  the execution time of the kernel [default: off]
#
#- POLYBENCH_PAPI: turn on papi timing (see below).
#
#- MINI_DATASET, SMALL_DATASET, STANDARD_DATASET, LARGE_DATASET,
#  EXTRALARGE_DATASET: set the dataset size to be used
#  [default: STANDARD_DATASET]
#
#- POLYBENCH_USE_C99_PROTO: Use standard C99 prototype for the functions.
#
#- POLYBENCH_USE_SCALAR_LB: Use scalar loop bounds instead of parametric ones.

#CFLAGS=-ggdb -O0
#CFLAGS=-O3 -DPOLYBENCH_TIME -DPOLYBENCH_LINUX_FIFO_SCHEDULER -DPOLYBENCH_CYCLE_ACCURATE_TIMER -DEXTRALARGE_DATASET 
#CFLAGS=-O3 -DPOLYBENCH_TIME -DPOLYBENCH_LINUX_FIFO_SCHEDULER -DPOLYBENCH_CYCLE_ACCURATE_TIMER -DMINI_DATASET
#CFLAGS=-O3 -DPOLYBENCH_TIME -DPOLYBENCH_LINUX_FIFO_SCHEDULER -DMINI_DATASET
CFLAGS=-O3 -ggdb -DPOLYBENCH_TIME -DPOLYBENCH_LINUX_FIFO_SCHEDULER -DPOLYBENCH_CYCLE_ACCURATE_TIMER -DLARGE_DATASET 


atax:
	gcc ${CFLAGS} -I utilities -I linear-algebra/kernels/atax utilities/polybench.c linear-algebra/kernels/atax/atax.c  $(LIB) -o linear-algebra/kernels/atax/atax_time

2mm:
	gcc ${CFLAGS} -I utilities -I linear-algebra/kernels/2mm utilities/polybench.c linear-algebra/kernels/2mm/2mm.c  $(LIB) -o linear-algebra/kernels/2mm/2mm_time

3mm:
	gcc ${CFLAGS} -I utilities -I linear-algebra/kernels/3mm utilities/polybench.c linear-algebra/kernels/3mm/3mm.c  -o linear-algebra/kernels/3mm/3mm_time

bicg:
	gcc ${CFLAGS} -I utilities -I linear-algebra/kernels/bicg utilities/polybench.c linear-algebra/kernels/bicg/bicg.c  $(LIB) -o linear-algebra/kernels/bicg/bicg_time

cholesky:
	gcc ${CFLAGS} -I utilities -I linear-algebra/kernels/cholesky utilities/polybench.c linear-algebra/kernels/cholesky/cholesky.c  -o linear-algebra/kernels/cholesky/cholesky_time -lm

doitgen:
	gcc ${CFLAGS} -I utilities -I linear-algebra/kernels/doitgen utilities/polybench.c linear-algebra/kernels/doitgen/doitgen.c  $(LIB) -o linear-algebra/kernels/doitgen/doitgen_time 

gemm:
	gcc ${CFLAGS} -I utilities -I linear-algebra/kernels/gemm utilities/polybench.c linear-algebra/kernels/gemm/gemm.c  -o linear-algebra/kernels/gemm/gemm_time 

gemver:
	gcc ${CFLAGS} -I utilities -I linear-algebra/kernels/gemver utilities/polybench.c linear-algebra/kernels/gemver/gemver.c  -o linear-algebra/kernels/gemver/gemver_time 

gesummv:
	gcc ${CFLAGS} -I utilities -I linear-algebra/kernels/gesummv utilities/polybench.c linear-algebra/kernels/gesummv/gesummv.c  -o linear-algebra/kernels/gesummv/gesummv_time 

mvt:
	gcc ${CFLAGS} -I utilities -I linear-algebra/kernels/mvt utilities/polybench.c linear-algebra/kernels/mvt/mvt.c  -o linear-algebra/kernels/mvt/mvt_time 

symm:
	gcc ${CFLAGS} -I utilities -I linear-algebra/kernels/symm utilities/polybench.c linear-algebra/kernels/symm/symm.c  -o linear-algebra/kernels/symm/symm_time 

syr2k:
	gcc ${CFLAGS} -I utilities -I linear-algebra/kernels/syr2k utilities/polybench.c linear-algebra/kernels/syr2k/syr2k.c  -o linear-algebra/kernels/syr2k/syr2k_time 

syrk:
	gcc ${CFLAGS} -I utilities -I linear-algebra/kernels/syrk utilities/polybench.c linear-algebra/kernels/syrk/syrk.c  -o linear-algebra/kernels/syrk/syrk_time 

trisolv:
	gcc ${CFLAGS} -I utilities -I linear-algebra/kernels/trisolv utilities/polybench.c linear-algebra/kernels/trisolv/trisolv.c  $(LIB) -o linear-algebra/kernels/trisolv/trisolv_time 

trmm:
	gcc ${CFLAGS} -I utilities -I linear-algebra/kernels/trmm utilities/polybench.c linear-algebra/kernels/trmm/trmm.c  $(LIB) -o linear-algebra/kernels/trmm/trmm_time 

durbin:
	gcc ${CFLAGS} -I utilities -I linear-algebra/solvers/durbin utilities/polybench.c linear-algebra/solvers/durbin/durbin.c  -o linear-algebra/solvers/durbin/durbin_time 

dynprog:
	gcc ${CFLAGS} -I utilities -I linear-algebra/solvers/dynprog utilities/polybench.c linear-algebra/solvers/dynprog/dynprog.c  -o linear-algebra/solvers/dynprog/dynprog_time 

gramschmidt:
	gcc ${CFLAGS} -I utilities -I linear-algebra/solvers/gramschmidt utilities/polybench.c linear-algebra/solvers/gramschmidt/gramschmidt.c  -o linear-algebra/solvers/gramschmidt/gramschmidt_time -lm

lu:
	gcc ${CFLAGS} -I utilities -I linear-algebra/solvers/lu utilities/polybench.c linear-algebra/solvers/lu/lu.c  -o linear-algebra/solvers/lu/lu_time 

ludcmp:
	gcc ${CFLAGS} -I utilities -I linear-algebra/solvers/ludcmp utilities/polybench.c linear-algebra/solvers/ludcmp/ludcmp.c  $(LIB) -o linear-algebra/solvers/ludcmp/ludcmp_time 

correlation:
	gcc ${CFLAGS} -I utilities -I datamining/correlation utilities/polybench.c datamining/correlation/correlation.c  -o datamining/correlation/correlation_time -lm

covariance:
	gcc ${CFLAGS} -I utilities -I datamining/covariance utilities/polybench.c datamining/covariance/covariance.c -o datamining/covariance/covariance_time 

floyd-warshall:
	gcc ${CFLAGS} -I utilities -I medley/floyd-warshall utilities/polybench.c medley/floyd-warshall/floyd-warshall.c  -o medley/floyd-warshall/floyd-warshall_time

reg_detect:
	gcc ${CFLAGS} -I utilities -I medley/reg_detect utilities/polybench.c medley/reg_detect/reg_detect.c  -o medley/reg_detect/reg_detect_time

adi:
	gcc ${CFLAGS} -I utilities -I stencils/adi utilities/polybench.c stencils/adi/adi.c  $(LIB) -o stencils/adi/adi_time

fdtd-2d:
	gcc ${CFLAGS} -I utilities -I stencils/fdtd-2d utilities/polybench.c stencils/fdtd-2d/fdtd-2d.c  $(LIB) -o stencils/fdtd-2d/fdtd-2d_time

fdtd-apml:
	gcc ${CFLAGS} -I utilities -I stencils/fdtd-apml utilities/polybench.c stencils/fdtd-apml/fdtd-apml.c  -o stencils/fdtd-apml/fdtd-apml_time

jacobi-1d-imper:
	gcc ${CFLAGS} -I utilities -I stencils/jacobi-1d-imper utilities/polybench.c stencils/jacobi-1d-imper/jacobi-1d-imper.c  -o stencils/jacobi-1d-imper/jacobi-1d-imper_time

jacobi-2d-imper:
	gcc ${CFLAGS} -I utilities -I stencils/jacobi-2d-imper utilities/polybench.c stencils/jacobi-2d-imper/jacobi-2d-imper.c  $(LIB) -o stencils/jacobi-2d-imper/jacobi-2d-imper_time

seidel-2d:
	gcc ${CFLAGS} -I utilities -I stencils/seidel-2d utilities/polybench.c stencils/seidel-2d/seidel-2d.c  -o stencils/seidel-2d/seidel-2d_time

clean:
	rm linear-algebra/kernels/atax/atax_time
	rm linear-algebra/kernels/2mm/2mm_time
	rm linear-algebra/kernels/3mm/3mm_time
	rm linear-algebra/kernels/bicg/bicg_time
	rm linear-algebra/kernels/cholesky/cholesky_time
	rm linear-algebra/kernels/doitgen/doitgen_time 
	rm linear-algebra/kernels/gemm/gemm_time 
	rm linear-algebra/kernels/gemver/gemver_time 
	rm linear-algebra/kernels/gesummv/gesummv_time 
	rm linear-algebra/kernels/mvt/mvt_time 
	rm linear-algebra/kernels/symm/symm_time 
	rm linear-algebra/kernels/syr2k/syr2k_time 
	rm linear-algebra/kernels/syrk/syrk_time 
	rm linear-algebra/kernels/trisolv/trisolv_time 
	rm linear-algebra/kernels/trmm/trmm_time 
	rm linear-algebra/solvers/durbin/durbin_time 
	rm linear-algebra/solvers/dynprog/dynprog_time 
	rm linear-algebra/solvers/gramschmidt/gramschmidt_time
	rm linear-algebra/solvers/lu/lu_time 
	rm linear-algebra/solvers/ludcmp/ludcmp_time 
	rm datamining/correlation/correlation_time
	rm datamining/covariance/covariance_time 
	rm medley/floyd-warshall/floyd-warshall_time
	rm medley/reg_detect/reg_detect_time
	rm stencils/adi/adi_time
	rm stencils/fdtd-2d/fdtd-2d_time
	rm stencils/fdtd-apml/fdtd-apml_time
	rm stencils/jacobi-1d-imper/jacobi-1d-imper_time
	rm stencils/jacobi-2d-imper/jacobi-2d-imper_time
	rm stencils/seidel-2d/seidel-2d_time

