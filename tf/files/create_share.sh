#!/bin/bash

mkfs -t xfs /dev/vdb
echo "/dev/vdb  /data/share xfs defaults,nofail 0 2" >> /etc/fstab
mount /data/share
mkdir -p /data/share
chown centos:centos -R /data/share
