docker_network_proxy:
  docker_network.present:
    - internal: True
    - require:
      - sls: docker
