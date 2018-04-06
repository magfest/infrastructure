docker_nginx_proxy:
  docker_container.running:
    - name: nginx_proxy
    - image: jwilder/nginx-proxy:latest
    - auto_remove: True
    - binds:
      - {{ salt['pillar.get']('data_path') }}/letsencrypt/etc/letsencrypt/live:/etc/nginx/certs
    - ports: 80,443
    - port_bindings:
      - 80:80
      - 443:443
    - networks:
      - docker_intranet
    - require:
      - docker_network: docker_intranet
      - sls: letsencrypt
