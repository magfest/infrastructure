include:
  - nodejs
  - npm

puppet install:
  pkg.installed:
    - name: puppet

fabric install:
  pkg.installed:
    - name: fabric

ruby-bcat install:
  pkg.installed:
    - name: ruby-bcat

magbot user:
  user.present:
    - name: magbot

/var/log/legacy_magbot/deploy/:
  file.directory:
    - name: /var/log/legacy_magbot/deploy/
    - makedirs: True

legacy_magbot git latest:
  git.latest:
    - name: git@github.com:magfest/magbot.git
    - target: /srv/legacy_magbot
    - identity: /root/.ssh/github_magbot_id_rsa

legacy_magbot secret.sh:
  file.managed:
    - name: /srv/legacy_magbot/secret.sh
    - source: salt://legacy_magbot/secret.sh
    - template: jinja

legacy_magbot rsyslog conf:
  file.managed:
    - name: /etc/rsyslog.d/legacy_magbot.conf
    - contents: |
        if $programname == 'legacy_magbot' then /var/log/legacy_magbot.log
        if $programname == 'legacy_magbot' then ~

legacy_magbot service conf:
  file.managed:
    - name: /lib/systemd/system/legacy_magbot.service
    - source: salt://legacy_magbot/legacy_magbot.service
    - template: jinja

/srv/legacy_magbot/ chown magbot:
  file.directory:
    - name: /srv/legacy_magbot/
    - user: magbot
    - group: magbot
    - recurse: ['user', 'group']

legacy_magbot service running:
  service.running:
    - name: legacy_magbot
    - watch_any:
      - file: /lib/systemd/system/legacy_magbot.service
      - file: /srv/legacy_magbot/secret.sh
      - git: git@github.com:magfest/magbot.git
    - require:
      - pkg: redis-server
      - sls: nodejs
      - sls: npm
