#!/bin/bash

DOWNLOAD_URL="192.168.2.189:8050/platformSoftware"

function downloadPackage(){

#   wget ${DOWNLOAD_URL}/bigtoe_DeepCloud-10.1.1-all.tar.gz
   wget ${DOWNLOAD_URL}/software_package.tgz
#   wget ${DOWNLOAD_URL}/platformTG.tgz
 #  wget ${DOWNLOAD_URL}/mutischeduler-1.0.0.tar.gz
 #  wget ${DOWNLOAD_URL}/fse-3.5.1.tar.gz
 #  wget ${DOWNLOAD_URL}/map.tgz
   wget ${DOWNLOAD_URL}/update_ssh_for_1604_20191016.tgz
   wget ${DOWNLOAD_URL}/importer-1.3.6.tar
#   wget ${DOWNLOAD_URL}/link-0.21.0.tar
   wget ${DOWNLOAD_URL}/hm_importer-0.12.5.tar
   wget ${DOWNLOAD_URL}/hw_importer-0.8.0.tar
   wget ${DOWNLOAD_URL}/dc84_sdk-0.1.0.tar
#   wget ${DOWNLOAD_URL}/vse-3.7.1-p2.tar.gz
#   wget ${DOWNLOAD_URL}/tools.zip
#   wget ${DOWNLOAD_URL}/tiles.tar.gz

}
downloadPackage
