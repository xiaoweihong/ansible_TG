#!/bin/bash

# This is deploy deepcloud.
# Author: Pang Hao
# Date: 2019.10.29

script_path=$(pwd)
log_file=$(pwd)/log/deploy.log
package_dir=$(pwd)/packages
config_dir=$(pwd)/config
image_dir=$(pwd)/images
pg_pod_name=$(kubectl get pod -n pgsql |tail -1 |awk '{print $1}')
host_ip=$(ifconfig -a $(route -n |awk '$1 ~ /^0.0.0.0$/ {print $NF}') |awk -F ":" '$1 ~ /inet addr/ {print $2}' |awk '{print $1}')
pg_ip=$(kubectl -n pgsql get svc -ojsonpath={..clusterIP})



function echo_log {
  echo -e $(date "+%F %T") "$1" >>${log_file}
}

function echo_error_log {
  if [[ $? != 0 ]]
  then
    if [[ -n "$2" ]]
    then
      cat /tmp/$2.log >>${log_file}
    fi
    echo -e "\033[40;31m$1 \033[0m"
    echo_log "\033[40;31m$1 \033[0m"
    exit 1
  fi
}

function check_installed {
  $1 &>/dev/null
  echo_error_log "\033[40;31m$2 is not installed !"
}

function install_package {
  echo_log "Install $1..."
  cd ${package_dir}/$1
  python setup.py install &>/dev/null
  echo_error_log "Install $1 is failed !"
  cd ${script_path}
  echo_log "\033[40;32mInstall $1 is success ! \033[0m"
}

function batch_install_packages {
  #for package in setuptools urllib3 certifi idna chardet requests jsonpointer jsonpatch backports six websocket meld3 supervisor
  for package in setuptools urllib3 certifi idna chardet requests jsonpointer jsonpatch backports six websocket
  do
    install_package ${package}
  done
}

function check_fse_type {
  echo_log "Check fse type..."
  type=$(python ${config_dir}/get_fse_type.py |awk -F '_' '{print $3}')
  
  if [[ "${type}" == "GPU" || "${type}" == "CPU" ]]
  then
    echo_log "\033[40;32mFse is running on ${type} ! \033[0m"
  else
    echo -e "\033[40;31mFse is not running on GPU or CPU, please check ! \033[0m"
    echo_log "\033[40;31mFse is not running on GPU or CPU, please check ! \033[0m"
    exit 1
  fi
}

function add_repo {
  echo_log "Add repo..."
  python ${config_dir}/add_repo.py |grep fail &>/dev/null

  if [[ $? != 0 ]]
  then
    echo_log "\033[40;32mAdd repo is success ! \033[0m"
  else
    echo -e "\033[40;31mAdd repo is failed, please check fse ! \033[0m"
    echo_log "\033[40;31mAdd repo is failed, please check fse ! \033[0m"
    exit 1
  fi
}

function configure_supervisor {
  echo_log "Configure supervisor..."
  rm -f /etc/supervisord.conf
  cp ${config_dir}/supervisord.conf /etc/
  rm -rf /etc/supervisor/
  mkdir -p /etc/supervisor/
  ps aux |grep supervisord |grep -v grep |awk '{print $2}' |xargs kill -9
  supervisord -c /etc/supervisord.conf &>/dev/null
  sed -i '/supervisord/d' /etc/rc.local
  sed -i '/exit/i\supervisord -c /etc/supervisord.conf' /etc/rc.local
  supervisorctl status &>/dev/null
  echo_error_log "Configure supervisor is failed !"
  echo_log "\033[40;32mConfigure supervisor is success ! \033[0m"
}

