#!/bin/bash

# Script name: firewall.sh
# Author:      Walter G. da Cruz
# Version:     0.3
# Date:        2019.01.19
# Updated:      2019.02.04
# Description:
# Shell script execute firewall ansible playbook.  The script Reconfigure iptables according to the type of Application
#
# Requirements:
# CentOS 5 comes with python 2.4 or 2.5. Ansible can only run on Python 2.6 and above.  The work around is to run
# centos5_update_python2.sh script, to install Python 2.6 on these hosts.  Ansible playbook needs to run with the
# --extra-vars (-e flag) pointing to 'ansible_python_interpreter=/usr/bin/python2.6'
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
        ansible-playbook -v -i $HOSTNAME -e 'ansible_python_interpreter=/usr/bin/python2.6' --ask-become-pass iptables.yml
    fi
}

if [[ $# -eq 0 ]]; then
    HOSTNAME="./hosts/hostfile"
    echo "Application Types are: aaa, cgw, kestrel, mail, rediscluster, sftp, splunk, yum"
    read -p "Enter Apptype: " APP_TYPE
    for i in `cat $HOSTNAME`; do
        get_os_version $i
    done
elif [[ $# -eq 2 ]]; then
    get_os_version $1
    HOSTNAME="$1,"
    APP_TYPE="$2"
else
    echo "Application Types are: aaa, cgw, kestrel, mail, rediscluster, sftp, splunk, yum"
    echo "Usage: ./$0 (which reads ./hosts/hostfile) OR ./$0 <hostname> <APP_TYPE>"
    exit 1
fi

echo "Running $0 playbook...."

ansible-playbook -v -i $HOSTNAME --extra-vars "app_type=$APP_TYPE" --ask-become-pass iptables.yml
