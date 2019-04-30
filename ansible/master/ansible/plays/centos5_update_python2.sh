#!/bin/bash

# Script name: centos5_update_python2.sh
# Author:      Walter G. da Cruz
# Version:     0.1
# Date:        2019.01.17
# Description:
# Shell script that executes an ansible playbook. We have a problem that Ansible don't run on old
# python 2.4 /2.5, which comes with CentOS 5.  The solution is to install python 2.6 parallel to
# the existing python.  Then, call the ansible-playbook with the "ansible_python_interpreter=/usr/bin/python2.6" flag
#
# Requirements:
# a) https://www.ansible.com/blog/using-ansible-to-manage-rhel-5-yesterday-today-and-tomorrow
#
##############################################################################################

get_os_version() {
    OS_VERSION=`ssh -q -t -o "StrictHostKeyChecking no" $1 "lsb_release -rs | cut -f1 -d."`
    if [ "$OS_VERSION" == "" ]; then
        ssh -q -t -o "StrictHostKeyChecking no" $1 "sudo yum -y install redhat-lsb-core"
        OS_VERSION=`ssh -q -o "StrictHostKeyChecking no" $1 "lsb_release -rs | cut -f1 -d."`
    fi
}

check_python2.6_installed_centos5() {
    PYTHON26=`ssh -q -t -o "StrictHostKeyChecking no" $1 "test -f /usr/bin/python2.6"`
    if [ PYTHON26 eq 1 ]; then
        ssh -q -t $1 "sudo yum -y install python26.x86_64"
    fi
}

if [[ $# -eq 0 ]] ; then
    read -p "Enter Hostname: " HOSTNAME
else
    HOSTNAME=$1
fi

get_os_version $HOSTNAME

if [ "$OS_VERSION" == "5" ]; then
    check_python2.6_installed_centos5 $HOSTNAME
fi
