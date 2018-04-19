base:
  '*':
    - salt_minion
    - swap

  'not bootstrap':
    - ufw
    - freeipa.client

  'bootstrap or mcp':
    - rng_tools
    - pip
    - docker
    - salt_master

  'mcp':
    - salt_cloud
    - docker_network_proxy
    - jenkins
    - freeipa.server
    - freeipa.export_certs
    - traefik.import_freeipa_certs
    - traefik
