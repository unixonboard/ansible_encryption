#!/bin/bash

# Script name: test_sudo.sh
# Author:      Walter G. da Cruz
# Version:     0.1
# Date:        2019.02.07
# Description:
# Shell script execute fix_cis_benchmark.yml ansible playbook.  The script reconfigure some settings flagged by the CIS_BENCHMARK report
# against our current configuration.  We are getting 75% and the goal is to get 90%
#
# Requirements:
# ERROR! the role 'cis-benchmark' was not found in /home/walter/scripts/ansible/plays/roles:/home/walter/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:/home/walter/scripts/ansible/plays
##############################################################################################

# for i in `cat ./hosts/qa-sudo1`; do
#     RESULT=`ssh -q $i "lsb_release -rs | cut -f1 -d."`
#     echo "Version -> $RESULT"

#     if [ $RESULT == "5" ]; then
# RESULT=`ssh -q $i "lsb_release -rs | cut -f1 -d."`
#         ansible-playbook -v -i $i, -e "host_key_checking=False; ansible_python_interpreter=/usr/bin/python2.6" --ask-become-pass test_sudo.yml
#     else
        ansible-playbook -v -i ./hosts/qa-sudo1 -e "host_key_checking=False" --ask-become-pass test_sudo.yml
#     fi
# done
