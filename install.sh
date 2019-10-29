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
#echo "|                    2. 集群部署                                    |"
#echo "+-------------------------------------------------------------------+"
#echo "|                    3. 930beta升级到930release                     |"
#echo "+-------------------------------------------------------------------+"
#echo "|                    4. 更换ip                                      |"
#echo "+-------------------------------------------------------------------+"
echo "|                    q. 退出                                        |"
echo "+-------------------------------------------------------------------+"
echo "请选择:"
}

function singleDeploy(){

  rm -f /etc/ansible/hosts
  rm -f /etc/ansible/group_vars/all.yml
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
fse_version: 3.5.1-Turing-Proxy
cluster: false
update: false
personfile: true" > /etc/ansible/group_vars/all.yml
. ansible/scripts/config_ssh.sh
cd /etc/ansible/scripts
./setupPersonfile.sh
   if [[ $? -ne 0 ]];then
      fatal_exit
   fi
   cp hosts /etc/ansible/hosts

  rm -rf /etc/TG
  mkdir /etc/TG
  mv /etc/ansible/hosts /etc/TG/
  mv /etc/ansible/group_vars/all.yml /etc/TG
  ln -s /etc/TG/hosts /etc/ansible
  ln -s /etc/TG/all.yml /etc/ansible/group_vars

  cd /etc/ansible
  ansible-playbook playbook/02-check.yml
  if [ $? -ne 0 ];then
       fatal_exit
  fi

  ansible-playbook playbook/00-installTG.yml
}

function clusterDeploy(){
  echo "cluster deploy"
  rm -f /etc/ansible/hosts
  rm -f /etc/ansible/group_vars/all.yml
. ansible/scripts/config_arcee.sh
#. ansible/scripts/personfile.sh

  echo "---

ansible_become: yes
ansible_become_method: sudo
ansible_user: $USER
ansible_password: $PASSWORD
ansible_become_pass: $PASSWORD
platformPath: /platformData
ansible_host_ip: '{{ ansible_default_ipv4.address }}'
bigtoe_version: 4.0.1
fse_version: 3.5.1-Turing-Proxy
cluster: true
update: false
personfile: true" > /etc/ansible/group_vars/all.yml

. ansible/scripts/config_ssh.sh

personfile=true
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
  rm -rf /etc/TG
  mkdir /etc/TG
  mv /etc/ansible/hosts /etc/TG
  mv /etc/ansible/group_vars/all.yml /etc/TG
  ln -s /etc/TG/hosts /etc/ansible
  ln -s /etc/TG/all.yml /etc/ansible/group_vars
   cd /etc/ansible
   ansible-playbook playbook/02-check.yml
   if [ $? -ne 0 ];then
     fatal_exit
   fi

   ansible-playbook playbook/00-installTG.yml

}
function update_delete(){
  supervisorctl stop all
  rm -f /etc/ansible/hosts
  rm -f /etc/ansible/group_vars/all.yml
  cd /etc/ansible
  cp /tmp/all.yml group_vars
  cp /tmp/hosts .
  rm -rf /etc/TG
  mkdir /etc/TG
  mv /etc/ansible/hosts /etc/TG
  mv /etc/ansible/group_vars/all.yml /etc/TG
  ln -s /etc/TG/hosts /etc/ansible
  ln -s /etc/TG/all.yml /etc/ansible/group_vars
  sed -i "s/fse_version:\( .*\)/fse_version: 3.5.1-Turing-Proxy/g" /etc/ansible/group_vars/all.yml
  sed -i "s/update:\( .*\)/update: True/g" /etc/ansible/group_vars/all.yml
  ansible-playbook playbook/03-updateTG.yml
}
function update(){
  rm -f /etc/ansible/hosts
  rm -f /etc/ansible/group_vars/all.yml
  supervisorctl stop all
  cd /etc/ansible
  cp /tmp/hosts .
  cp /tmp/all.yml group_vars
  rm -rf /etc/TG
  mkdir /etc/TG
  mv /etc/ansible/hosts /etc/TG
  mv /etc/ansible/group_vars/all.yml /etc/TG
  ln -s /etc/TG/hosts /etc/ansible
  ln -s /etc/TG/all.yml /etc/ansible/group_vars
  sed -i "s/fse_version:\( .*\)/fse_version: 3.5.1-Turing-Proxy/g" /etc/ansible/group_vars/all.yml
  sed -i "s/update:\( .*\)/update: True/g" /etc/ansible/group_vars/all.yml
  ansible-playbook playbook/03-updateTG.yml
}

function changeip(){
   cd /etc/ansible
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
  
  if [  -d /etc/ansible ];then
      logging "存在版本"
     if [ ! -f /etc/ansible/VERSION-930-release ];then
      logging "备份旧版本配置文件"
       cp /etc/ansible/hosts /tmp
       cp /etc/ansible/group_vars/all.yml /tmp
     fi
  else
      logging "旧版本已删除，配置文件需要手动配置"
      rm -f /etc/ansible
      ln -s ${SHELL_DIR}/ansible /etc/ansible
      touch /usr/local/TG_delete_update_flag
        fatal_exit
  fi


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
        3)
  clear
      logging "930beta升级到930release"
      if [ ! -f /usr/local/TG_delete_update_flag ];then
          logging "正常升级"
          rm -f /etc/ansible
          ln -s ${SHELL_DIR}/ansible /etc/ansible
          update
      else
          logging "修改配置文件后升级"
          cp /etc/ansible/hosts /tmp
          cp /etc/ansible/group_vars/all.yml /tmp
          update_delete
      fi
  if [[ $? == 0 ]]; then
    normal_exit
  else
    fatal_exit
  fi
        ;;
#        4)
#  clear
#      logging "更换ip"
#      changeip
#      ;;
      [qQ])
      logging "退出"
  unlock
      exit 0
      ;;
      *)
      logging "请选择[1-3]"
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
