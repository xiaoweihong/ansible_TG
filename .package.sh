#!/bin/bash
PUBLISH_DATE=$(date +%Y%m%d)
PUBLISH_PATH=/root/platformTG_${PUBLISH_DATE}

echo "clean package"
cd roles/common/files/package
rm -f *gz
rm -f *.img

mkdir ${PUBLISH_PATH} -p && cd ${PUBLISH_PATH}

cp -pvr /etc/ansible/ ${PUBLISH_PATH}


ln -s ansible/roles/common/files/package/software_package.tgz software_package.tgz
ln -s ansible/install.sh install.sh

cd ansible/roles/common/files/package/ && bash downPackage.sh
cd -
