{%- set secret_path = salt['pillar.get']('data:path') ~ '/secret' -%}

magbot group:
  group.present:
    - name: magbot

magbot user:
  user.present:
    - name: magbot
    - require:
      - group: magbot

legacy_deploy git latest:
  git.latest:
    - name: https://github.com/magfest/ubersystem-deploy.git
    - target: {{ secret_path }}/legacy_deploy
    - require:
      - sls: salt_master

legacy_magbot git latest:
  git.latest:
    - name: git@github.com:magfest/magbot.git
    - target: {{ secret_path }}/legacy_magbot
    - identity: /root/.ssh/github_magbot.pem
    - require:
      - sls: salt_master
