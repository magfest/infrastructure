#! /bin/bash

# This script will bootstrap and configure the salt-master server
# used to manage the entire MAGFest IT infrastructure.

# Download the infrastructure code
git clone --depth 1 https://github.com/magfest/infrastructure.git /srv/infrastructure

# Change into our temp infrastructure bootstrap dir
cd /srv/infrastructure

# Install SaltStack master and minion
curl -o /tmp/bootstrap-salt.sh -L https://bootstrap.saltstack.com
sh /tmp/bootstrap-salt.sh -i 'mcp' -L -M -P git develop

# Preseed mcp's minion key
salt-key --gen-keys='mcp'
cp mcp.pub /etc/salt/pki/master/minions/mcp
cp mcp.pem /etc/salt/pki/minion/minion.pem
cp mcp.pub /etc/salt/pki/minion/minion.pub

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
echo 'Done! Please update the files under /srv/data/secret/pillar with secret keys/passwords and run the following command:'
echo ''
echo '    salt mcp state.apply'
echo ''
