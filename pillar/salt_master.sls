master_address: 127.0.0.1
minion_id: salt-master
data_path: /srv/volumes/data

ssh_keys: {}

ufw:
  enabled:
    True

  applications:
    OpenSSH:
      enabled: True
    Saltmaster:
      enabled: True

  services:
    http:
      protocol: tcp
    https:
      protocol: tcp
    # 50000: # jnlp
    #   protocol: tcp

  sysctl:
    forwarding: 1
