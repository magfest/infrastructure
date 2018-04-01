#! /bin/bash

CURRENT_DIR=`pwd`

# Download the infrastructure code
git clone --depth 1 https://github.com/magfest/infrastructure.git /tmp/infrastructure
git clone --depth 1 https://github.com/magfest/infrastructure-secret.git /tmp/infrastructure-secret

# Copy the secrets into our temp infrastructure dir
cd /tmp/infrastructure
rsync -avh --progress --ignore-existing --exclude '.git' /tmp/infrastructure-secret/ ./

# Install SaltStack master and minion
curl -L https://bootstrap.saltstack.com | sh -s -- -i 'salt-master' -P -M stable

# Run salt locally to configure salt-master
salt-call --local --id='salt-master' --file-root=salt --pillar-root=pillar state.highstate

# Restart the services
/etc/init.d/salt-master restart
/etc/init.d/salt-minion restart

# Tell the salt-master's minion to configure itself
salt 'salt-master' test.ping
salt-key -y -a 'salt-master'
salt 'salt-master' state.highstate

# Cleanup
cd $CURRENT_DIR
rm -r /tmp/infrastructure
rm -r /tmp/infrastructure-secret
