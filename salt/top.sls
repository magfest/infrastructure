base:
  '*':
    - salt_minion
    - swap
    - fail2ban

  'not bootstrap':
    - ufw
    - freeipa.client

  'mcp or bootstrap':
    - salt_master
    - docker

  'mcp':
    - redis
    - salt_cloud
    - jenkins
    - freeipa.server
    - traefik.import_freeipa_certs
    - traefik
    - legacy_magbot
    - slack_irc
