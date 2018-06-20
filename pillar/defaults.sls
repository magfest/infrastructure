master:
  domain: magfest.net
  address: saltmaster.magfest.net

freeipa:
  realm: 'magfest.org'
  hostname: 'ipa-01.magfest.net'
  ui_domain: 'directory.magfest.net'

mine_functions:
  external_ip:
    - mine_function: network.interface_ip
    - eth0
  internal_ip:
    - mine_function: network.interface_ip
    - eth1

ufw:
  enabled: True

  settings:
    ipv6: False

  sysctl:
    ipv6_autoconf: 0

  applications:
    OpenSSH:
      limit: True
