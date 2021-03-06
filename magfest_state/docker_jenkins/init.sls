# ============================================================================
# Installs a Jenkins server in a docker container
#
# After installation, configure authentication in the Jenkins web UI and
# in FreeIPA at https://directory.magfest.net. Jenkins users must belong to
# either the "jenkins-users" group, or the "developers" group. Jenkins
# administrators must belong to the "jenkins-admins" group or the "admins"
# group.
#
# In the Jenkins web UI:
#
# Manage Jenkins > Configure Global Security > Advanced Server Configuration...
#
#     Server: ldaps://ipa-01.magfest.org
#     root DN: dc=magfest,dc=org
#     User search base: cn=users,cn=accounts
#     User search filter: uid={0}
#     Group search base:
#     Group search filter:
#     Group membership: Search for LDAP groups containing user
#         Group membership filter: (| (member={0}) (uniqueMember={0}) (memberUid={1}))
#     Manager DN: uid=svc_jenkins,cn=users,cn=accounts,dc=magfest,dc=org
#     Manager Password: secret
#
# ============================================================================

{% set jenkins_home = salt['pillar.get']('data:path') ~ '/jenkins/jenkins_home' -%}
{% set jenkins_user = salt['pillar.get']('jenkins:user') -%}
{% set jenkins_group = salt['pillar.get']('jenkins:group') -%}

include:
  - docker.network


# ============================================================================
# Configure jenkins user/group
#
# The jenkins user in the docker container has uid=1000 and gid=1000. Any
# bound files or directories on the host machine must also be owned by the
# jenkins user.
# ============================================================================

docker_jenkins user:
  group.present:
    - name: {{ jenkins_group }}
    - gid: 1000

  user.present:
    - name: {{ jenkins_user }}
    - uid: 1000
    - gid: 1000
    - require:
      - group: {{ jenkins_group }}


# ============================================================================
# Configure Jenkins JVM keystore
#
# Required for importing any certificates to which Jenkins will need access.
# ============================================================================

{{ jenkins_home }}/.keystore/:
  file.directory:
    - name: {{ jenkins_home }}/.keystore/
    - user: {{ jenkins_user }}
    - group: {{ jenkins_group }}
    - mode: 700
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
    - require:
      - user: {{ jenkins_user }}

# Start with default cacerts.
copy {{ jenkins_home }}/.keystore/cacerts:
  cmd.run:
    - name: docker cp jenkins:/etc/ssl/certs/java/cacerts {{ jenkins_home }}/.keystore/
    - creates: {{ jenkins_home }}/.keystore/cacerts
    - require:
      - file: {{ jenkins_home }}/.keystore/

# chown jenkins:jenkins cacerts
chown jenkins {{ jenkins_home }}/.keystore/cacerts:
  file.managed:
    - name: {{ jenkins_home }}/.keystore/cacerts
    - user: {{ jenkins_user }}
    - group: {{ jenkins_group }}
    - replace: False
    - mode: 600
    - require:
      - copy {{ jenkins_home }}/.keystore/cacerts


# ============================================================================
# Configure Jenkins logging
# ============================================================================

/var/log/jenkins/:
  file.directory:
    - name: /var/log/jenkins/
    - makedirs: True
    - user: syslog
    - group: adm

/etc/rsyslog.d/jenkins.conf:
  file.managed:
    - name: /etc/rsyslog.d/jenkins.conf
    - contents: |
        if $programname == 'jenkins' then /var/log/jenkins/jenkins.log
        if $programname == 'jenkins' then ~
    - listen_in:
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


# ============================================================================
# Jenkins docker container
# ============================================================================

docker_jenkins:
  docker_container.running:
    - name: jenkins
    - image: jenkins/jenkins:lts
    - auto_remove: True
    - binds: {{ salt['pillar.get']('data:path') }}/jenkins/jenkins_home:/var/jenkins_home
    - ports: 8080,50000
    - environment:
      - JAVA_OPTS: >
          -Djavax.net.ssl.trustStore=/var/jenkins_home/.keystore/cacerts
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
