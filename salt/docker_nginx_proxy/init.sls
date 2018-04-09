{{ salt['pillar.get']('data_path') }}/nginx_proxy/etc/nginx/certs/:
  file.directory:
    - mode: 700
    - makedirs: True

docker_nginx_proxy:
  # docker_container.absent:
  #   - name: nginx_proxy
  #   - force: True
  docker_container.running:
    - name: nginx_proxy
    - image: jwilder/nginx-proxy:latest
    - auto_remove: True
    - binds:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - {{ salt['pillar.get']('data_path') }}/nginx_proxy/etc/nginx/certs:/etc/nginx/certs
    - ports: 80,443
    - port_bindings:
      - 80:80
      - 443:443
    - networks:
      - docker_intranet
    - require:
      - docker_network: docker_intranet
