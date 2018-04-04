base:
  '*':
    - defaults

  'bootstrap':
    - salt_master

  'salt-master':
    - salt_master
    - salt_cloud
    - docker
