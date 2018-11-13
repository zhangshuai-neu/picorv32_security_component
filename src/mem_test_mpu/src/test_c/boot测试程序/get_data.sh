#! /bin/bash

line_num=`wc -l boot.asm |cut -d' ' -f1`
let data_line_num=line_num-7
tail boot.asm -n$data_line_num |cut -b 7-15 >boot.data

cut boot.data -b 1-2 >boot1.data
cut boot.data -b 3-4 >boot2.data
cut boot.data -b 5-6 >boot3.data
cut boot.data -b 7-8 >boot4.data
