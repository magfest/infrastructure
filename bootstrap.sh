#! /bin/bash

# This script will bootstrap and configure the salt-master server
# used to manage the entire MAGFest IT infrastructure.

# Download the infrastructure code
git clone --depth 1 https://github.com/magfest/infrastructure.git /tmp/infrastructure

# Change into our temp infrastructure bootstrap dir
cd /tmp/infrastructure/bootstrap

# Install SaltStack master and minion
curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com
sh bootstrap-salt.sh -i 'mcp' -L -M -P git develop

# Preseed mcp's minion key
salt-key --gen-keys='mcp'
cp mcp.pub /etc/salt/pki/master/minions/mcp
cp mcp.pem /etc/salt/pki/minion/minion.pem
cp mcp.pub /etc/salt/pki/minion/minion.pub

# Run salt locally to configure a minimal mcp
salt-call --local --file-root=./salt --pillar-root=./pillar state.highstate

# Restart the services
/etc/init.d/salt-master restart
/etc/init.d/salt-minion restart

# Give the services a chance to start up
sleep 10

# Tell mcp's minion to fully configure itself
salt 'mcp' test.ping
salt 'mcp' state.highstate

# Cleanup
cd ~
rm -rf /tmp/infrastructure
