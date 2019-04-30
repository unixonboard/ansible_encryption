#!/bin/bash

## check for encrypted LVMs on a Hypervisor, verify everything is set up correctly for each encrypted VM
## this runs only on Hypervisors; written for CentOS 7, CentOS 6, SL 6.4 and above
##
## 20190222 - first draft - rich
## 20190225 - version 1.0 - rich
## 20190227 - version 1.1 - changed from LVM to a VM focus - rich
## 20190228 - version 1.2 - minor tweaks - rich
## 20190305 - version 1.3 - updated error messgaes - rich
## 20190308 - version 2.0 - major update to support CentOS 7, CentOS 6.8 (and above), SL 6.4 (and above) - rich

## verify this is run on a hyper, only as root
user_root=$( id | grep -c "(root)" )
is_hyper=$( virsh list --all 2>&1 | grep -c "State" )
if [[ "${is_hyper}" -ne "1" || "${user_root}" -ne "1" ]]; then
    echo "  FAIL : this script is only for use as root on Hypervisors"
    echo ""
    exit 1
fi

## determine OS version on the Hyper
os_rel=$( cat /etc/redhat-release | xargs )
if [[ "${os_rel}" =~ "entOS" ]]; then
    ## is it 7.x
    if [[ "${os_rel}" =~ " 7." ]]; then
        os_vers="c7"
    else
        if [[ "${os_rel}" =~ " 6.8" || "${os_rel}" =~ " 6.9" || "${os_rel}" =~ " 6.10" ]]; then
            os_vers="c6"
        else
            os_vers="no"
        fi
    fi
else
    if [[ "${os_rel}" =~ "cientific" ]]; then
        ## is it 6.4 or above
        if [[ "${os_rel}" =~ " 6.4" || "${os_rel}" =~ " 6.5" || "${os_rel}" =~ " 6.6" || "${os_rel}" =~ " 6.7" || "${os_rel}" =~ " 6.8" || "${os_rel}" =~ " 6.9" ]]; then
            os_vers="s6"
        else
            os_vers="no"
        fi
    fi
fi


if [[ "${os_vers}" == "no" ]]; then
    echo "  FAIL : Disk encryption is NOT supported on this OS: ${os_rel}"
    echo ""
    exit 1
fi

if [[ "${os_vers}" == "c7" ]]; then
    ## verify Clevis is setup
    clevis_num=$( systemctl list-unit-files | grep -c clevis )
    clevis_ok=$( systemctl list-unit-files | grep clevis | grep -c enabled )
    if [[ "${clevis_num}" -ge "2" ]]; then
        ## packages are installed
        if [[ "${clevis_ok}" -ge "1" ]]; then
            ## packages are enabled
            echo "  OK : Clevis packages installed and enabled"
        else
            echo "  FAIL : clevis-luks-askpass.path is NOT enabled"
            echo ""
            exit 1
        fi
    else
        echo "  FAIL : Check that Clevis packages are installed and enabled"
        echo ""
        exit 1
    fi
else
    echo "  Note: NBDE (clevis/tang) is NOT supported on this OS: ${os_rel}"
fi

errors=""
## find encrypted VMs with autostart set, which are not running, and start them
lvm_list=$( lsblk | grep ENCR | sed 's/.*ENCR/ENCR/' | awk '{print $1}' | sed 's/--/-/g' | sort -n | xargs )
if [[ -z ${lvm_list} ]]; then
    ## no Encrypted disks found, next for loop will be skipped
    echo ""
    echo "#INFO# No Encrypted disks found on this hyper"
fi

## create a list of related VMs
vm_list=""
for lvm in ${lvm_list} ; do
    vm0=$( echo ${lvm} | sed 's/ENCR-//' )
    ## verify VM exists; LVM might be for a data disk
    vm_exist=$( virsh list --all | grep -c " ${vm0} " )
    if [[ "${vm_exist}" -eq "1" ]]; then
        ## it is a VM disk
        vm_list+=" ${vm0}"
    fi
done

