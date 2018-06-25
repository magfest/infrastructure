base:
  '*':
    - salt_minion
    - rsyslog
    - sshd
    - swap

  'not bootstrap':
    - ufw
    - fail2ban
    - freeipa_client

  'mcp or bootstrap':
    - salt_master
    - docker

  'mcp':
    - salt_cloud
    - docker_freeipa
    - docker_jenkins.import_freeipa_certs
    - docker_jenkins
    - docker_redis
    - docker_magbot
    - docker_traefik.import_freeipa_certs
    - docker_traefik
    - legacy_deploy
    - legacy_magbot
    - legacy_magbot.deploy_logs
    - slack_irc
