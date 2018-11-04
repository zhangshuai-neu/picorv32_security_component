#! /bin/bash

line_num=`wc -l boot.asm |cut -d' ' -f1`
let data_line_num=line_num-7
tail boot.asm -n$data_line_num |cut -b 7-15 >boot.data
