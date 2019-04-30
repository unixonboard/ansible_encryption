#!/bin/bash

# Script name: yum_security_updates.sh
# Author:      Walter G. da Cruz
# Version:     0.2
# Date:        2019.01.05
# Description:
# Shell script that executes an ansible playbook. The script will create a yum repo config
# for security patches only
# https://access.redhat.com/solutions/10021
#
# Requirements:
# a) Already have an account on AWS
#
##############################################################################################

get_os_version() {
    OS_VERSION=`ssh -q -o "StrictHostKeyChecking no" $1 "lsb_release -rs | cut -f1 -d."`
    if [ "$OS_VERSION" == "" ]; then
        ssh -q -o "StrictHostKeyChecking no" $1 "sudo yum -y install redhat-lsb-core"
        OS_VERSION=`ssh -q -o "StrictHostKeyChecking no" $1 "lsb_release -rs | cut -f1 -d."`
    fi
}

if [[ $# -eq 0 ]] ; then
    read -p "Enter Hostname: " HOSTNAME
else
    HOSTNAME=$1
fi

get_os_version $HOSTNAME

echo "Running $0 playbook...."

if [ "$OS_VERSION" == "5" ]; then
    ansible-playbook -v -i $HOSTNAME, -e 'ansible_python_interpreter=/usr/bin/python2.6' --ask-become-pass yum_security_updates.yml 
else
    ansible-playbook -v -i $HOSTNAME, --ask-become-pass yum_security_updates.yml 
fi

