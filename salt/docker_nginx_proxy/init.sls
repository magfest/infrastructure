docker_nginx_proxy:
  docker_container.running:
    - name: nginx_proxy
    - image: jwilder/nginx-proxy:latest
    - auto_remove: True
    - binds:
      - /srv/volumes/data/letsencrypt/etc/letsencrypt/live:/etc/nginx/certs
      - /var/run/docker.sock:/tmp/docker.sock:ro
    - ports: 80
    - port_bindings:
      - 80:80
      - 443:443
    - networks:
      - docker_intranet
    - require:
      - docker_network: docker_intranet
      - sls: letsencrypt
