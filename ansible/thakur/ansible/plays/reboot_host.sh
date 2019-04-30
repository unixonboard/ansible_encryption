#!/bin/bash

# Script name: reboot_host.sh
# Author:      Walter G. da Cruz
# Version:     0.2
# Date:        2019.01.08
# Description:
# Shell script execute fix_cis_benchmark.yml ansible playbook.  The script reconfigure some settings flagged by the CIS_BENCHMARK report
# against our current configuration.  We are getting 75% and the goal is to get 90%
#
# Requirements:
# ERROR! the role 'cis-benchmark' was not found in /home/walter/scripts/ansible/plays/roles:/home/walter/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:/home/walter/scripts/ansible/plays
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
        ansible-playbook -v -i $HOSTNAME -e 'ansible_python_interpreter=/usr/bin/python2.6' --ask-become-pass reboot_host.yml
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
ansible-playbook -v -i $HOSTNAME --ask-become-pass reboot_host.yml

ssh -q -t $HOSTNAME "sudo init 6"