function create_db_user {
  echo_log "Create database user deepglint..."
  kubectl exec -it ${pg_pod_name} -n pgsql -- bash -c "psql -U postgres -c 'SELECT 1 FROM pg_user WHERE usename = \$\$deepglint\$\$'" |grep -q 1
  
  if [[ $? != 0 ]]
  then
    kubectl exec -it ${pg_pod_name} -n pgsql -- bash -c "psql -U postgres -c 'CREATE USER deepglint WITH PASSWORD \$\$tiA)hLRbvqZ6\$\$;'" &>/dev/null
    echo_error_log "Create database user deepglint is failed !"
    echo_log "\033[40;32mCreate database user deepglint is success ! \033[0m"
  else
    echo_log "\033[40;32mThe database user deepglint already exists ! \033[0m"
  fi

  kubectl exec -it ${pg_pod_name} -n pgsql -- bash -c "psql -U postgres -c 'ALTER USER deepglint createdb;'" &>/dev/null
}

function create_db {
  echo_log "Create database keycloak..."
  kubectl exec -it ${pg_pod_name} -n pgsql -- bash -c "psql -U postgres -c 'SELECT 1 FROM pg_database WHERE datname = \$\$keycloak\$\$'" |grep -q 1
  
  if [[ $? != 0 ]]
  then
    kubectl exec -it ${pg_pod_name} -n pgsql -- bash -c "psql -U deepglint -d postgres -c 'CREATE DATABASE keycloak'" &>/dev/null
    echo_error_log "Create database keycloak is failed !"
    echo_log "\033[40;32mCreate database keycloak is success ! \033[0m"
  else
    echo_log "\033[40;32mThe database keycloak already exists ! \033[0m"
  fi
}

