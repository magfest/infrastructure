base:
  '*':
    - salt_minion
    - rsyslog
    - sshd
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
    - freeipa.server
    - jenkins.import_freeipa_certs
    - jenkins
    - traefik.import_freeipa_certs
    - traefik
    - legacy_deploy
    - legacy_magbot
    - legacy_magbot.deploy_logs
    - slack_irc
