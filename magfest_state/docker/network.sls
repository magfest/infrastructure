include:
  - docker.install


# ============================================================================
# Creates an internal Docker network named "docker_network_internal"
# ============================================================================

docker_network_internal:
  docker_network.present:
    - internal: True
    - require:
      - sls: docker.install


# ============================================================================
# Creates an external Docker network named "docker_network_external"
# ============================================================================

docker_network_external:
  docker_network.present:
    - internal: False
    - require:
      - sls: docker.install
