{%- set certs_dir = '/etc/ssl/certs' -%}
{%- set minion_id = salt['grains.get']('id') %}
{%- set private_interface = 'eth0' if salt['grains.get']('is_vagrant') else 'eth1' -%}
{%- set private_ip = salt['network.interface_ip'](private_interface) -%}
{%- set arbiter_ip = salt['mine.get']('G@file-arbiter', private_interface) -%}

include:
  - reggie


glusterfs:
  client:
    enabled: True
    volumes:
      reggie_volume:
        path: /srv/reggie/data/uploaded_files
        server: {{ arbiter_ip }}
        user: vagrant
        group: vagrant


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
          host: localhost
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
