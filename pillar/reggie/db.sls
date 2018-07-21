{%- set private_ip = salt['network.interface_ip']('eth1') -%}
{%- set db_name = salt['pillar.get']('reggie:db:name') -%}
{%- set db_username = salt['pillar.get']('reggie:db:username') -%}

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
    Postgresql:
      to_addr: {{ private_ip }}

  services:
    http:
      protocol: tcp
    https:
      protocol: tcp


postgres:
  use_upstream_repo: False
  pkgs_extra:
    - postgresql-contrib
  manage_force_reload_modules: False
  postgresconf: |
    listen_addresses = '{{ private_ip }}'
  acls:
    - ['local', '{{ db_name }}', '{{ db_username }}']
    - ['hostssl', '{{ db_name }}', '{{ db_username }}', '{{ private_ip }}/24']
