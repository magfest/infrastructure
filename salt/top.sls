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
    - reggie.devenv
    - postgres
    - reggie.db

  '*reggie* and G@roles:files':
    - reggie_deploy.glusterfs
    - glusterfs.server

  '*reggie* and G@roles:loadbalancer':
    - letsencrypt
    - haproxy
    - reggie_deploy.loadbalancer

  '*reggie* and G@roles:web':
    - reggie.devenv
    - reggie_deploy.ssl
    - reggie_deploy.glusterfs
    - glusterfs.client
    - nginx.ng
    - reggie.web
    - reggie_deploy.web

  '*reggie* and G@roles:sessions':
    - redis.server

  '*reggie* and G@roles:queue':
    - rabbitmq

  '*reggie* and G@roles:scheduler':
    - reggie.scheduler

  '*reggie* and G@roles:worker':
    - reggie.worker
