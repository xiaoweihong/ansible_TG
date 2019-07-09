#!/bin/bash

DOWNLOAD_URL="192.168.2.189:8050"

func downloadPackage(){

   wget ${DOWNLOAD_URL}/bigtoe_DeepEngine-4.0.1-all.tar.gz
   wget ${DOWNLOAD_URL}/software_package.tgz
   wget ${DOWNLOAD_URL}/platformTG.tgz
   wget ${DOWNLOAD_URL}/mutischeduler-1.0.0.tar.gz
   wget ${DOWNLOAD_URL}/fse-3.5.1.tar.gz
   wget ${DOWNLOAD_URL}/map.tgz

}

