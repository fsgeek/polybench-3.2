#!/bin/sh
make -f Makefile.comerge gramschmidt fdtd-2d
rm ~/gs-access.txt
touch ~/gs-access.txt
chattr +c ~/gs-access.txt
linear-algebra/solvers/gramschmidt/gramschmidt_time >> ~/gs-access.txt &
rm ~/fdtd2d-access.txt
touch ~/fdtd2d-access.txt
chattr +c ~/fdtd2d-access.txt
stencils/fdtd-2d/fdtd-2d_time >> ~/fdtd2d-access.txt &

