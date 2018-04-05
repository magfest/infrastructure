docker_nginx:
  docker_container.running:
    - name: nginx
    - image: nginx:latest
    - restart_policy: unless-stopped
    - auto_remove: True
    - ports: 80,443
    - port_bindings: 80:80,443:443
    - networks:
      - docker_internal_network
    - require:
      - pip install docker
      - docker_internal_network
