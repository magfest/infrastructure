{%- import_yaml 'defaults.sls' as defaults -%}

ufw:
  sysctl:
    forwarding: 1

  services:
    http:
      protocol: tcp
      comment: Public HTTP

    https:
      protocol: tcp
      comment: Public HTTPS

    9200:
      comment: ELK
      from_addr:
        - 10.0.0.0/8  # private network
        - 159.65.162.238  # magstock8.uber.magfest.org
        - 159.65.164.228  # west2018.uber.magfest.org
        - 165.227.110.177  # labs2018.uber.magfest.org
        - 67.205.144.195  # super2018.uber.magfest.org
        - 67.205.153.181  # archive.uber.magfest.org
        - 67.205.168.250  # labs2.uber.magfest.org

    '*':
      deny: True
      protocol: any
      from_addr: {{ defaults.ip_blacklist }}
