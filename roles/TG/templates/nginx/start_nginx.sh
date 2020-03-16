#!/bin/bash
NAME="nginx"
CID=$(docker ps | awk '{if($NF=="'${NAME}'")print $1}')
if [[ $CID"x" != "x" ]];then
    docker rm --force $CID
fi

docker run -d --restart always \
--network host \
-v /var/www:/var/www \
-v /home/{{ansible_user}}/platformTG/jormougand/latest:/home/{{ansible_user}}/platformTG/jormougand/latest \
-v /etc/nginx/conf.d:/etc/nginx/conf.d \
-v /etc/nginx/nginx.conf:/etc/nginx/nginx.conf \
-v /platformData:/platformData \
-v /data/bigtoe:/data/bigtoe \
-v /etc/localtime:/etc/localtime \
--name $NAME \
nginx:1.17.3
