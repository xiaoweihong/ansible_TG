#!/bin/bash


while true
do
    read -p "请输入ssh端口(服务器默认为22，如果没有修改可以回车跳过不用填写): " ansible_ssh_port
  if [ ! -n "$ansible_ssh_port" ];then
      ansible_ssh_port=22
      break
  fi
  if [ ! -n "$ansible_ssh_port" ]||[ -n "`echo $ansible_ssh_port | sed 's/[0-9]//g'`" ]||[ $ansible_ssh_port -le 0 ];then
      continue
    else
      ansible_ssh_port=${ansible_ssh_port}
    fi
break
done

grep "ansible_ssh_port" $SHELL_DIR/ansible/group_vars/all.yml >/dev/null 2>/dev/null || echo "ansible_ssh_port: ${ansible_ssh_port}" >> $SHELL_DIR/ansible/group_vars/all.yml
#grep "ansible_ssh_port" $SHELL_DIR/ansible/group_vars/all.yml >/dev/null 2>/dev/null || { echo "ansible_ssh_port: ${ansible_ssh_port}" >> $SHELL_DIR/ansible/group_vars/all.yml }
echo "SSH端口号为: "$ansible_ssh_port
sed -i "s/ansible_ssh_port:\( .*\)/ansible_ssh_port: $ansible_ssh_port/g" $SHELL_DIR/ansible/group_vars/all.yml
