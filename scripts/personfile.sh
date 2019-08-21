#!/bin/bash

while true
do
    read -p "请输入是否需要人员档案(y/n): " Confirm
  if [ ! -n "$Confirm" ];then
      continue
  fi
case $Confirm in
  [yY][eE][sS]|[yY])
   personfile=true
   break
  ;;
  [nN][oO]|[nN])
   personfile=false
   break
  ;;
  *)
    echo "请输入y或者n"
  ;;
esac
done
