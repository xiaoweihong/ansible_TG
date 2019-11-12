#!/bin/bash

Color_Text()
{
  echo -e " \e[0;$2m$1\e[0m"
}

Echo_Red()
{
  echo $(Color_Text "$1" "31")
}

Echo_Green()
{
  echo $(Color_Text "$1" "32")
}

Echo_Yellow()
{
  echo $(Color_Text "$1" "33")
}

Echo_Blue()
{
  echo $(Color_Text "$1" "34")
}

Echo_Red "开始进行修改ip，修改ip前，请确保已经修改过/etc/ansible/hosts里的对应ip。已经修改请输入 y 进行修改IP操作;输入 n 将退出操作"
while true
do
read is_ok

case "$is_ok" in
   y|Y)
     ansible-playbook playbook/01-changeip.yml
     exit 0
  ;;
  n|N)
     exit 0
  ;;
  q|Q)
     exit 10
  ;;
  *)
     Echo_Red "开始进行修改ip，修改ip前，请确保已经修改过/etc/ansible/hosts里的对应ip。已经修改请输入 y 进行修改IP操作;输入 n 将退出操作"
  ;;
esac
done
