#!/usr/bin/env bash

i=0
cd
for line in `awk '{print $3}' /etc/passwd`; do
  arr[$i]=$line
  i=`expr $i + 1`
done


echo ${#arr[@]}