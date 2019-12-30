#!/bin/bash

if [ `whoami` != "root" ]; then
    echo "You Must Be Root"
    exit 1
fi

WORK_DIR="/opt/bigtoe"
TOOLS="$WORK_DIR/bigtoe-tools"

if [[ $1 != "--skip-fse" ]]; then
    $WORK_DIR/fse-tools.sh init-dir
    if [ $? != 0 ]; then
        echo -e "\033[31m\033[1m\033[5m校验失败。如果不需要特征搜索引擎，安装时增加--skip-fse参数，如./install_web.sh --skip-fse\033[0m"
        exit 1
    fi
fi

mount -fav
if [ $? != 0 ]; then
    echo -e "\033[31m\033[1m\033[5mfstab校验失败，请检查/etc/fstab文件！\033[0m"
    exit 1;
fi

#$WORK_DIR/check_system.sh
#if [ $? != 0 ];then
#    echo -e "\033[31m\033[1m\033[5m系统检测不通过！\033[0m"
#    exit 1;
#fi

$TOOLS install web
