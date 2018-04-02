base:
  '*':
    - defaults

  'not bootstrap':
    - ufw

  'bootstrap or salt-master':
    - salt_master
    - salt_cloud
