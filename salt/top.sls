base:
  '*':
    - salt_minion
    - ufw
  'salt-master':
    - salt_master
    - salt_cloud
