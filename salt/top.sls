base:
  '*':
    - salt_minion
    - swap

  'not bootstrap':
    - ufw
    - freeipa.client

  'mcp or bootstrap':
    - docker
    - salt_master

  'mcp':
    - salt_cloud
    - docker_network_proxy
    - jenkins
    - freeipa.server
    - traefik.import_freeipa_certs
    - traefik
    - legacy
