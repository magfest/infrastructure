base:
  '*':
    - defaults

  'bootstrap':
    - salt_master

  'salt-master':
    - salt_master
    - digitalocean
    - letsencrypt
    - freeipa
