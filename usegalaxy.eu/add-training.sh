#!/bin/bash
if (( $# != 1 )) && (( $# != 3 )); then
    echo "Usage:"
    echo
    echo "  $0 <training-identifier> <vm-size> <vm-count>"
    echo
    exit 1;
fi

training_identifier=$1
vm_size=${2:-c.c10m55}
vm_count=${3:-1}
output="instance_training-${training_identifier}.tf"

cat training-template.txt | \
    sed "s/TRAINING_IDENTIFIER/${training_identifier}/g" | \
    sed "s/VM_SIZE/${vm_size}/g" | \
    sed "s/VM_COUNT/${vm_count}/g" > $output

#echo "Done: instance_training-${training_identifier}.tf"
