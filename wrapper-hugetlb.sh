#!/bin/sh

#echo LD_PRELOAD=libhugetlbfs.so HUGETLB_MORECORE=yes $1 >> $2
LD_PRELOAD=libhugetlbfs.so HUGETLB_MORECORE=yes $1 >> $2 2>&1

