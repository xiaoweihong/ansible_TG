#!/bin/bash

SHELL_DIR=$(cd $(dirname $0); pwd)
SHELL_LOG="${SHELL_DIR}/logs/install.log"
LOCK_FILE="/tmp/TG.lock"


if [[ $# -ne 2 || "$1" == "-h" || "$1" == "--help" ]]
then
  echo "Select a user with sudo permissions"
  echo "Usage: sudo bash `basename $0` USER PASSWORD"
  exit 1
fi

USER=$1
PASSWORD=$2
IPADDR=`hostname -I | cut -f1 -d' '`

#[[ $UID -eq 0 ]] || { echo "please sudo exec or exec by root" ; exit 1 ; }

if [[ $HOME != "/root" ]];then
  echo "please use sudo su - change root privilage"
  exit
fi

function lock(){
    touch ${LOCK_FILE}
}

function unlock(){
    rm -f ${LOCK_FILE}
}

function fatal_exit() {
    logging "Fatal Exit."
    unlock
    exit 1
}


function normal_exit() {
    logging "Normal Exit."
    unlock
    exit 0
}


function kill_exit() {
    logging "Receive Kill Signal."
    unlock
    exit 1
}

function logging(){
  if [[ ! -d ${SHELL_DIR}"/logs" ]];then
      mkdir -p ${SHELL_DIR}"/logs"
  fi
  LOG_INFO="[$(date "+%Y-%m-%d") $(date "+%H:%M:%S")] $1"
  echo ${LOG_INFO}
  echo ${LOG_INFO} >> ${SHELL_LOG}
}

function run() {
  $1 | tee -a $SHELL_LOG
  return ${PIPESTATUS[0]}
}

function checkAnsible(){
  ansible --version >/dev/null 2>&1
  return $?
}

function installAnsible(){
  tar zxvf ${SHELL_DIR}/software_package.tgz -C /opt/
  cp ${SHELL_DIR}/ansible/roles/common/files/conf/apt/sources.list_local /etc/apt/sources.list
  cp ${SHELL_DIR}/ansible/roles/common/files/conf/apt/02allow-unsigned /etc/apt/apt.conf.d/
  apt-get update
  apt-get -y install ansible
  if [ $? -ne 0 ];then
    echo "install error"
    exit 500
  fi
  mv /etc/ansible /etc/ansible_bak
  ln -s ${SHELL_DIR}/ansible /etc/ansible
}

function menu(){
echo "+-------------------------------------------------------------------+"
echo "|                     瞳镜平台部署                                  |"
echo "+-------------------------------------------------------------------+"
echo "|        A tool to auto-compile & install TG platform on Linux      |"
echo "+-------------------------------------------------------------------+"
echo "|           For more information please read document               |"
echo "+-------------------------------------------------------------------+"
echo "|                    1. 单机部署                                    |"
echo "+-------------------------------------------------------------------+"
echo "|                    2. 集群部署                                    |"
echo "+-------------------------------------------------------------------+"
echo "|                    q. 退出                                        |"
echo "+-------------------------------------------------------------------+"
echo "请选择:"
}

function singleDeploy(){

  if [ -d /etc/ansible ];then
    rm -f /etc/ansible
  else
    ln -s ${SHELL_DIR}/ansible /etc/ansible
  fi
. ansible/scripts/config_arcee.sh

  echo "[master]
${IPADDR}
" > /etc/ansible/hosts
  echo "---

ansible_become: yes
ansible_become_method: sudo
ansible_user: $USER
ansible_password: $PASSWORD
ansible_become_pass: $PASSWORD
platformPath: /platformData
ansible_host_ip: '{{ ansible_default_ipv4.address }}'
bigtoe_version: 4.0.1
fse_version: 3.5.1 
cluster: false
personfile: false" > /etc/ansible/group_vars/all.yml

    cd /etc/ansible
    ansible-playbook playbook/02-check.yml
    if [ $? -ne 0 ];then
         fatal_exit
    fi

    ansible-playbook playbook/00-installTG.yml
}

function clusterDeploy(){
  echo "cluster deploy"
. ansible/scripts/config_arcee.sh
. ansible/scripts/personfile.sh

  echo "---

ansible_become: yes
ansible_become_method: sudo
ansible_user: $USER
ansible_password: $PASSWORD
ansible_become_pass: $PASSWORD
platformPath: /platformData
ansible_host_ip: '{{ ansible_default_ipv4.address }}'
bigtoe_version: 4.0.1
fse_version: 3.5.1
cluster: true
personfile: $personfile" > /etc/ansible/group_vars/all.yml

if [[ $personfile == "false" ]];then
   cd ansible/scripts
   ./setup.sh
   if [[ $? -ne 0 ]];then
      fatal_exit 
   fi
   cp hosts /etc/ansible/hosts
else
   cd ansible/scripts
   ./setupPersonfile.sh
   if [[ $? -ne 0 ]];then
      fatal_exit 
   fi
   cp hosts /etc/ansible/hosts
fi
   cd /etc/ansible
   ansible-playbook playbook/02-check.yml
   if [ $? -ne 0 ];then
     fatal_exit
   fi

   ansible-playbook playbook/00-installTG.yml

}


function main(){


    if [[ -f ${LOCK_FILE} ]];then
        logging "This Tool Is Running, Please Wait."
        exit 1
    fi
    lock
  run checkAnsible
  if [[ $? != 0 ]];then
    logging "Ansible Is Not Installed, Install Ansible "
    installAnsible
    if [[ $? != 0 ]]; then
        fatal_exit
    fi
  else
    logging "Ansible Aleady Installed."
  fi

 if [ -f /etc/ansible ];then
    rm -f /etc/ansible
 fi
 ln -s ${SHELL_DIR}/ansible /etc/ansible

    while true
    do
        menu
    read choose
        case $choose in
        1)
  clear
      logging "单机部署"
  singleDeploy
  if [[ $? == 0 ]]; then
    normal_exit
  else
    fatal_exit
  fi
        ;;
        2)
  clear
      logging "集群部署"
      clusterDeploy
  if [[ $? == 0 ]]; then
    normal_exit
  else
    fatal_exit
  fi
      ;;
      [qQ])
      logging "退出"
  unlock
      exit 0
      ;;
      *)
      logging "请选择[1-2]"
        menu
      esac
  done
}
trap "kill_exit" HUP INT QUIT TSTP
logging ""
echo "-------" >> $SHELL_LOG
params=$@
logging "COMMAND: $0 $params"
main $@
