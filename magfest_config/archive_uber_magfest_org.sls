{%- import_yaml 'defaults.sls' as defaults -%}

ufw:
  services:
    http:
      protocol: tcp
      comment: Public HTTP

    https:
      protocol: tcp
      comment: Public HTTPS

    '*':
      deny: True
      protocol: any
      from_addr: {{ defaults.ip_blacklist }}