## go thru the VM list and check the encryption process was completed
for vm in ${vm_list} ; do
    echo ""
    echo "Checking VM : ${vm}"
    ## is the VM up and set to autostart ?
    vm_auto=$( virsh list --autostart --all | grep -c " ${vm} " )
    vm_up=$( virsh list --autostart --all | grep "running" | grep -c " ${vm} " )
    if [[ "${vm_auto}" -ge "1" ]]; then
        ## VM is set for autostart
        if [[ "${vm_up}" -ge "1" ]]; then
            ## VM is up
            echo "  OK : VM is up"
        else
            echo "  WARNING - VM is not up:"
            virsh list --autostart --all | grep " ${vm} "
            errors+=" vm"
        fi
    else
        echo "  WARNING - VM is NOT set for autostart:"
        virsh list --autostart --all
        errors+=" vm_autostart"
    fi

    ## check VM for all disks
    vm_disks=$( virsh dumpxml ${vm} | grep "/dev/" | grep ${vm} | sed 's/...$//' | sed 's/.*\///' | sed 's/open-//' | xargs )
    for disk in ${vm_disks} ; do
        lvm=$( echo "ENCR-${disk}" )
        echo "+ LVM : ${lvm}"
        dev_lvm=$( lvs | grep " ${lvm} " | awk '{print $2}' )
        open_lvm=$( echo ${lvm} | sed 's/ENCR/open/' )
        open_num=$( lsblk | grep -c "${open_lvm} " )
        if [[ "${open_num}" -ne "1" ]]; then
            ## disk is not open
            echo "    WARNING - encrypted disk is not open: ${open_lvm}"
            errors+=" lvm_open"
        fi

        if [[ "${os_vers}" == "c7" ]]; then
            ## check if the tang servers are set up correctly
            encr_slots=$( luksmeta show -d /dev/${dev_lvm}/${lvm} 2>&1 | grep -v inactive | grep -v empty | awk '{print $1}' | xargs )
            num_slots=$( echo ${encr_slots} | wc -w )
            if [[ "${num_slots}" -ge "2" ]]; then
                ## at least 2 slots are in use - list the Tang servers
                echo "    Tang servers in use:"
                for slot in ${encr_slots} ; do
                    luksmeta load -d /dev/${dev_lvm}/${lvm} -s ${slot} | jose b64 dec -i- | json_reformat 2>&1 | grep url | awk '{print "      " $2}' | sed 's/"//g'
                done
            else
                ## not enough Tang slots used
                echo "    ERROR - more Tang slots need to be set up:"
                luksmeta show -d /dev/${dev_lvm}/${lvm} 2>&1 | awk '{print "     " $0}'
                errors+=" tang"
            fi
        else
            echo "      # NOTICE # after a hyper reboot, this disk needs to be MANUALLY opened before the VM can start"
        fi

        echo "    Disk for the VM to mount: /dev/mapper/${open_lvm} "
        encr=$( virsh dumpxml ${vm} | grep -c "/dev/mapper/${open_lvm}" )
        if [[ "${encr}" -ge "1" ]]; then
            ## VM has an encrypted disk
            echo "    OK : VM is using the encrypted disk"
        else
            ## no encrypted disk found
            echo "  WARNING - VM is NOT using the encrypted disk"
            errors+=" vm_disk"
        fi

        ## check /etc/crypttab
        if [[ -f /etc/crypttab ]]; then
            ## crypttab exists
            crypt_tab=$( grep ${open_lvm} /etc/crypttab | grep "none" | grep "_netdev" | grep -c "/dev/${dev_lvm}/${lvm}" )
            if [[ "${crypt_tab}" -ge "1" ]]; then
                ## entry is probably OK
                echo "    OK : Encrypted LVM is in /etc/crypttab"
            else
                echo "  ERROR - /etc/crypttab is not correct"
                errors+=" crypttab_entry"
            fi
        else
            echo "  ERROR - /etc/crypttab does NOT exist"
            errors+=" crypttab"
        fi

        ## check for original LVM disk
        orig_lvm=$( echo ${open_lvm} | sed 's/open-//' )
        orig_disk=$( lvs | grep -c " ${orig_lvm} ")
        if [[ "${orig_disk}" -ge "1" ]]; then
            ## original LVM still exists
            echo "  WARNING - original LVM still exists: ${dev_lvm}/${orig_lvm}"
            errors+=" orig_lvm"
        fi

    done

done
echo ""

if [[ "${os_vers}" == "c7" ]]; then
    ## check for the cronjob/script
    if [[ -f /usr/local/sbin/delayed_encrypted_autostart.sh ]]; then
        ## file exists
        cron_tab=$( crontab -l | grep "/usr/local/sbin/delayed_encrypted_autostart.sh" | grep -c -v "#" )
        if [[ "${cron_tab}" -ge "1" ]]; then
            ## crontab entry is probably ok
            echo "  OK : /usr/local/sbin/delayed_encrypted_autostart.sh is in crontab"
        else
            echo "  ERROR - NOT active in crontab: /usr/local/sbin/delayed_encrypted_autostart.sh"
            errors+=" crontab_entry"
        fi
    else
        echo "  ERROR - script is missing: /usr/local/sbin/delayed_encrypted_autostart.sh"
        errors+=" auto_script"
    fi
fi

echo ""

## Verbose list of errors
if [[ "${1}" == "-v" ]]; then
    echo "Errors found: ${errors}"
    echo ""
fi

## print Warning if there were errors
if [[ -n ${errors} ]]; then
    echo "FAIL : Please resolve all Errors and Warnings above..."
    echo ""
    exit 1
else
    echo "PASS : VM Encryption checks have all passed"
    echo ""

fi

exit 0

