include:
  - docker_network_proxy

jenkins group:
  group.present:
    - name: jenkins
    - gid: 1000

jenkins user:
  user.present:
    - name: jenkins
    - uid: 1000
    - gid: 1000
    - require:
      - group: jenkins

{{ salt['pillar.get']('data:path') }}/jenkins/jenkins_home/:
  file.directory:
    - user: jenkins
    - group: jenkins
    - mode: 700
    - makedirs: True
    - require:
      - user: jenkins

/var/log/jenkins/:
  file.directory:
    - name: /var/log/jenkins/
    - makedirs: True
    - user: syslog
    - group: adm

jenkins rsyslog conf:
  file.managed:
    - name: /etc/rsyslog.d/jenkins.conf
    - contents: |
        if $programname == 'jenkins' then /var/log/jenkins/jenkins.log
        if $programname == 'jenkins' then ~
    - watch_in:
      - service: rsyslog

/etc/logrotate.d/jenkins:
  file.managed:
    - name: /etc/logrotate.d/jenkins
    - contents: |
        /var/log/jenkins/jenkins.log {
            daily
            missingok
            rotate 52
            compress
            delaycompress
            notifempty
            create 640 syslog adm
            sharedscripts
            postrotate
                invoke-rc.d rsyslog rotate > /dev/null
            endscript
        }

jenkins:
  docker_container.running:
    - name: jenkins
    - image: jenkinsci/blueocean:latest
    - auto_remove: True
    - binds: {{ salt['pillar.get']('data:path') }}/jenkins/jenkins_home:/var/jenkins_home
    - ports: 8080,50000
    - environment:
      - JAVA_OPTS: >
          -Djavax.net.ssl.trustStore=/var/jenkins_home/.keystore/cacerts \
          -Djavax.net.ssl.trustStorePassword=changeit
    - log_driver: syslog
    - log_opt:
      - tag: jenkins
    - labels:
      - traefik.enable=true
      - traefik.frontend.rule=Host:{{ salt['pillar.get']('jenkins:domain') }}
      - traefik.frontend.entryPoints=http,https
      - traefik.port=8080
      - traefik.docker.network=docker_network_internal
    - networks:
      - docker_network_internal
    - require:
      - docker_network: docker_network_internal
