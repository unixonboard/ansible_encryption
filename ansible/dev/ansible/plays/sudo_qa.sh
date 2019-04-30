#!/bin/bash

# Filename:      sudo_qa.sh
# Author:        Walter G. da Cruz
# Version:       0.1
# Date:          2019.02.07
# Description:
# Install New Sudoo access in QA Environment
#
# Requirements:
#
##############################################################################################

# CENTOS7="CentOS Linux release 7.2.1511 (Core)"
# SL6="Scientific Linux release 6.4 (Carbon)"
# CENTOS5="CentOS release 5.8 (Final)"

for i in `cat ./hosts/qa-sudo1`; do
    RESULT=`ssh -q $i "lsb_release -rs | cut -f1 -d."`
    echo "Version -> $RESULT"

    case $RESULT in
        7) echo "$i is a Centos 7"
	        # ./initial_setup.sh $i 7 
	        # ./test_sudo.sh $i 7 
            ./update_sudo_qa.sh $i 7
	        # ./update_sudo.sh $i 7 
            # ./yum_security_updates.sh $i 7 
		    # ./cis_benchmark.sh $i 7 
		    # ./iptables.sh $i 7
            # ./reboot_host.sh $i 7
	        ;;
        6) echo "$i is a Centos 6"
	        # ./initial_setup.sh $i 6 
	        # ./test_sudo.sh $i 7 
            ./update_sudo_qa.sh $i 6
	        # ./update_sudo.sh $i 6 
            # ./yum_security_updates.sh $i 6 
		    # ./cis_benchmark.sh $i 6 
		    # ./iptables.sh $i 6
            # ./reboot_host.sh $i 6
	        ;;
        5) echo "$i is a CentOS 5"
            # ./centos5_update_python2.sh $i 5
            # ./initial_setup.sh $i 5 
	        # ./test_sudo.sh $i 7 
            ./update_sudo_qa.sh $i 5
	        # ./update_sudo.sh $i 5 
	        # ./yum_security_updates.sh $i 5 
	        # ./cis_benchmark.sh $i 5 
	        # ./iptables.sh $i 5
            # ./reboot_host.sh $i 5
            ;;
	    *) echo "CentOS version NOT found on $i"
            # ./check.sh $i
    esac
done

