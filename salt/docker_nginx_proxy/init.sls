docker_nginx_proxy:
  docker_container.running:
    - name: nginx_proxy
    - image: jwilder/nginx-proxy:latest
    - auto_remove: True
    - binds:
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
