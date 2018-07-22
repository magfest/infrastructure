{%- from 'reggie/init.sls' import env, minion_id, private_ip, certs_dir -%}

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
    https:
      protocol: tcp
      to_addr: {{ private_ip }}


nginx:
  server:
    enabled: True
    bind:
      address: {{ private_ip }}
      ports:
      - 443
    site:
      https_reggie_site:
        enabled: True
        type: nginx_proxy
        name: https_reggie_site
        proxy:
          host: 127.0.0.1
          port: 8282
          protocol: http
        ssl:
          enabled: True
          # engine: letsencrypt
          cert_file: {{ certs_dir }}/{{ minion_id }}.crt
          key_file: {{ certs_dir }}/{{ minion_id }}.key
        host:
          name: {{ minion_id }}
          port: 443
