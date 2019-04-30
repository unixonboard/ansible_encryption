#!/bin/bash

# Script name: update_root.sh
# Author:      Walter G. da Cruz
# Version:     0.1
# Date:        2019.03.02
# Description:
# Basically, update root password. 
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

run_ansible_centos5() {
    if [ "$OS_VERSION" == "5" ]; then
        ansible-playbook -v -i $HOSTNAME -e 'ansible_python_interpreter=/usr/bin/python2.6' --ask-become-pass update_root.yml
    fi
}

if [[ $# -eq 1 ]]; then
    HOSTNAME="./hosts/hostfile"
    REGION="$1"
    
    for i in `cat $HOSTNAME`; do
        get_os_version $i
    done
elif [[ $# -eq 2 ]]; then
    get_os_version $1
    HOSTNAME="$1,"
    REGION="$2"
else
    echo "Regions are: usa, eur, uae, chn, ind"
    # read -p "Enter Region: " REGION
    echo "Usage: ./$0 <region> (which reads ./hosts/hostfile) OR ./$0 <hostname> <region>"
    exit 1
fi

echo "Running $0 playbook...."

ansible-playbook -v -i $HOSTNAME --extra-vars "location=$REGION" --ask-become-pass update_root.yml
