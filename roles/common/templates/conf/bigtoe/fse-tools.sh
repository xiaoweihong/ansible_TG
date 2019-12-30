#!/bin/bash

if [[ `whoami` != "root" ]]; then
    echo "You Must Be Root"
    exit 1
fi

usage(){
    echo ""
    echo "Usage: ./fse-tools COMMAND ARGS"
    echo ""
    echo "Commands:"
    echo "    init-dir (e.g. ./fse-tools.sh init-dir)"
    echo "    update (e.g. ./fse-tools.sh update dockerhub.deepglint.com/atlas/fse:3.5.0)"
    echo "    coredump (e.g. ./fse-tools.sh coredump fse-api on || ./fse-tools.sh coredump fse-node off)"
}

log_error() {
    echo -e "\033[31m\033[1m\033[5m$1 \033[0m"
}

main() {
    case $1 in
        init-dir)
            echo "开始检查并初始化fse存储目录"
            if [ ! -d /fse-ssd ]; then
                log_error "请先挂载ssd硬盘至/fse-ssd目录"
                exit 1
            fi
            if [ ! -d /fse-sata ]; then
                log_error "请先挂载sata硬盘至/fse-sata目录"
                exit 1
            fi

    #        read -p "请确保/fse-ssd已经挂载至额外ssd硬盘，/fse-sata已经挂载至额外的sata硬盘，否则系统可能无法长时间正常运行！确认没有问题请输入yes继续操作，输入no退出本次操作: " check
    #        if [[ ! $check == "yes" ]]; then
    #            log_error "请挂载好目录再次执行，本次操作退出"
    #            exit 1
    #        fi

            for i in {0..31}
            do
                for type in "cpu" "gpu"
                do
                    mkdir -p  /fse-ssd/fse-$type-$i
                    mkdir -p  /fse-sata/fse-$type-$i
                done
            done
            echo "完成"
            ;;
        update)
            echo "开始更新fse版本"
            if [[ ! $2 ]]; then
                log_error "请输入fse的镜像名称，如dockerhub.deepglint.com/atlas/fse:3.5.0"
                exit 1
            fi
            for i in {0..31}
            do
                for type in "cpu" "gpu"
                do
                    kubectl set image deployment/fse-$type-$i fse-$type-$i=$2 -n fse
                done
            done
            kubectl set image deployment/fseapi fseapi=$2 -n fse
            echo "完成，请等待新版本fse启动"
            ;;
        coredump)
            if [[ $2 == "fse-node" ]]; then
                if [[ $3 == "on" ]]; then
                    kubectl get pods -n fse -l app=fse | awk  'NR>1 {print $1}' | xargs -I{} kubectl label pod {} -n fse coredump=on
                    echo "开启成功。下次应用挂掉后请至对应的/fse-sata/fse-cpu-i/cores/目录下查看coredump文件。请记得之后关闭coredump"
                elif [[ $3 == "off" ]]; then
                    kubectl get pods -n fse -l app=fse | awk  'NR>1 {print $1}' | xargs -I{} kubectl label pod {} -n fse coredump-
                    echo "关闭成功。拿到需要的coredump后请删除其他无用的coredump文件减少不必要的磁盘占用"
                else
                    log_error "合法开启参数应当为on/off，比如 ./fsetools.sh coredump fse-node on/off"
                fi
            elif [[ $2 == "fse-api" ]]; then
                if [[ $3 == "on" ]]; then
                    kubectl get pods -n fse -l app=fseapi | awk  'NR>1 {print $1}' | xargs -I{} kubectl label pod {} -n fse coredump=on
                    echo "开启成功。下次应用挂掉后请至对应的/data/bigtoe/fseapi/cores/目录下查看coredump文件。请记得之后关闭coredump"
                elif [[ $3 == "off" ]]; then
                    kubectl get pods -n fse -l app=fseapi | awk  'NR>1 {print $1}' | xargs -I{} kubectl label pod {} -n fse coredump-
                    echo "关闭成功。拿到需要的coredump后请删除其他无用的coredump文件减少不必要的磁盘占用"
                else
                    log_error "合法开启参数应当为on/off，比如 ./fsetools.sh coredump fse-node on/off"
                fi
            else
                log_error "非法参数，只支持fse-api或者fse-node，比如 ./fse-tools.sh coredump fse-node/fse-api on"
            fi
            ;;
        *)
            usage;
    esac
}

main $@
