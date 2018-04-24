#! /bin/bash

# This script will bootstrap and configure the salt-master server
# used to manage the entire MAGFest IT infrastructure.

# Change into tmp dir
cd /tmp

# Install SaltStack master and minion
curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com
sh bootstrap-salt.sh -i 'mcp' -L -M -P stable

# Preseed mcp's minion key
salt-key --gen-keys='mcp'
cp mcp.pub /etc/salt/pki/master/minions/mcp
cp mcp.pem /etc/salt/pki/minion/minion.pem
cp mcp.pub /etc/salt/pki/minion/minion.pub
rm mcp.pem
rm mcp.pub

# Download the infrastructure code
git clone --depth 1 https://github.com/magfest/infrastructure.git /srv/infrastructure
cd /srv/infrastructure

# Run salt locally to configure a minimal mcp
salt-call --local --id='bootstrap' --file-root=salt --pillar-root=pillar state.highstate

# Restart the services
systemctl restart salt-master
systemctl restart salt-minion

# Give the services a chance to start up
sleep 5

# Next steps
echo ''
echo '================================'
echo ''
echo ''
echo 'Done! Please update the files under /srv/data/secret/pillar with' \
     'secret keys/passwords and run the following command:'
echo ''
echo '    salt mcp state.apply'
echo ''
echo 'NOTE: Some of the services take a few minutes to initialize. ' \
     'You may need to run that command a few times before everything ' \
     'is configured correctly.'
