#!/bin/bash

# Script name: iptables_yum.sh
# Author:      Walter G. da Cruz
# Version:     0.1
# Date:        2019.01.07
# Description:
# Shell script that executes an ansible playbook. The script will deploy iptables on Yum Repo hosts
#
# Requirements:
# a) Already have an account on AWS
#
##############################################################################################

# ansible-playbook -i localhost, yum_security_updates.yml --extra-vars "aws_access_key='<AWS_ACCESS_KEY' aws_secret_key='AWS_SECRET_KEY'"
# ansible-playbook -vv -i pssb-scl01-yum1, -e 'host_key_checking=False' iptables_yum.yml
ansible-playbook -vv -i ./hosts/hostfile -e 'host_key_checking=False' --ask-become-pass iptables_yum.yml
