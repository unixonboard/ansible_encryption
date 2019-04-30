#!/bin/bash

# Script name: os_version.sh
# Author:      Walter G. da Cruz
# Version:     0.1
# Date:        2019.01.19
# Updated:      2019.02.04
# Description:
# Shell script execute initial check if lsb is intalled. That is required to find which version of CentOS we are running
#
# Requirements:
##############################################################################################

ping -c 2 $1;

OS_VERSION=`ssh -q -o "StrictHostKeyChecking no" $1 "lsb_release -rs | cut -f1 -d."`

if [ "$OS_VERSION" == "" ]; then
    ssh -q -o "StrictHostKeyChecking no" $1 "sudo yum -y install redhat-lsb-core; lsb_release -rs | cut -f1 -d."
else
    echo "--> $OS_VERSION"
fi
