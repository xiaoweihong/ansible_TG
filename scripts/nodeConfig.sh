#!/bin/bash

>hosts
source config.ini
masterIP=`hostname -I | cut -f1 -d' '`
echo -n "[master]
" >> hosts
echo $masterIP>> hosts
echo "" >> hosts
echo -n "[personalFileNode]
" >> hosts
echo $personalFileNode>> hosts
echo "" >> hosts
echo -n "[postgresNode]
" >> hosts
echo $postgresNode >> hosts
echo "" >> hosts
echo -n "[node]
" >> hosts
for ip in ${nodes[*]}
do
 echo $ip >> hosts
done
