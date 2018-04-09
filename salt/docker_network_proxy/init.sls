docker_network_external:
  docker_network.present:
    - internal: False
    - require:
      - sls: docker

docker_network_internal:
  docker_network.present:
    - internal: True
    - require:
      - sls: docker
