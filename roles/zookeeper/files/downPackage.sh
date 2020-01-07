#!/bin/bash

DOWNLOAD_URL="192.168.2.189:8050/platformSoftware"

function downloadPackage(){

   wget ${DOWNLOAD_URL}/apache-zookeeper-3.5.6-bin.tar.gz
   wget ${DOWNLOAD_URL}/zookeeper-3.4.10.tar.gz

}
downloadPackage
