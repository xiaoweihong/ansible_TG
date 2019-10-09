#!/bin/bash
> config.ini

while true
do
  echo "集群内机器数量(包括所有节点):"
  read machineNum
  if [ ! -n "$machineNum" ] || [ -n "`echo $machineNum| sed 's/[0-9]//g'`" ] ;then
      echo "请输入正确的整数数字"
      continue
  fi
  if [ $machineNum -lt 2 ];then
    echo "集群功能需要至少2台机器,请确认配置"
    continue
  fi

  if [ ! -n "$machineNum" ]||[ -n "`echo $machineNum| sed 's/[0-9]//g'`" ]||[ $machineNum -le 0 ];then
    continue
  else
    machineNum=${machineNum}
  fi

      break
done


while true
do
  echo "请输入从数据库节点ip:"
  read  postgresNode
    if [ ! -n "$postgresNode" ];then
      continue
    else
      echo "postgresNode='$postgresNode'" >> ./config.ini
    fi
      break
done

if [[ $machineNum -gt 2 ]];then
while true
do
  echo "请输入node节点ip(不包括主节点ip和数据库从节点ip，多台服务器之间以空格分割):"
  read nodeip
    if [ ! -n "$nodeip" ];then
      continue
    else
      echo "nodes='$nodeip'" >> ./config.ini
    fi
      break
done
fi

clear

echo -e "\033[34;32;1m 生成配置文件完毕，当前路径下 config.ini \033[0m"
sleep 1
echo -e "\033[34;32;1m config.ini 预览 \033[0m"
sleep 1
echo "------------------------------------------------------"
cat ./config.ini
