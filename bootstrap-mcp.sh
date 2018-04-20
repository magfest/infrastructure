#! /bin/bash

# This script will bootstrap and configure the salt-master server
# used to manage the entire MAGFest IT infrastructure.

# Download the infrastructure code
rm -rf /tmp/infrastructure
git clone --depth 1 https://github.com/magfest/infrastructure.git /tmp/infrastructure

# Change into our temp infrastructure bootstrap dir
cd /tmp/infrastructure

# Install SaltStack master and minion
curl -o bootstrap-salt.sh -L https://raw.githubusercontent.com/saltstack/salt-bootstrap/develop/bootstrap-salt.sh
sh bootstrap-salt.sh -i 'mcp' -L -M -P git develop

# Preseed mcp's minion key
salt-key --gen-keys='mcp'
cp mcp.pub /etc/salt/pki/master/minions/mcp
cp mcp.pem /etc/salt/pki/minion/minion.pem
cp mcp.pub /etc/salt/pki/minion/minion.pub

# Run salt locally to configure a minimal mcp
salt-call --local --id='bootstrap' --file-root=salt --pillar-root=pillar state.highstate

# Restart the services
/etc/init.d/salt-master restart
/etc/init.d/salt-minion restart

# Next steps
echo ''
echo '================================'
echo ''
echo ''
echo 'Done! Please update the files under /srv/secret/pillar with secret keys/passwords and run the following command:'
echo ''
echo '    salt mcp state.apply'
echo ''
