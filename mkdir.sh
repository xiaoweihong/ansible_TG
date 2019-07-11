#!/bin/bash

ansible all -m shell -a "mkdir /data"
ansible all -m shell -a "mkdir /platformData"
