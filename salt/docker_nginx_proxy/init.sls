docker_nginx_proxy:
  docker_container.running:
    - name: nginx_proxy
    - image: jwilder/nginx-proxy:latest
    - auto_remove: True
    - ports: 80
    - port_bindings:
      - 80:80
    - networks:
      - docker_intranet
    - require:
      - docker_network: docker_intranet