function insert_db_data {
  echo_log "Insert database data..."
  rm -rf /home/ubuntu/dbtool
  cp -r ${config_dir}/dbtool /home/ubuntu
  cd /home/ubuntu/dbtool/
  kubectl exec -it ${pg_pod_name} -n pgsql -- bash -c "psql -U postgres -c 'SELECT datname FROM pg_database'" |grep -q keycloak

  if [[ $? != 0 ]]
  then 
    echo -e "\033[40;31mThe database keycloak is not exists ! \033[0m"
    echo_log "\033[40;31mThe database keycloak is not exists ! \033[0m"
    exit 1
  else
    keycloak_table_num=$(kubectl exec -it ${pg_pod_name} -n pgsql -- bash -c "psql -U deepglint -d keycloak -c 'SELECT COUNT(*) FROM pg_tables WHERE schemaname = \$\$public\$\$'" |sed -n '3p' |sed -e 's/\r//g')
    if [[ ${keycloak_table_num} -gt 10 ]] 
    then
      echo_log "\033[40;32mThe database keycloak already insert data ! \033[0m"
    else
      cat keycloak.sql |kubectl exec -it ${pg_pod_name} -n pgsql -- psql -U deepglint -d keycloak &>/dev/null
    fi
  fi

  sed -i "s/127.0.0.1/${pg_ip}/g" ./config/dbtool.yaml  
  sed -i "s/192.168.2.225/${host_ip}/g" ./dbfiles/updatedb.xml
  sed -i "s/STAR_DEVICE_NUM/100000000/g" ./dbfiles/updatedb.xml
  sed -i "s/STAR_REGISTER_REPO_NUM/100000000/g" ./dbfiles/updatedb.xml
  sed -i "s/STAR_REGISTER_REPO_CAPACITY/100000000/g" ./dbfiles/updatedb.xml

  face_feature=$(grep 'MODEL_FACEFEATURE' /opt/bigtoe/pkg/k8s-conf/deepengine/vse/config/template/public.val |awk -F '#' '{print $2}')
  if [[ ${face_feature} = '1.9.3.0' ]]
  then
    mv /home/ubuntu/dbtool/dbfiles/updatedb.xml /home/ubuntu/dbtool/dbfiles/updatedb.xml.tmp
    tac /home/ubuntu/dbtool/dbfiles/updatedb.xml.tmp |sed "0,/]]><\/Update>/!b;//a\vsecall: true\', sync_id = nextval\(\'dgc_cachesync_seq\'\) WHERE config_def = \'MatrixMeta\'\;\nfeaturever: 1.9.3.0\nlinearbeta: 0.0\nlinearalpha: 1.0\ncosbbelow: 0.21251082\ncosabelow: 0.8685458\nrfcnaddr: vse-image-allobj-service.vse:7458\nrecogaddr: vse-image-allobj-service.vse:7458\nUPDATE config SET \"value\" = \'detectaddr: vse-image-allobj-service.vse:7458" |tac >/home/ubuntu/dbtool/dbfiles/updatedb.xml  
    rm -f /home/ubuntu/dbtool/dbfiles/updatedb.xml.tmp 
  elif [[ ${face_feature} = '2.7.3.0' ]] 
  then
    mv /home/ubuntu/dbtool/dbfiles/updatedb.xml /home/ubuntu/dbtool/dbfiles/updatedb.xml.tmp
    tac /home/ubuntu/dbtool/dbfiles/updatedb.xml.tmp |sed "0,/]]><\/Update>/!b;//a\vsecall: true\', sync_id = nextval\(\'dgc_cachesync_seq\'\) WHERE config_def = \'MatrixMeta\'\;\nfeaturever: 2.7.3.0\n    linearth: 1\n    originth: 1\n    cosb: 0.25255307\n  - cosa: 0.85106399\n    linearth: 0.85\n    originth: 0.702\n    cosb: 0.09108108\n  - cosa: 1.08108107\n    linearth: 0.83\n    originth: 0.6835\n    cosb: -0.74730632\n  - cosa: 2.30769028\n    linearth: 0.8\n    originth: 0.6705\n    cosb: -0.26428582\n  - cosa: 1.58730175\n  params:\nscoretransformer:\nrfcnaddr: vse-image-allobj-service.vse:7458\nrecogaddr: vse-image-allobj-service.vse:7458\nUPDATE config SET \"value\" = \'detectaddr: vse-image-allobj-service.vse:7458" |tac >/home/ubuntu/dbtool/dbfiles/updatedb.xml  
    rm -f /home/ubuntu/dbtool/dbfiles/updatedb.xml.tmp
  else
    echo -e "\033[40;31mThe face feature of vse is neither 1.9.3.0 nor 2.7.3.0, please check ! \033[0m"
    echo_log "\033[40;31mThe face feature of vse is neither 1.9.3.0 nor 2.7.3.0, please check ! \033[0m"
    exit 1
  fi

  kubectl exec -it ${pg_pod_name} -n pgsql -- bash -c "psql -U postgres -c 'SELECT datname FROM pg_database'" |grep -q god_eye
  
  if [[ $? != 0 ]]
  then
    bash run.sh &>/tmp/insert_db_data.log
    tail -1 /tmp/insert_db_data.log |grep -q "Update DB Success"
    echo_error_log "Insert database data to god_eye is failed !" "insert_db_data"
  else
    godeye_table_num=$(kubectl exec -it ${pg_pod_name} -n pgsql -- bash -c "psql -U deepglint -d god_eye -c 'SELECT COUNT(*) FROM pg_tables WHERE schemaname = \$\$public\$\$'" |sed -n '3p' |sed -e 's/\r//g')
    if [[ ${godeye_table_num} -gt 10 ]]
    then
      echo_log "\033[40;32mThe database god_eye already insert data ! \033[0m"
    else
      bash run.sh &>/tmp/insert_db_data.log
      tail -1 /tmp/insert_db_data.log |grep -q "Update DB Success"
      echo_error_log "Insert database data to god_eye is failed !" "insert_db_data"
    fi
  fi

  type=$(python ${config_dir}/get_fse_type.py |awk -F '_' '{print $3}')
  if [[ "${type}" == "CPU" ]] 
  then
    kubectl exec -it ${pg_pod_name} -n pgsql -- bash -c "psql -U deepglint -d god_eye -c 'UPDATE config SET value = \$\$2\$\$ WHERE id = \$\$688edede-2a0d-488e-9052-ca423948f258\$\$'" &>/dev/null
  fi

  cd ${script_path}
  echo_log "\033[40;32mInsert database data is success ! \033[0m"
}

