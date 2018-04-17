base:
  '*':
    - defaults

  'bootstrap or salt-master':
    - salt_master
    - salt_master_secret

  'salt-master':
    - digitalocean
    - digitalocean_secret
    - letsencrypt

  'freeipa*':
    - freeipa
    - freeipa_secret

  'freeipa-replica':
    - freeipa_replica
    - freeipa_replica_secret
