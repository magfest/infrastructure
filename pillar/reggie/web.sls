{%- from 'reggie/init.sls' import env, minion_id, private_ip, certs_dir, mounted_data_dir -%}
{%- set glusterfs_ip = salt.saltutil.runner('mine.get', tgt='*reggie* and G@roles:files and G@env:' ~ env, fun='internal_ip', tgt_type='compound').values()|first -%}

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


glusterfs:
  client:
    enabled: True
    volumes:
      reggie_volume:
        path: {{ mounted_data_dir }}
        server: {{ glusterfs_ip }}
        user: reggie
        group: reggie


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
          cert_file: {{ certs_dir }}/{{ minion_id }}.crt
          key_file: {{ certs_dir }}/{{ minion_id }}.key
        host:
          name: {{ minion_id }}
          port: 443
