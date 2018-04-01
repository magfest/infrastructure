#! /bin/bash

git clone --depth 1 https://github.com/magfest/infrastructure-secret.git .secret
rsync -avhu --progress --exclude '.git' .secret/ ./
curl -L https://bootstrap.saltstack.com | sudo sh -s -- -P -M stable
salt-call --id=salt-master --file-root=salt --pillar-root=pillar state.highstate
salt-key -y -a salt-master
