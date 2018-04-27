base:
  '*':
    - salt_minion
    - swap

  'not bootstrap':
    - ufw
    - freeipa.client

  'mcp or bootstrap':
    - salt_master
    - docker

  'mcp':
    - salt_cloud
    - docker_network_proxy
    - jenkins
    - freeipa.server
    - traefik.import_freeipa_certs
    - traefik
    - legacy_magbot
    - slack_irc