function upload_picture {
  echo_log "Upload picture to seaweed..."
  cd ${config_dir}/seaweed/
  bash run.sh &>/tmp/upload_picture.log
  rm -f /tmp/zizhen.jpg
  wget -P /tmp http://127.0.0.1:30934/deepcloud/general/smoke/zizhen.jpg &>/dev/null
  echo_error_log "Upload picture to seaweed is failed !" "upload_picture"

  cd ${script_path}
  echo_log "\033[40;32mUpload picture to seaweed is success ! \033[0m"
}

function load_image {
  echo_log "Load $1 image..."
  docker load -i ${image_dir}/$1.tar &>/dev/null
  echo_error_log "Load $1 image is failed !"
  echo_log "\033[40;32mLoad $1 image is success ! \033[0m"
}

function batch_load_images {
  for image in python353 python2712
  do
    load_image ${image}
  done
}

function timer {
  seconds_left=100
  echo_log "\033[40;32mWait ${seconds_left}s for all pods in the deepcloud namespace to be completely removed ! \033[0m"
  while [ ${seconds_left} -gt 0 ]
  do
    echo -ne "\033[40;31m      ${seconds_left}      \033[0m" &>>${log_file}
    sleep 1
    seconds_left=$(($seconds_left - 1))
    echo -ne "\r     \r" &>>${log_file}
  done
}

function deploy_deepcloud {
  echo_log "Deploy deepcloud..."
  rm -rf /home/ubuntu/deepcloud
  cp -r ${config_dir}/deepcloud /home/ubuntu 
  sed -i "s/192.168.2.225/${host_ip}/g" /home/ubuntu/deepcloud/values.yaml
  kubectl get po -n deepcloud &>/tmp/get_pod.log
  grep -q "No resources found" /tmp/get_pod.log
   
  if [[ $? != 0 ]]
  then
    echo_log "\033[40;32mDeepcloud already deploy ! \033[0m"
    helm delete --purge dgc &>/dev/null
    timer 
  fi

  helm install -n dgc /home/ubuntu/deepcloud &>/tmp/deploy_deepcloud.log
  echo_error_log "Deploy deepcloud is failed !" "deploy_deepcloud"
  echo_log "\033[40;32mDeploy deepcloud is success ! \033[0m"
}

function supervisor_deploy {
  echo_log "Deploy $1..."
  rm -rf /home/ubuntu/$1
  cp -r ${config_dir}/$1 /home/ubuntu
  rm -f /etc/supervisor/$1.conf
  rm -rf /data/$1
  mkdir -p /data/$1
  cp ${config_dir}/example.conf /etc/supervisor/$1.conf
  sed -i "s/EXAMPLE/$1/g" /etc/supervisor/$1.conf
}

function supervisor_check {
  supervisorctl stop $1 &>/dev/null
  supervisorctl remove $1 &>/dev/null
  supervisorctl update &>/dev/null
  sleep 5
  status=$(supervisorctl status |grep $1 |awk '{print $2}')
  
  if [[ "${status}" != "RUNNING" ]]
  then
    echo -e "\033[40;31mDeploy $1 is failed ! \033[0m"
    echo_log "\033[40;31mDeploy $1 is failed ! \033[0m"
    exit 1
  fi

  echo_log "\033[40;32mDeploy $1 is success ! \033[0m"
}

function deploy_ladder {
  umount /home/ubuntu/ladder/data/seaweedfs &>/dev/null
  supervisor_deploy "ladder"
  sed -i "s/172.27.15.2/${host_ip}/g" /home/ubuntu/ladder/config/config-xiayun-k8s.yaml
  supervisor_check "ladder"
}

