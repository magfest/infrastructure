docker_network_proxy:
  docker_network.present:
    - require:
      - sls: docker
