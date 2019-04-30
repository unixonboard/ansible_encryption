#!/bin/bash

# Script name: setup_vm_autostart
# Author:      Walter G. da Cruz
# Version:     0.1
# Date:        2019.03.15
# Updated:      2019.03.15 - Included the HV OS Version
# Description:
# scp script to HV and Run Verification which VMs are Encrypted
#
# Requirements:
##############################################################################################

get_os_version() {
    OS_VERSION=`ssh -q -o "StrictHostKeyChecking no" $1 "lsb_release -rs | cut -f1 -d."`
    if [ "$OS_VERSION" == "" ]; then
        ssh -q -o "StrictHostKeyChecking no" $1 "sudo yum -y install redhat-lsb-core"
        OS_VERSION=`ssh -q -o "StrictHostKeyChecking no" $1 "lsb_release -rs | cut -f1 -d."`
    fi
}

if [[ $# -eq 2 ]]; then
    echo "=============== Working on Hypervisor $1 and VM $2.... ==============="
    get_os_version $1
    ssh -q -t -o "StrictHostKeyChecking no" $i "sudo virsh autostart $2"
  done
else
    echo "Usage: ./$0 <Hypervisor> <VM name>"
    exit 1
fi

