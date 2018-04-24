#! /bin/bash

# This script will bootstrap and configure the salt-master server
# used to manage the entire MAGFest IT infrastructure.

# Echo commands to stdout
set -x

# Install SaltStack master and minion
# TODO: Commit 19ec7b6de18256dd9b52919ef9c0d8b39d874277 contains a fix for
#       docker_containers that we need, and newer versions contain bugs that
#       we can't work around. Update this to use "stable" once the next
#       version after v2018.3.0 is released.
curl -o /tmp/bootstrap-salt.sh -L https://bootstrap.saltstack.com
sh /tmp/bootstrap-salt.sh -i 'mcp' -L -M -P git 19ec7b6de18256dd9b52919ef9c0d8b39d874277

# Preseed mcp's minion key
cd /tmp
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
echo ""
echo "================================"
echo ""
echo ""
echo "Done! Please update the files under /srv/data/secret/pillar with your" \
     "secret keys and passwords."
echo ""
echo "Some of the services take a few minutes to initialize. You can follow" \
     "the progress of the Free IPA installation with the following command:"
echo ""
echo "    tail -f /srv/data/freeipa/ipa-data/var/log/ipaserver-install.log"
echo ""
echo "Once Free IPA is installed, you can finish configuring mcp with the" \
     "following command:"
echo ""
echo "    salt mcp state.apply"
echo ""
