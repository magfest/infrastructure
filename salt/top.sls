base:
  '*':
    - salt_minion
    - swap

  'not bootstrap':
    - ufw
    - fail2ban
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
