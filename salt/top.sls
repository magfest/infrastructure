base:
  '*':
    - rsyslog
    - sshd
    - swap

  'not *reggie*':
    - salt_minion

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
    - docker_traefik.import_freeipa_certs
    - docker_traefik

  'mcp and not G@is_vagrant:True':
    - docker_magbot
    - legacy_deploy
    - legacy_magbot
    - legacy_magbot.deploy_logs
    - slack_irc

  '*reggie* and G@roles:db':
    - postgres
    - reggie.db

  '*reggie* and G@roles:loadbalancer':
    - haproxy

  '*reggie* and G@roles:web':
    - nginx
    - reggie_deploy.web
    - reggie.web

  '*reggie* and G@roles:sessions':
    - redis.server

  # '*reggie* and (G@roles:files or G@roles:files_arbiter)':
  #   - reggie_deploy.files
