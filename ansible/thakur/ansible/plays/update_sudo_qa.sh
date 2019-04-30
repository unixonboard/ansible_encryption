#!/bin/bash

# Script name: update_sudo_qa.sh
# Author:      Walter G. da Cruz
# Version:     0.1
# Date:        2019.02.07
# Description:
# Shell script executes Update /etc/sudoers file and move users with sudo access to /etc/sudoers.d/ directory
# Note:  This script and playbook applies to QA Environment
# https://confluence-eng-sjc2.cisco.com/conf/display/~wdacruz/NCSE-60795+%5BJasper%5D+CT1108%3A+SEC-OPS-SUDO%3A+Implement+restricted+root+and+sudo+access
#
# Requirements:
##############################################################################################

#  RESULT=`ssh -q $i "lsb_release -rs | cut -f1 -d."`

# if [ $2 == "5" ]; then
#     ansible-playbook -v -i $1, -e 'host_key_checking=False; ansible_python_interpreter=/usr/bin/python2.6' --ask-become-pass update_sudo_qa.yml
# else
    # ansible-playbook -v -i ./hosts/qa-sudo1 -e 'host_key_checking=False' --ask-become-pass update_sudo_qa.yml
    # ansible-playbook -v -i ./hosts/qa-sudo1 -e 'host_key_checking=False; ansible_python_interpreter=/usr/bin/python2.6' update_sudo_qa.yml
    ansible-playbook -v -i ./hosts/qa-sudo1 -e 'host_key_checking=False; ansible_python_interpreter=/usr/bin/python2.6' --ask-become-pass update_sudo_qa.yml
    # ansible-playbook -v -i ./hosts/qa-sudo1 -e 'host_key_checking=False; ansible_python_interpreter=/usr/bin/python2.6' --ask-become-pass update_sudo_qa.yml --limit @/home/walter/scripts/ansible/plays/update_sudo_qa.retry
# fi

