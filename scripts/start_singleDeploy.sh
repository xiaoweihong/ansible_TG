#!/bin/bash
> config.ini
while true
do
  echo "请输入引擎服务器节点ip(请勿输入主节点ip):"
  read  bigtoeIP
    if [ ! -n "${bigtoeIP}" ];then
      continue
    else
      echo "bigtoeIP='$bigtoeIP'" >> ./config.ini
    fi
      break
done

clear

echo -e "\033[34;32;1m 生成配置文件完毕，当前路径下 config.ini \033[0m"
sleep 1
echo -e "\033[34;32;1m config.ini 预览 \033[0m"
sleep 1
echo "------------------------------------------------------"
cat ./config.ini
