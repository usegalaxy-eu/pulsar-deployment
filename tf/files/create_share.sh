#!/bin/bash

sleep 300

while [ ! -b /dev/sdb ]; do
  echo "Waiting for /dev/sdb..."
  sleep 2
done

mkfs -t xfs /dev/sdb
mkdir -p /data/share
echo "/dev/sdb  /data/share xfs defaults,nofail 0 2" >> /etc/fstab
mount /data/share
chown pulsar:pulsar -R /data/share