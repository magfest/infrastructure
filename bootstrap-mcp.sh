#!/bin/bash

# This script will bootstrap and configure the salt-master server
# used to manage the entire MAGFest IT infrastructure.

set -x  # Start echoing commands to stdout

# Install SaltStack master and minion
curl -o /tmp/bootstrap-salt.sh -L https://bootstrap.saltstack.com
sh /tmp/bootstrap-salt.sh -i 'mcp' -L -M -P git 'v2018.3.2'

# Preseed mcp's minion key
cd /tmp
salt-key --gen-keys='mcp'
cp mcp.pub /etc/salt/pki/master/minions/mcp
cp mcp.pem /etc/salt/pki/minion/minion.pem
cp mcp.pub /etc/salt/pki/minion/minion.pub
rm mcp.pem
rm mcp.pub

# Download or update the infrastructure code
if [ -d "/srv/infrastructure/.git" ]; then
    cd /srv/infrastructure
    git pull
else
    git clone --depth 1 https://github.com/magfest/infrastructure.git /srv/infrastructure
    cd /srv/infrastructure
fi

# Run salt locally to configure a minimal mcp
salt-call --local --id='bootstrap' --file-root=magfest_state --pillar-root=magfest_config state.highstate

# Restart the services
systemctl restart salt-master
systemctl restart salt-minion

# Give the services a chance to start up
sleep 5

# Next steps
set +x  # Stop echoing commands to stdout
echo ""
echo "================================"
echo ""
echo "Done! Please update the files under /srv/data/secret/infrastructure/magfest_config with your" \
     "secret keys/passwords and run the following command:"
echo ""
echo "    salt mcp state.apply"
echo ""
echo "NOTE: Some of the services take a few minutes to initialize. You can" \
     "follow the progress of the Free IPA installation with the following" \
     "command:"
echo ""
echo "    tail -f /srv/data/freeipa/ipa-data/var/log/ipaserver-install.log"
echo ""
