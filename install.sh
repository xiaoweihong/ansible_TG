#!/bin/bash

function checkAnsible(){
  ansible --version >/dev/null 2>&1
  if [ $? -ne 0 ];then
    echo "ansible not installed,begin install ansible" 
    tar zcvf roles/common/files/package/software_package.tgz -C /opt/
    cp roles/common/files/conf/apt/sources.list_local /etc/apt/sources.list
    cp roles/common/files/conf/apt/02allow-unsigned /etc/apt/apt.conf.d/
    apt-get update
    apt-get install ansible
    echo "install completed"
  fi

}

checkAnsible

ansible-playbook playbook/00-installTG.yml
