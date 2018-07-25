{%- set env = salt['grains.get']('env') -%}
{%- set certs_dir = '/etc/ssl/certs' -%}
{%- set minion_id = salt['grains.get']('id') -%}
{%- set mounted_data_dir = '/srv/mnt/reggie' -%}
{%- set private_ip = salt['grains.get']('ip4_interfaces:eth1')[0] -%}
{%- set sessions_ip = salt.saltutil.runner('mine.get', tgt='*reggie* and G@roles:sessions and G@env:' ~ env, fun='internal_ip', tgt_type='compound').values()|first -%}
{%- set queue_ip = salt.saltutil.runner('mine.get', tgt='*reggie* and G@roles:queue and G@env:' ~ env, fun='internal_ip', tgt_type='compound').values()|first -%}
{%- set db_ip = salt.saltutil.runner('mine.get', tgt='*reggie* and G@roles:db and G@env:' ~ env, fun='internal_ip', tgt_type='compound').values()|first -%}
{%- set db_name = 'reggie' -%}
{%- set db_password = 'reggie' -%}
{%- set db_username = 'reggie' %}


reggie:
  db:
    username: {{ db_username }}
    password: {{ db_password }}
    name: {{ db_name }}
    host: {{ db_ip }}

  plugins:
    ubersystem:
      config:
        mounted_data_dir: {{ mounted_data_dir }}
        secret:
          broker_url: amqp://reggie:reggie@{{ queue_ip }}:5672/reggie
    magprime:
      name: magprime
      source: https://github.com/magfest/magprime.git

  sideboard:
    config:
      cherrypy:
        engine.autoreload.on: False
        server.socket_host: 127.0.0.1
        server.socket_port: 8282
        tools.sessions.host: {{ sessions_ip }}
        tools.sessions.port: 6379
        tools.sessions.password: reggie


ssh:
  password_authentication: True
  permit_root_login: False


ssl:
  dir: /etc/ssl
  certs_dir: {{ certs_dir }}
