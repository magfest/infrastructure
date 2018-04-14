#! /bin/bash

# This script will bootstrap and configure the salt-master server
# used to manage the entire MAGFest IT infrastructure.

# Download the infrastructure code
git clone --depth 1 https://github.com/magfest/infrastructure.git /tmp/infrastructure
git clone --depth 1 https://github.com/magfest/infrastructure-secret.git /tmp/infrastructure-secret

# Change into our temp infrastructure bootstrap dir
cd /tmp/infrastructure/bootstrap

# Install SaltStack master and minion
curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com
sh bootstrap-salt.sh -i 'salt-master' -L -M -P git develop

# Preseed the salt-master's minion key
salt-key --gen-keys='salt-master'
cp salt-master.pub /etc/salt/pki/master/minions/salt-master
cp salt-master.pem /etc/salt/pki/minion/minion.pem
cp salt-master.pub /etc/salt/pki/minion/minion.pub

# Run salt locally to configure a minimal salt-master
salt-call --local --config-dir=/tmp/infrastructure/bootstrap state.highstate

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
