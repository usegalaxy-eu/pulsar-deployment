#!/bin/bash
find /data/share/tools/_conda/envs -maxdepth 1 -mindepth 1 -type d -exec tar zcvf {}.tar.gz {} --exclude=*.pyc \;
