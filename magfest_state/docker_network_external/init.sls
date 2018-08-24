# ============================================================================
# Installs an external Docker network named "docker_network_external"
# ============================================================================

docker_network_external:
  docker_network.present:
    - internal: False
    - require:
      - sls: docker
