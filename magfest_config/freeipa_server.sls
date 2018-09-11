{% import_yaml 'defaults.sls' as defaults %}
{% set private_ip = salt['grains.get']('ip4_interfaces')[salt['grains.get']('private_interface', 'eth1')][0] %}


freeipa:
  server:
    enabled: True
    realm: MAGFEST.ORG
    domain: magfest.org
    hostname: {{ salt['grains.get']('fqdn', '') }}


ssh:
  password_authentication: True
  permit_root_login: False


ufw:
  enabled: True

  settings:
    ipv6: False

  sysctl:
    forwarding: 1
    ipv6_autoconf: 0

  applications:
    OpenSSH:
      limit: True
      to_addr: {{ private_ip }}
      comment: Private network SSH

  services:
    http:
      protocol: tcp
      comment: Public HTTP
    https:
      protocol: tcp
      comment: Public HTTPS
    88:
      protocol: any
      comment: Kerberos
    464:
      protocol: any
      comment: Kerberos kpasswd
    389:
      protocol: tcp
      comment: LDAP
    636:
      protocol: tcp
      comment: LDAP SSL
    7389:
      protocol: tcp
      to_addr: {{ private_ip }}
      comment: FreeIPA Replica
    8443:
      protocol: tcp
      to_addr: {{ private_ip }}
      comment: FreeIPA Replica Bug  # https://pagure.io/freeipa/issue/6016
    "9443:9445":
      protocol: tcp
      to_addr: {{ private_ip }}
      comment: FreeIPA Replica Config
