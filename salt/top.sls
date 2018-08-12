base:
  '*':
    - rsyslog
    - sshd
    - swap
    - salt_minion

  'not bootstrap':
    - ufw
    - fail2ban
    - freeipa_client

  'mcp or bootstrap':
    - salt_master
    - docker

  'mcp':
    - salt_cloud.manager
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

  'G@salt-cloud:*':
    - salt_cloud.vm

  'G@roles:reggie':
    - filebeat

  'G@roles:reggie and G@roles:db':
    - reggie.devenv
    - postgres
    - reggie.db
    - reggie_deploy.db_backup

  'G@roles:reggie and G@roles:files':
    - reggie_deploy.glusterfs
    - glusterfs.server

  'G@roles:reggie and G@roles:loadbalancer':
    - reggie_deploy.ssl
    - haproxy
    - letsencrypt
    - reggie_deploy.letsencrypt

  'G@roles:reggie and G@roles:web':
    - reggie.devenv
    - reggie_deploy.ssl
    - reggie_deploy.glusterfs
    - glusterfs.client
    - nginx.ng
    - reggie.web
    - reggie_deploy.web

  'G@roles:reggie and G@roles:sessions':
    - reggie_deploy.sessions
    - redis.server

  'G@roles:reggie and G@roles:queue':
    - rabbitmq

  'G@roles:reggie and G@roles:scheduler':
    - reggie.scheduler

  'G@roles:reggie and G@roles:worker':
    - reggie.worker
