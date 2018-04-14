master_address: 127.0.0.1
minion_id: salt-master
data_path: /srv/volumes/data

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
    # 53: # dns
    #   protocol: any
    88: # kerberos
      protocol: any
    464: # kerberos_passwd
      protocol: any
    389: # ldap
      protocol: tcp
    636: # ldapssl
      protocol: tcp
    # 123: # ntp
    #   protocol: udp
    # 7389: # freeipa_replica
    #   protocol: tcp
    # "9443:9445": # freeipa_replica_config
    #   protocol: tcp

  sysctl:
    forwarding: 1
