docker_intranet:
  docker_network.present:
    - internal: True
    - require:
      - sls: docker
