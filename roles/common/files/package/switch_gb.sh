#!/bin/bash

if [ `whoami` != "root" ]; then
    echo "You Must Be Root"
    exit 1
fi

USE_GB="$1"
if [[ $USE_GB == "" || $USE_GB == "0" ]];then
    sed -i "s/^\$port_template$/\$port_template_bak/g" /opt/bigtoe/pkg/k8s-conf/deepengine/vse/generate.php
    rm -rf /etc/bigtoe/flags/use_gb
else
    sed -i "s/^\$port_template_bak$/\$port_template/g" /opt/bigtoe/pkg/k8s-conf/deepengine/vse/generate.php
    touch /etc/bigtoe/flags/use_gb
fi

kubectl delete ns vse
/opt/bigtoe/bigtoe-tools deploy deepengine-vse
