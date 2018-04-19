master_domain: magfest.net
master_address: saltmaster.magfest.net

mine_functions:
  external_ip:
    - mine_function: network.interface_ip
    - eth0
  internal_ip:
    - mine_function: network.interface_ip
    - eth1

ufw:
  enabled:
    True
  applications:
    OpenSSH:
      enabled: True
