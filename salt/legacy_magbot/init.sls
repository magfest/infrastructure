{%- set secret_path = salt['pillar.get']('data:path') ~ '/secret' -%}

puppet install:
  pkg.installed:
    - name: puppet

fabric install:
  pkg.installed:
    - name: fabric

magbot user:
  user.present:
    - name: magbot

legacy_deploy git latest:
  git.latest:
    - name: https://github.com/magfest/ubersystem-deploy.git
    - target: {{ secret_path }}/legacy_deploy

legacy_deploy fabric_settings.ini:
  file.managed:
    - name: {{ secret_path }}/legacy_deploy/puppet/fabric_settings.ini
    - template: jinja

legacy_deploy bootstrap_control_server:
  cmd.run:
    - name: fab -H localhost bootstrap_control_server
    - cwd: {{ secret_path }}/legacy_deploy/puppet
    - creates: {{ secret_path }}/legacy_deploy/puppet/hiera/nodes

legacy_magbot git latest:
  git.latest:
    - name: git@github.com:magfest/magbot.git
    - target: {{ secret_path }}/legacy_magbot
    - identity: /root/.ssh/github_magbot.pem

legacy_magbot secrets.sh:
  file.managed:
    - name: {{ secret_path }}/legacy_magbot/secrets.sh
    - source: salt://legacy_magbot/secrets.sh
    - template: jinja

legacy_magbot service conf:
  file.managed:
    - name: /lib/systemd/system/legacy_magbot.service
    - source: salt://legacy_magbot/legacy_magbot.service
    - template: jinja

legacy_magbot service running:
  service.running:
    - name: legacy_magbot
    - watch_any:
      - file: /lib/systemd/system/legacy_magbot.service
      - git: git@github.com:magfest/magbot.git
