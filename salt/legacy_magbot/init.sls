include:
  - nodejs
  - npm

puppet install:
  pkg.installed:
    - name: puppet

fabric install:
  pkg.installed:
    - name: fabric

magbot user:
  user.present:
    - name: magbot

{% for ssh_key_name, ssh_key in salt['pillar.get']('magbot:ssh_keys').items() %}
/home/magbot/.ssh/{{ ssh_key_name }}.pub:
  file.managed:
    - mode: 644
    - user: magbot
    - group: magbot
    - makedirs: True
    - contents: {{ ssh_key['public'] }}

/home/magbot/.ssh/{{ ssh_key_name }}.pem:
  file.managed:
    - mode: 600
    - user: magbot
    - group: magbot
    - contents: |
        {{ ssh_key['private']|indent(8) }}
{% endfor %}

legacy_deploy git latest:
  git.latest:
    - name: https://github.com/magfest/ubersystem-deploy.git
    - target: /srv/legacy_deploy

/srv/legacy_deploy/puppet/fabric_settings.ini:
  file.managed:
    - name: /srv/legacy_deploy/puppet/fabric_settings.ini
    - source: salt://legacy_magbot/fabric_settings.ini
    - template: jinja

legacy_deploy bootstrap_control_server:
  cmd.run:
    - name: fab -H localhost bootstrap_control_server
    - cwd: /srv/legacy_deploy/puppet
    - creates: /srv/legacy_deploy/puppet/hiera/nodes

/srv/data/secret/hiera/:
  file.directory:
    - name: /srv/data/secret/hiera
    - dir_mode: 700
    - file_mode: 600
    - recurse:
      - mode

legacy_deploy symlink secret hiera:
  file.symlink:
    - name: /srv/legacy_deploy/puppet/hiera/nodes/external/secret
    - target: /srv/data/secret/hiera
    - user: magbot
    - group: magbot
    - makedirs: True

/srv/legacy_deploy/ chown magbot:
  file.directory:
    - name: /srv/legacy_deploy/
    - user: magbot
    - group: magbot
    - recurse: ['user', 'group']

legacy_magbot git latest:
  git.latest:
    - name: git@github.com:magfest/magbot.git
    - target: /srv/legacy_magbot
    - identity: /root/.ssh/github_magbot.pem

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
