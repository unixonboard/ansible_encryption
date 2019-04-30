#!/bin/bash

# Script name: update_sudo.sh
# Author:      Walter G. da Cruz
# Version:     0.2
# Date:        2019.02.04
# Description:
# Shell script executes initial configuration.  If force Initial Password, password size, sudo requesting password, etc.
# https://confluence-eng-sjc2.cisco.com/conf/display/~wdacruz/NCSE-60795+%5BJasper%5D+CT1108%3A+SEC-OPS-SUDO%3A+Implement+restricted+root+and+sudo+access
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

if [[ $# -eq 0 ]] ; then
    read -p "Enter Hostname: " HOSTNAME
else
    HOSTNAME=$1
fi

get_os_version $HOSTNAME

echo "Running $0 playbook...."

if [ "$OS_VERSION" == "5" ]; then
    ansible-playbook -v -i $HOSTNAME, -e 'ansible_python_interpreter=/usr/bin/python2.6' --ask-become-pass update_sudo.yml
else
    ansible-playbook -v -i $HOSTNAME, --ask-become-pass update_sudo.yml
fi

