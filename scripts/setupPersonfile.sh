#!/bin/bash
./start_personfilesetup.sh
echo -e "\033[41;32;1m 请确认上述信息是否正确，正确请输入 y 继续下一步安装; 输入 n 将重新配置IP; 退出请输入 q \033[0m"
while true
do
read is_ok

case "$is_ok" in
   y|Y)
     ./nodeConfig.sh
     exit 0
  ;;
  n|N)
     ./start_personfilesetup.sh
  ;;
  q|Q)
     exit 10
  ;;
  *)
    echo -e "\033[41;32;1m 请确认上述信息是否正确，正确请输入 y 继续下一步安装; 输入 n 将重新配置IP；退出请输入 q \033[0m"
  ;;
esac
done
