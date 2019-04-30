remove the hostfile
create a file with your hostlist
create a symlink that points to the hostfile:
ln -s <my file> hostlist
verify the hostlist is accessible: cat ./hostfile
change directory to plays and run your Ansible playbook
