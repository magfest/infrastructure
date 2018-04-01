#! /bin/bash

git clone https://github.com/magfest/infrastructure-secret.git secret
curl -L https://bootstrap.saltstack.com | sudo sh -s -- -P -M stable
salt-call --local --id=salt-master --file-root=salt --pillar-root=pillar
