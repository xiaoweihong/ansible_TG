#!/bin/bash


while true
do
    read -p "请输入图片存储时间(单位:(M)月,不用输入单位,默认为6个月)*必填: " Storage_time
  if [ ! -n "$Storage_time" ];then
      Storage_time=6M
      break
  fi
  if [ ! -n "$Storage_time" ]||[ -n "`echo $Storage_time | sed 's/[0-9]//g'`" ]||[ $Storage_time -le 0 ];then
      continue
    else
      Storage_time=${Storage_time}M
    fi
break
done

sed -i "s/\"Ttl\":\( .*\),/\"Ttl\": \"$Storage_time\",/g" $SHELL_DIR/ansible/roles/TG/templates/serviceConfig/arcee_captured.json
