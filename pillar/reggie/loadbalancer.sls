{%- set env = salt['grains.get']('env') -%}
{%- set certs_dir = '/etc/ssl/certs' -%}
{%- set private_ip = salt['network.interface_ip']('eth1') -%}

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
    http:
      protocol: tcp
    https:
      protocol: tcp


haproxy:
  proxy:
    enabled: True
    mode: http
    logging: syslog
    maxconn: 1024
    timeout:
      connect: 5000
      client: 50000
      server: 50000
    listen:
      reggie_http_to_https_redirect:
        mode: http

        http_request:
          - action: 'redirect location https://%H:443%HU code 301'

        binds:
          - address: 0.0.0.0
            port: 80

      reggie_load_balancer:
        mode: http
        force_ssl: True

        acl:
          header_location_exists: 'res.hdr(Location) -m found'
          path_starts_with_app: 'path_beg -i /reggie'
          path_starts_with_profiler: 'path_beg -i /profiler'

        http_response:
          - action: 'replace-value Location https://([^/]*)(?:/reggie)?(.*) https://\1:443\2'
            condition: 'if header_location_exists'

        http_request:
          - action: 'set-path /reggie/%[path]'
            condition: 'if !path_starts_with_app !path_starts_with_profiler'

        binds:
          - address: 0.0.0.0
            port: 443
            ssl:
              enabled: True
              pem_file: {{ certs_dir }}/localhost.pem

        servers:
        {%- for server, addr in salt.saltutil.runner('mine.get', tgt='*reggie* and G@roles:web and G@env:' ~ env, fun='internal_ip', tgt_type='compound').items() %}
          - name: {{ server }}
            host: {{ addr }}
            port: 443
            params: ssl verify none
        {% endfor -%}
