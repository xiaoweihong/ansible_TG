#!/bin/bash

if [ `whoami` != "root" ]; then
    echo "You Must Be Root"
    exit 1
fi

WORK_DIR="/opt/bigtoe"
TOOLS="$WORK_DIR/bigtoe-tools"

source $WORK_DIR/bin/functions

# 检查系统是否满足需求。
#$WORK_DIR/check_system.sh
#if [[ $? != 0 ]];then
#    echo -e "\033[31m\033[1m\033[5m系统检测不通过！\033[0m"
#    exit 1
#fi
#
## 校验fse。
#if [[ $1 != "--skip-fse" ]]; then
#    $WORK_DIR/fse-tools.sh init-dir
#    if [ $? != 0 ]; then
#        echo -e "\033[31m\033[1m\033[5m校验失败。如果不需要特征搜索引擎，安装时增加--skip-fse参数，如./install_web.sh --skip-fse\033[0m"
#        exit 1
#    fi
#fi

$TOOLS install system-dependence

# 安装完Nvidia驱动之后，再检查一次。
if check_gpu_exists; then
    $WORK_DIR/check_system.sh --check-gpu-only
    if [[ $? != 0 ]];then
        echo -e "\033[31m\033[1m\033[5m系统检测不通过！\033[0m"
        exit 1
    fi
fi

# 检查华为D卡驱动。
if check_npu_exists; then
    $WORK_DIR/check_system.sh --check-npu-only
    if [[ $? != 0 ]];then
        echo -e "\033[31m\033[1m\033[5m系统检测不通过！\033[0m"
        exit 1
    fi

fi
$TOOLS install web
