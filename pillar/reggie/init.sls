{%- set certs_dir = '/etc/ssl/certs' -%}
{%- set private_ip = salt['network.interface_ip']('eth0' if salt['grains.get']('is_vagrant') else 'eth1') -%}

reggie:
  plugins:
    magprime:
      name: magprime
      source: https://github.com/magfest/magprime.git


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


# haproxy:
#   proxy:
#     enabled: True
#     mode: http
#     logging: syslog
#     maxconn: 1024
#     timeout:
#       connect: 5000
#       client: 50000
#       server: 50000
#     listen:
#       reggie_http_to_https_redirect:
#         mode: http

#         http_request:
#           - action: 'redirect location https://%H:4443%HU code 301'

#         binds:
#         - address: 0.0.0.0
#           port: 8000

#       reggie_load_balancer:
#         mode: http
#         force_ssl: True

#         acl:
#           header_location_exists: 'res.hdr(Location) -m found'
#           path_starts_with_app: 'path_beg -i /app'
#           path_starts_with_profiler: 'path_beg -i /profiler'

#         http_response:
#           - action: 'replace-value Location https://([^/]*)(?:/app)?(.*) https://\1:4443\2'
#             condition: 'if header_location_exists'

#         http_request:
#           - action: 'set-path /app/%[path]'
#             condition: 'if !path_starts_with_app !path_starts_with_profiler'

#         binds:
#         - address: 0.0.0.0
#           port: 4443
#           ssl:
#             enabled: True
#             pem_file: {{ certs_dir }}/localhost.pem

#         servers:
#         - name: reggie_backend
#           host: 127.0.0.1
#           port: 443
#           params: ssl verify none


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
          cert_file: {{ certs_dir }}/localhost.crt
          key_file: {{ certs_dir }}/localhost.key
        host:
          name: {{ salt['grains.get']('id') }}
          port: 443


ssh:
  password_authentication: True
  permit_root_login: False
