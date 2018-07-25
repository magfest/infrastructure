{%- from 'reggie/init.sls' import env, private_ip, db_name, db_username, db_password -%}
{%- set db_client_target = '*reggie* and P@roles:(web|worker|scheduler) and G@env:' ~ env -%}

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


postgres:
  use_upstream_repo: False
  pkgs_extra: [postgresql-contrib]
  manage_force_reload_modules: False
  postgresconf: listen_addresses = 'localhost,{{ private_ip }}'

  cluster:
    locale: en_US.UTF-8

  acls:
    - ['local', 'all', 'all']
    - ['host', 'all', 'all', '127.0.0.1/32', 'md5']
    - ['hostssl', 'all', 'all', '{{ private_ip }}/32', 'md5']
    {%- for server, addr in salt.saltutil.runner('mine.get', tgt=db_client_target, fun='internal_ip', tgt_type='compound').items() %}
    - ['hostssl', 'all', 'all', '{{ addr }}/32', 'md5']
    {%- endfor %}

  users:
    {{ db_username }}:
      ensure: present
      password: {{ db_password }}
      createdb: False
      createroles: False
      encrypted: True
      login: True
      superuser: False
      replication: True
      runas: postgres

  databases:
    {{ db_name }}:
      runas: postgres
      template: template0
      encoding: UTF8
      lc_ctype: en_US.UTF-8
      lc_collate: en_US.UTF-8
