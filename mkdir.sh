#!/bin/bash

rm -f /root/.ssh/known_hosts
ansible all -m shell -a "mkdir /data"
ansible all -m shell -a "mkdir /platformData"
