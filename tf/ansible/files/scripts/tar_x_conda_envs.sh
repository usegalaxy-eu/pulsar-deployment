#!/bin/bash
find /data/share/tools/_conda/envs -maxdepth 1 -mindepth 1 -type f -exec tar zxvf {} -C / \;
