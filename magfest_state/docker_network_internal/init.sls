# ============================================================================
# Installs an internal Docker network named "docker_network_internal"
# ============================================================================

docker_network_internal:
  docker_network.present:
    - internal: True
    - require:
      - sls: docker
