#!/bin/bash

>hosts
source config.ini
masterIP=`hostname -I | cut -f1 -d' '`
echo -n "[master]
" >> hosts
echo $masterIP>> hosts
echo "" >> hosts
echo -n "[node]
" >> hosts
for ip in ${nodes[*]}
do
 echo $ip >> hosts
done
echo "" >> hosts
echo -n "[bigtoe]
" >> hosts
echo $masterIP>> hosts
#####
echo "" >> hosts
echo -n "[redis]
" >> hosts
echo $masterIP>> hosts
#####
echo "" >> hosts
echo -n "[kafka]
" >> hosts
echo $masterIP>> hosts
#####
echo "" >> hosts
echo -n "[db]
" >> hosts
echo $masterIP>> hosts
#####
echo "" >> hosts
echo -n "[flink]
" >> hosts
echo $masterIP>> hosts
#####
echo "" >> hosts
echo -n "[all:vars]
" >> hosts
echo "port=32400">> hosts
