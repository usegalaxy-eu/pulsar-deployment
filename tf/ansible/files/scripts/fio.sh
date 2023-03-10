#!/bin/bash

echo "Max-Write-Speed:"
fio --rw=write --name=IOPS-write --bs=1024k --direct=1 --filename=test-file --numjobs=4 --ioengine=libaio --iodepth=32 --refill_buffers --group_reporting --runtime=60 --time_based --size=5G
rm test-file

echo "Max-Read-Speed:"
fio --rw=read --name=IOPS-read --bs=1024k --direct=1 --filename=test-file --numjobs=4 --ioengine=libaio --iodepth=32 --refill_buffers --group_reporting --runtime=60 --time_based --size=5G
rm test-file

echo "IOPS-Write:"
fio --rw=randwrite --name=IOPS-write --bs=4k --direct=1 --filename=test-file --numjobs=4 --ioengine=libaio --iodepth=32 --refill_buffers --group_reporting --runtime=60 --time_based --size=5G
rm test-file

echo "IOPS-Read:"
fio --rw=randread --name=IOPS-read --bs=4k --direct=1 --filename=test-file --numjobs=4 --ioengine=libaio --iodepth=32 --refill_buffers --group_reporting --runtime=60 --time_based --size=5G
rm test-file
