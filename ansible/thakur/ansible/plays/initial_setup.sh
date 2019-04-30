#!/bin/bash

# Script name: initial_setup.sh
# Author:      Walter G. da Cruz
# Version:     0.1
# Date:        2019.02.04
# Description:
# Shell script executes initial configuration.  If force Initial Password, password size, sudo requesting password, etc.
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

check_python2.6_installed_centos5() {
    PYTHON26=`ssh -q -o "StrictHostKeyChecking no" $1 "test -f /usr/bin/python2.6"`
    if [ PYTHON26 eq 1 ]; then
        ssh -q -t $1 "sudo yum -y install python26.x86_64"
    fi
}

run_ansible_centos5() {
    if [ "$OS_VERSION" == "5" ]; then
        ansible-playbook -v -i $HOSTNAME -e 'ansible_python_interpreter=/usr/bin/python2.6' --ask-become-pass initial_setup.yml
    fi
}

if [[ $# -eq 0 ]]; then
    HOSTNAME="./hosts/hostfile"
    for i in `cat $HOSTNAME`; do
        get_os_version $i
    done
elif [[ $# -eq 1 ]]; then
    get_os_version $1
    HOSTNAME="$1,"
else
    echo "Usage: ./$0 (which reads ./hosts/hostfile) OR ./$0 <hostname>"
    exit 1
fi

echo "Running $0 playbook...."
ansible-playbook -v -i $HOSTNAME --ask-become-pass initial_setup.yml
