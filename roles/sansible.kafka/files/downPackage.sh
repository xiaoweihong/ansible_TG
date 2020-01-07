#!/bin/bash

DOWNLOAD_URL="192.168.2.189:8050/platformSoftware"

function downloadPackage(){

   wget ${DOWNLOAD_URL}/kafka_2.11-2.3.1.tgz
   wget ${DOWNLOAD_URL}/kafka_2.11-0.10.2.1.tgz

}
downloadPackage
