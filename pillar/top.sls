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
    - freeipa
    - freeipa_secret
