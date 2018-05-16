legacy_deploy git latest:
  git.latest:
    - name: https://github.com/magfest/ubersystem-deploy.git
    - target: /srv/legacy_deploy

/srv/legacy_deploy/puppet/fabric_settings.ini:
  file.managed:
    - name: /srv/legacy_deploy/puppet/fabric_settings.ini
    - source: salt://legacy_deploy/fabric_settings.ini
    - template: jinja
    - require:
      - legacy_deploy git latest

legacy_deploy bootstrap_control_server:
  cmd.run:
    - name: fab -H localhost bootstrap_control_server
    - cwd: /srv/legacy_deploy/puppet
    - creates: /srv/legacy_deploy/puppet/hiera/nodes
    - require:
      - /srv/legacy_deploy/puppet/fabric_settings.ini

/srv/data/secret/hiera/:
  file.directory:
    - name: /srv/data/secret/hiera
    - dir_mode: 700
    - file_mode: 600
    - recurse:
      - mode
    - require:
      - legacy_deploy bootstrap_control_server

legacy_deploy secret hiera symlink:
  file.symlink:
    - name: /srv/legacy_deploy/puppet/hiera/nodes/external/secret
    - target: /srv/data/secret/hiera
    - makedirs: True
    - require:
      - /srv/data/secret/hiera/
    - require_in:
      - sls: legacy_magbot

legacy_deploy secret uber_puppet_module_files:
  file.recurse:
    - name: /srv/legacy_deploy/puppet/modules/uber/files
    - source: salt://legacy_deploy/uber_puppet_module_files
    - exclude_pat: 'README.md'
    - require:
      - legacy_deploy secret hiera symlink
