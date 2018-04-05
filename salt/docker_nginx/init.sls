docker_nginx:
  docker_container.running:
    - name: nginx
    - image: nginx:latest
    - auto_remove: True
    - ports: 80,443
    - port_bindings:
      - 80:80
      - 443:443
    - require:
      - pip install docker
      - docker_internal_network
