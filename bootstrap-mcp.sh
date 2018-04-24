#! /bin/bash

# This script will bootstrap and configure the salt-master server
# used to manage the entire MAGFest IT infrastructure.

# Download the infrastructure code
git clone --depth 1 https://github.com/magfest/infrastructure.git /srv/infrastructure

# Change into our temp infrastructure bootstrap dir
cd /srv/infrastructure

# Install SaltStack master and minion
# TODO: Commit 19ec7b6de18256dd9b52919ef9c0d8b39d874277 contains a fix for
#       docker_containers that we need, and newer versions contain bugs that
#       we can't work around. Update this to use "stable" once the next
#       version after v2018.3.0 is released.
curl -o /tmp/bootstrap-salt.sh -L https://bootstrap.saltstack.com
sh /tmp/bootstrap-salt.sh -i 'mcp' -L -M -P git 19ec7b6de18256dd9b52919ef9c0d8b39d874277

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
echo 'Done! Please update the files under /srv/data/secret/pillar with' \
     'secret keys/passwords and run the following command:'
echo ''
echo '    salt mcp state.apply'
echo ''
echo 'NOTE: There may be some failures the first time the command is run.' \
     'Some of the services take a few minutes to initialize. If there are' \
     'any errors, please wait a moment and try again.'
