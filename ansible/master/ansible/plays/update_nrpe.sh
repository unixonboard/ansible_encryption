#!/bin/bash

# Script name: update_nrpe.sh
# Author:      Walter G. da Cruz
# Version:     0.1
# Date:        2019.03.03
# Description:
# Currently, nrpe runs under xinet.d.  We are migrating to nrpe daemon instead
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
        ansible-playbook -v -i $HOSTNAME -e 'ansible_python_interpreter=/usr/bin/python2.6' --ask-become-pass update_nrpe.yml
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

ansible-playbook -v -i $HOSTNAME --ask-become-pass update_nrpe.yml

