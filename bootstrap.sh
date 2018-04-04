#! /bin/bash

# This script will bootstrap and configure the salt-master server
# used to manage the entire MAGFest IT infrastructure.

# Download the infrastructure code
git clone --depth 1 https://github.com/magfest/infrastructure.git /tmp/infrastructure
git clone --depth 1 https://github.com/magfest/infrastructure-secret.git /tmp/infrastructure-secret

# Copy the secrets into our temp infrastructure dir
cd /tmp/infrastructure
rsync -avh --progress --ignore-existing --exclude '.git' /tmp/infrastructure-secret/ ./

# Install SaltStack master and minion
curl -L https://bootstrap.saltstack.com | sh -s -- -i 'salt-master' -L -M -P stable

# Preseed the salt-master's minion key
salt-key --gen-keys='salt-master'
cp salt-master.pub /etc/salt/pki/master/minions/salt-master
cp salt-master.pem /etc/salt/pki/minion/minion.pem
cp salt-master.pub /etc/salt/pki/minion/minion.pub

# Run salt locally to configure a minimal salt-master
salt-call --local --id='bootstrap' --file-root=salt --pillar-root=pillar state.highstate

# Restart the services
/etc/init.d/salt-master restart
/etc/init.d/salt-minion restart

# Give the services a chance to start up
sleep 10

# Tell the salt-master's minion to fully configure itself
salt 'salt-master' test.ping
salt 'salt-master' state.highstate

# Cleanup
cd ~
rm -rf /tmp/infrastructure
rm -rf /tmp/infrastructure-secret
