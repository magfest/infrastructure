{%- from 'reggie/init.sls' import private_ip -%}

include:
  - reggie


ufw:
  enabled: True

  settings:
    ipv6: False

  sysctl:
    ipv6_autoconf: 0

  applications:
    OpenSSH:
      limit: True
      to_addr: {{ private_ip }}

  services:
    6379:
      protocol: tcp
      comment: Redis


redis:
  pass: reggie
  port: 6379
  bind: {{ private_ip }}
