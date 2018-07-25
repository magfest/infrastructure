{%- from 'reggie/init.sls' import env, private_ip -%}
{%- set glusterfs_servers = salt.saltutil.runner('mine.get', tgt='*reggie* and G@roles:files and G@env:' ~ env, fun='internal_ip', tgt_type='compound').items() -%}
{%- set glusterfs_servers_count = glusterfs_servers|length -%}

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
    24007:
      comment: GlusterFS Server 24007
    24008:
      comment: GlusterFS Server 24008
    49152:
      comment: GlusterFS Brick


glusterfs:
  server:
    enabled: True
    service: glusterd
    peers:
      {%- for server, addr in glusterfs_servers %}
      - {{ addr }}
      {%- endfor %}
    volumes:
      reggie_volume:
        storage: /srv/glusterfs/reggie_volume
        {% if glusterfs_servers_count > 1 %}replica: {{ glusterfs_servers_count }}{% endif %}
        bricks:
          {%- for server, addr in glusterfs_servers %}
          - {{ addr }}:/srv/glusterfs/reggie_volume
          {%- endfor %}
