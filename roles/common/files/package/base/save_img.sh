#!/bin/bash

for IMG in `docker image ls | awk 'NR>1{print $1":"$2}'`
do
    FILE=`echo $IMG | sed 's/\//-/g' | sed 's/\:/-/g'`
    docker save $IMG > $FILE".tar"
done
