base:
  '*':
    - rsyslog
    - sshd
    - swap
    - salt.minion

  'G@is_vagrant:True':
    - vagrant

  'not bootstrap':
    - ufw
    - fail2ban
    - freeipa.client

  'G@roles:ipa-replica':
    - freeipa.server.replica

  'G@roles:saltmaster or bootstrap':
    - salt.master

  'G@roles:saltmaster and not bootstrap':
    - salt.cloud.manager
    - docker
    - docker_freeipa
    - docker_jenkins.import_freeipa_certs
    - docker_jenkins
    - docker_redis
    - docker_traefik.import_freeipa_certs
    - docker_traefik

  'G@roles:saltmaster and not G@is_vagrant:True':
    - docker_magbot
    - legacy_deploy
    - legacy_magbot
    - legacy_magbot.deploy_logs
    - slack_irc

  'G@salt-cloud:*':
    - salt.cloud.vm

  'G@roles:reggie':
    - filebeat
    - reggie_deploy

  'G@roles:reggie and G@roles:locust':
    - reggie.devenv
    - reggie_deploy.locust

  'G@roles:reggie and G@roles:locustmaster':
    - reggie_deploy.locustmaster

  'G@roles:reggie and G@roles:db':
    - reggie.devenv
    - postgres
    - reggie_deploy.db
    - reggie.db

  'G@roles:reggie and G@roles:files':
    - reggie_deploy.glusterfs
    - glusterfs.server

  'G@roles:reggie and G@roles:loadbalancer':
    - reggie_deploy.ssl
    - haproxy
    - letsencrypt
    - reggie_deploy.letsencrypt
    - reggie_deploy.loadbalancer

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
