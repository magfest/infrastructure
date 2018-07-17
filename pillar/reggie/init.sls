{%- set env = salt['grains.get']('env') -%}
{%- set certs_dir = '/etc/ssl/certs' -%}
{%- set minion_id = salt['grains.get']('id') %}
{%- set private_ip = salt['network.interface_ip']('eth0' if salt['grains.get']('is_vagrant') else 'eth1') -%}

{#-
{%- set sessions_ip = salt['mine.get']('*reggie* and G@roles:sessions and G@env:' ~ env, 'internal_ip', tgt_type='compound').values()|first -%}

{%- if 'db' in salt['grains.get']('roles') -%}
  {%- set db_ip = salt['mine.get']('*reggie* and G@roles:db and G@env:' ~ env, 'internal_ip', tgt_type='compound').values()|first -%}
{%- else -%}
  {%- set db_ip = '127.0.0.1' -%}
{%- endif -%}
-#}

reggie:
  db:
    username: reggie
    password: reggie
    name: reggie
    {# host: {{ db_ip }} #}

  plugins:
    magprime:
      name: magprime
      source: https://github.com/magfest/magprime.git

  sideboard:
    config:
      cherrypy:
        engine.autoreload.on: False
        server.socket_host: {{ private_ip }}
        server.socket_port: 8282
        {# tools.sessions.host: {{ sessions_ip }} #}
        tools.sessions.port: 6379
        tools.sessions.password: reggie


# glusterfs:
#   server:
#     enabled: True
#     service: glusterd
#     peers:
#       - {{ private_ip }}
#     volumes:
#       reggie_volume:
#         storage: /srv/glusterfs/reggie_volume
#         bricks:
#           - {{ private_ip }}:/srv/glusterfs/reggie_volume
#   client:
#     enabled: True
#     volumes:
#       reggie_volume:
#         path: /srv/reggie/data/uploaded_files
#         server: {{ private_ip }}
#         user: vagrant
#         group: vagrant


ssh:
  password_authentication: True
  permit_root_login: False


ssl:
  dir: /etc/ssl
  certs_dir: {{ certs_dir }}
