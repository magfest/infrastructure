minion_id: freeipa

freeipa:
  realm: 'magfest.org'
  ds_password: 'password'
  admin_password: 'password'
  hostname: 'ipa-01.magfest.net'
  install_opts: >
    --realm=MAGFEST.ORG
    --domain=ipa.magfest.net
    --ds-password=password
    --admin-password=password
    --no-ntp
    --unattended


ufw:
  enabled:
    True

  applications:
    OpenSSH:
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
    7389: # freeipa_replica
      protocol: tcp
    "9443:9445": # freeipa_replica_config
      protocol: tcp

  sysctl:
    forwarding: 1
