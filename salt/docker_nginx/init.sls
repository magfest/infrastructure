docker_nginx:
  docker_container.absent:
    - force: True
    - name: nginx
    # - image: nginx:latest
    # - ports: 80,443
    # - network_mode: docker_internal_network
    # - networks:
    #   - docker_internal_network
    # - require:
    #   - pip install docker
    #   - docker_internal_network
