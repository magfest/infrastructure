docker_intranet:
  docker_network.present:
    - require:
      - sls: docker
