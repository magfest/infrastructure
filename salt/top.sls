base:
  '*':
    - defaults
    - ufw
  'salt-master':
    - salt_master
    - salt_cloud
