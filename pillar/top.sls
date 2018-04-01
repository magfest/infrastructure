base:
  '*':
    - default
    - salt_minion
  'salt-master':
    - salt_master
    - salt_cloud
    - firewall
