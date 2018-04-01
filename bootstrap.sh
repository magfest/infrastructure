#! /bin/bash

git clone --depth 1 https://github.com/magfest/infrastructure-secret.git .secret
rsync -avh --progress --ignore-existing --exclude '.git' .secret/ ./
curl -L https://bootstrap.saltstack.com | sudo sh -s -- -P -M stable
salt-call --local --id=salt-master --file-root=salt --pillar-root=pillar state.highstate
salt-key -y -a salt-master