function deploy_xiaohong {
  supervisor_deploy "xiaohong"
  sed -i "s/192.168.2.225/${pg_ip}/g" /home/ubuntu/xiaohong/config/config_xiayun_k8s.yaml
  supervisor_check "xiaohong"
}

function deploy_imgtransferrer {
  supervisor_deploy "imgtransferrer"
  sed -i "s/10.0.3.171/${pg_ip}/g" /home/ubuntu/imgtransferrer/config/config.yaml
  supervisor_check "imgtransferrer"
}

function deploy_delete_expired_data {
  supervisor_deploy "delete_expired_data"
  docker rmi delete_expired_data &>/dev/null
  cd /home/ubuntu/delete_expired_data/
  sed -i "s/172.17.0.1/${pg_ip}/g" delete_expired_data.py
  docker build -t delete_expired_data . &>/dev/null
  cd ${script_path}
  docker rmi python:3.5.3 &>/dev/null
  docker rm -f delete_expired_data &>/dev/null
  supervisor_check "delete_expired_data"
}

function deploy_fse_monitor {
  supervisor_deploy "fse_monitor"
  sed -i "s/192.168.2.225/${host_ip}/g" /home/ubuntu/fse_monitor/fse_monitor.py
  supervisor_check "fse_monitor"
}

function configure_smoke_file {
  echo_log "Configure smoke file..."
  rm -rf /home/ubuntu/DPCdev
  cp -r ${config_dir}/DPCdev /home/ubuntu
  kubectl exec -it ${pg_pod_name} -n pgsql -- bash -c "psql -U deepglint -d god_eye -c 'UPDATE tenant SET access_key = \$\$AK-smoke\$\$ WHERE id = \$\$2e931176-4b5c-4608-a7ab-b0eddff80b99\$\$'" &>/dev/null
  kubectl exec -it ${pg_pod_name} -n pgsql -- bash -c "psql -U deepglint -d god_eye -c 'UPDATE tenant SET secret_key = \$\$SK-smoke\$\$ WHERE id = \$\$2e931176-4b5c-4608-a7ab-b0eddff80b99\$\$'" &>/dev/null
  sed -i "s/192.168.2.225/${host_ip}/g" /home/ubuntu/DPCdev/MySource.txt
  sed -i "s/192.168.2.225/${host_ip}/g" /home/ubuntu/DPCdev/msg.py
  sed -i "s/192.168.2.225/${host_ip}/g" /home/ubuntu/DPCdev/gRepo.txt
  sed -i "s/^/#&/g" /home/ubuntu/DPCdev/XIOT.txt
  cp ${config_dir}/smoke_test.sh /root/smoke_test.sh
  echo_log "\033[40;32mConfigure smoke file is success ! \033[0m"
  echo_log "\033[40;32mPlease start smoking with command: cd /root/ && bash smoke_test.sh ! \033[0m"
}

function main {
  # Clear log.
  >${log_file}

  # Check python is installed.
  check_installed "python -V" Python

  # Check helm is installed.
  check_installed "helm list" Helm

  # Install packages.
  batch_install_packages

  # Check the type of fse.
  check_fse_type
  
  # Add repo.
  add_repo
  
  # Configure supervisor.
#  configure_supervisor
  
  # Create database user.
  create_db_user
  
  # Create database.
  create_db
  
  # Insert database data.
  insert_db_data

  # Upload picture to seaweed.
#  upload_picture
  
  # Deploy deepcloud.
  deploy_deepcloud
  
  # Deploy ladder.
#  deploy_ladder

  # Deploy xiaohong.
  # deploy_xiaohong

  # Deploy imgtransferrer.
#  deploy_imgtransferrer

  # Deploy delete expired data.
#  deploy_delete_expired_data
  
  # Deploy fse monitor.
#  deploy_fse_monitor

  # Configure smoke file.
#  configure_smoke_file
}


main
