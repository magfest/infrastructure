{%- set secret_path = salt['pillar.get']('data:path') ~ '/secret' -%}

ubersystem-deploy git latest:
  git.latest:
    - name: https://github.com/magfest/ubersystem-deploy.git
    - target: {{ secret_path }}/legacy_deploy

legacy_magbot git latest:
  git.latest:
    - name: https://github.com/magfest/magbot.git
    - target: {{ secret_path }}/legacy_magbot
