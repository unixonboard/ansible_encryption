#!/bin/bash

# Filename:      main.sh
# Author:        Walter G. da Cruz
# Version:       0.1
# Date:          2019.01.15
# Description:
# Install iptables rules on Yum repos
#
# Requirements:
# a) CentOS 7 already comes with yum-security plugin, no need to install
##############################################################################################

# CENTOS7="CentOS Linux release 7.2.1511 (Core)"
# SL6="Scientific Linux release 6.4 (Carbon)"
# CENTOS5="CentOS release 5.8 (Final)"

check_app_type() {
    case "$1" in
        aaa) APP_TYPE="aaa"
            ;;
        cgw) APP_TYPE="cgw"
            ;;
        kestrel) APP_TYPE="kestrel"
            ;;
        mail) APP_TYPE="mail"
            ;;
        rediscluster) APP_TYPE="rediscluster"
            ;;
        sftp) APP_TYPE="sftp"
            ;;
        splunk) APP_TYPE="splunk"
            ;;
        yum) APP_TYPE="yum"
            ;;
        *) APP_TYPE="" 
            Echo "There is a problem with Application Type"
            exit 1
    esac
}

check_region() {
    case "$1" in
        usa) REGION="usa"
        ;;
        eur) REGION="eur"
        ;;
        uae) REGION="uae"
        ;;
        chn) REGION="chn"
        ;;
        ind) REGION="ind"
        ;;
        *) REGION=""
            Echo "There is a problem with REGION"
            exit 1
    esac
}

if [[ $# -eq 0 ]]; then
    read -p "Enter Apptype: " APP_TYPE
    check_app_type $APP_TYPE
    read -p "Enter Region: " REGION
    check_app_type $APP_TYPE
    check_region $REGION
elif [[ $# -eq 2 ]]; then
    APP_TYPE=$1
    REGION=$2
    check_app_type $1
    check_region $2
else
    echo "There is a problem with the Parameters"
    echo "Application Types are: aaa, cgw, kestrel, mail, rediscluster, sftp, splunk, yum"
    echo "Regions are: usa, eur, uae, chn, ind"
    Echo "Usage: ./main.sh <App type> <Region>"
    exit 1
fi

for i in `cat ./hosts/hostfile`; do
    echo "Working on $i host......."
    ./centos5_update_python2.sh $i
    ./initial_setup.sh $i
    ./update_sudo.sh $i
    ./yum_security_updates.sh $i
    ./cis_benchmark.sh $i
    ./update_root.sh $i $REGION
    ./update_nrpe.sh $i
    ./tag_encrypted.sh $i
    ./iptables.sh $i $APP_TYPE
    ./reboot_host.sh $i
done

