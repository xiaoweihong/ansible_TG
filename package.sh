#!/bin/bash
PUBLISH_DATE=$(date +%Y%m%d)
VERSION_TAG=$(git reflog |head -1|awk '{print $1}')
PUBLISH_NAME=platform_${VERSION_TAG}-${PUBLISH_DATE}-NOENGINE
PUBLISH_PATH=/backup/xiaowei/project/release/platformTG/release/${PUBLISH_NAME}
BASEDIR=$(cd $(dirname $0); pwd)


echo "clean package"
cd roles/common/files/package
rm -f *gz
rm -f *.img
rm -f *.tar
rm -f *.zip

if [  -d ${PUBLISH_PATH} ];then
   rm  -rf ${PUBLISH_PATH}*
fi

mkdir ${PUBLISH_PATH}/ansible -p

cd ${PUBLISH_PATH}

cp -pvr ${BASEDIR}/* ${PUBLISH_PATH}/ansible
#cp -pvr /etc/ansible/ ${PUBLISH_PATH}

cd ${PUBLISH_PATH}
ln -s ansible/roles/common/files/package/software_package.tgz software_package.tgz
ln -s ansible/install.sh install.sh

cd ${PUBLISH_PATH}/ansible/roles/common/files/package/ && bash downPackage.sh
cd ${PUBLISH_PATH}

cd ../
tar zcvf ${PUBLISH_NAME}.tar.gz ${PUBLISH_NAME}
