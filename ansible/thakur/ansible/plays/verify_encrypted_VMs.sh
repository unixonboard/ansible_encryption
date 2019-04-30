#!/bin/bash

# Script name: verify_encrypted_VMs.sh
# Author:      Walter G. da Cruz
# Version:     0.2
# Date:        2019.03.01
# Updated:      2019.03.15 - Included the HV OS Version
# Description:
# scp script to HV and Run Verification which VMs are Encrypted
#
# Requirements:
##############################################################################################

get_os_version() {
    OS_VERSION=`ssh -q -o "StrictHostKeyChecking no" $1 "lsb_release -rs | cut -f1 -d."`
    if [ "$OS_VERSION" == "" ]; then
        ssh -q -o "StrictHostKeyChecking no" $1 "sudo yum -y install redhat-lsb-core"
        OS_VERSION=`ssh -q -o "StrictHostKeyChecking no" $1 "lsb_release -rs | cut -f1 -d."`
    fi
    echo "OS Version for $1 is: $OS_VERSION"
}

if [[ $# -eq 0 ]]; then
  HOSTNAME="./hosts/hostfile"
  for i in `cat $HOSTNAME`; do
    echo "=============== Working on $i ==============="
    get_os_version $i
    scp -pqr ./files/delayed_encrypted_autostart.sh $i:/tmp
    scp -pqr ./files/verify_encrypted_VMs.sh $i:/tmp
    ssh -q -t -o "StrictHostKeyChecking no" $i "sudo cp /tmp/delayed_encrypted_autostart.sh /usr/local/sbin/delayed_encrypted_autostart.sh; \
      sudo chmod u+x /usr/local/sbin/delayed_encrypted_autostart.sh; \
		  sudo chmod u+x /tmp/verify_encrypted_VMs.sh; \
		  sudo /tmp/verify_encrypted_VMs.sh | sudo tee /var/www/html/$i.verify_encrypted_VMs; \
		  rm -f /tmp/verify_encrypted_VMs.sh"
      curl -v http://$i/$i.verify_encrypted_VMs | tee logs/$i.verify_encrypted_VMs
  done
elif [[ $# -eq 1 ]]; then
    echo "=============== Working on $1 ==============="
    get_os_version $1
    scp -pqr ./files/delayed_encrypted_autostart.sh $i:/tmp
    scp -pqr ./files/verify_encrypted_VMs.sh $1:/tmp
    ssh -q -t -o "StrictHostKeyChecking no" $1 "sudo cp /tmp/delayed_encrypted_autostart.sh /usr/local/sbin/delayed_encrypted_autostart.sh; \
	    sudo chmod u+x /usr/local/sbin/delayed_encrypted_autostart.sh; \
	    sudo chmod u+x /tmp/verify_encrypted_VMs.sh; \
      sudo /tmp/verify_encrypted_VMs.sh | sudo tee /var/www/html/`hostname`.verify_encrypted_VMs; \
      rm -f /tmp/verify_encrypted_VMs.sh"
    curl -v http://$1/$1.verify_encrypted_VMs | tee logs/$1.verify_encrypted_VMs
else
    echo "Usage: ./$0 (which reads ./hosts/hostfile) OR ./$0 <hostname>"
    exit 1
fi

