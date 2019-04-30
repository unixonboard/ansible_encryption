#!/bin/bash

## check for encrypted VMs, with autostart enabled, which are not running and start them
## this is needed when the disk is not opened (un-encrypted) before the default virsh start
## on a hyper after a reboot, with "disk not found" errors in messages
##
## Only check for for an hour after reboot of the hyper
## root crontab entries:
## start encrypted VMs that failed waiting for the encrypted disk to be opened (only for 1 hr after HV reboot)
## * * * * * /usr/local/sbin/delayed_encrypted_autostart.sh >> /var/log/delayed-encrypted-autostart.log 2>&1
##
## 20190301 - fixed uptime logic - rich

verbose_debug=""
## was the last reboot less than an hour ago?
up2long=$( uptime -p | egrep -c "year|month|week|day|hour" )
if [[ "${up2long}" -ge "1" ]]; then
	if [[ "$1" == "-f" ]]; then
		echo "  #FORCE# run no matter what..."
		verbose_debug="y"
	else
		## Hyper has been up over an hour, stop trying
		exit 2
	fi
fi

## find encrypted VMs with autostart set, which are not running, and start them
vm_list=$( virsh list --autostart --all | grep "shut off" | awk '{print $2}' | xargs )
## go thru the list and find the encrypted VMs (by the disk name)
for vm in ${vm_list} ; do
	echo " $(date) #INFO# checking VM : $vm"
	encr=$( virsh dumpxml ${vm} | grep -c "mapper/open" )
	if [[ "${encr}" -ge "1" ]]; then
		## VM has an encrypted disk
		disk0=$( virsh dumpxml ${vm} | grep "mapper/open" | sed 's/.*mapper\///' | sed 's/.\/.//' )
		## verify if disk is avail
		encr_disk0=$( lsblk | grep ${disk0} | grep -c "crypt" )

		## if a logical volume and VM pair exist - start the VM
		if [[ "${disk0}" =~ "${vm}" && "${encr_disk0}" == "1" ]]; then 
			## start the VM
			echo " $(date) #INFO# STARTING VM : $vm"
			virsh start ${vm}
		fi
	fi
done

## if running manually (-f) then display status
if [[ -n ${verbose_debug} ]]; then
	echo ""
	lsblk | egrep -i "encr|crypt"
	echo ""
	cat /etc/crypttab
	echo ""
	virsh list --all
fi

exit 0

