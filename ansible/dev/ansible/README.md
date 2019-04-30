# ansible

Ansible Playbooks and Roles for Jasper IOT

# Project:	    Ansible Playbook for Hardening VM configurations
# Author:	      Walter G. da Cruz
# Date:		      2019.02.17
# Version:      2019.03.15a
# 2019.03.15a:  Added setup_vm_autostart.sh script
# 2019.03.11a:  Updated latest version of verify_encrypted_VMs.sh
# 2019.03.08a:  Updated /etc/security/pwquality.conf on CentOS 7 
# 2019.03.07b:  Fixed Duplicated entries in /etc/security/pwquality.conf file
# 2019.03.06a:  Fixed issue with verify_encrypted_VMs
# 2019.03.05c:  update_nrpe.yml has an issue that copy original configuration failed if the file already exists. Fixed
# 2019.03.03b:  Added Pub key for Epel
# 2019.03.03a:  Fix issue with AD login accounts affected by IPTables, added update_root and update_nrpe playbooks
# 2019.02.25a:  Updated create_users playbook.  I found we need to update /etc/pam.d/ssh file
# Description:
# Collection of Ansible Playbook for Hardening VM Configuration according to CIS-BENCHMARK
# Note: The Ansible playbooks can apply to many hosts at the time, depending of the hostfile list.  The reason we use a "FOR" loop as we do 1 host at the time is, many hosts have misconfiguration (especially YUM repo). That stops the whole process. Also, we are replacing SUDO and requesting users to upgrade their password.  By running a "FOR" loop, we can identify which host we need to update our password.
#
# Requirements:
# 1. Have Ansible version 2.2 minimum.  Most of the ansible playbooks use systemd, which started on Ansible Version 2.2
# 2. If you need to run the CIS-Benchmark, you'll need to install java-headless version 1.8 or later.  It won't run on old Java Versions
# 3. Have lsb command installed.  The command will tell us which version of CentOS/Scientific Linux we are running (5, 6, 7, etc.)
# 4. Note: CentOS 5 comes with python 2.4 by default.  Ansible playbook requires python 2.6 at minimum.  We need to install python2.6 on CentOS 5 hosts.  The centos5_update_python2.sh will take care about it.
# If the host is Version 6, it will ignore this request.
##############################################################################################

Usage:
1. First of all, you need to edit ./ansible/plays/hosts/hostfile.  We suggest you create a separate file under ./ansible/plays/hosts directory and the hostfile will be a symlink.  For instance:
  a. cd ./ansible/plays/hosts/
  b. rm -f hostfile
  c. cat <host> > pd4-kestrels
  d. ln -s pd4-kestrels hostfile
2. Go back one directory and execute ./main.sh Bash shell script.  You'll get prompt what type of application you want to deploy.  The Choice are: aaa, cgw, kestrel, mail, rediscluster, sftp, splunk, yum.  The reason of this prompt is, each application requires a particular port open. This setting only affects the iptables playbook.
3. The main.sh is a shell wrapper that calls the following shell scripts in this particular order:
    ./centos5_update_python2.sh $i # Check if host is a CentOS version 5.  If it is, it will install python2.6 (required to run Ansible). Otherwise, it will ignore it
    ./initial_setup.sh $i		# Initial hardening setup. If the password is too old and you didn't change it for at least 6 months.  If you try to login to the host, It will ask you to change  your password.
    ./update_sudo.sh $i			# Update SUDO password, no more NOPASSWD entries.  The sudo will be available for 1 hour.
    ./yum_security_updates.sh $i	# Run yum updade --security for security packages only.  That might include the Kernel
    ./cis_benchmark.sh $i		# Main Hardening script
    ./iptables.sh $i $APP_TYPE		# Install IP Tables depending of what type of application you are running.  Still allows ping, snmp, nrpe, dns, yum, and ntp services.
    ./tag_encrypted.sh $i		# Add an entry into /etc/issue saying the VM is encrypted
    ./reboot_host.sh $i			# Once everythin is done, we reboot the VM and make sure when it comes back, everything is working.

4. The shell scripts listed above are wrappers to the Ansible playbooks with the same name. For instance, iptables.sh shell script points to iptables.yml Ansible Playbook.
5. Each of the shell scripts can be run independently.  They will prompt for which host you want to do.
