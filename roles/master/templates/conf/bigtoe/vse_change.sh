#!/bin/bash

IP={{ansible_host_ip}}
grep Encryption vse-video-allobj-config.tpl >/dev/null 2>&1

if [[ $? -eq 1 ]];then
    ls vse-*.tpl|xargs -i sed -i 's#"AllObjsSendMode":true#"AllObjsSendMode":true,\n        "DisableFeatureEncryption": true#g' {};
    docker run --rm -v /etc/bigtoe/flags/sshd_port:/etc/bigtoe/flags/sshd_port -v /opt/bigtoe:/opt/bigtoe -v /var/www:/var/www -e SERVER_IP=${IP} --user 33 dockerhub.deepglint.com/arch/php:7.3.8-fpm php /var/www/bigtoe/scripts/template.php vse config.json
fi

