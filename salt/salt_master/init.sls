# ============================================================================
# Salt master prerequisites
# ============================================================================

# Salt needs libssh-dev and python-git to clone github repositories
libssh-dev install:
  pkg.installed:
    - name: libssh-dev
    - reload_modules: True

python-git install:
  pkg.installed:
    - name: python-git
    - reload_modules: True


# ============================================================================
# Secret infrastructure configuration
# ============================================================================

{%- set secret_infrastructure = salt['pillar.get']('data:path') ~ '/secret/infrastructure' %}

# Create directory if it doesn't exist
{{ secret_infrastructure }}/:
  file.directory:
    - mode: 700
    - makedirs: True

# Initialize a local git repository. This is mostly to help admins track
# updates to their secret data.
{{ secret_infrastructure }}/ git init:
  git.present:
    - name: {{ secret_infrastructure }}/
    - bare: False

# No need to track changes to *.example or README.md, because those files are
# under configuration management.
{{ secret_infrastructure }}/ git ignore:
  file.managed:
    - name: {{ secret_infrastructure }}/.gitignore
    - contents: |
        salt/**/*.sls
        README.md
    - require:
      - git: {{ secret_infrastructure }}/

# Put README.md under configuration management, so local changes are reverted
{{ secret_infrastructure }}/README.md:
  file.managed:
    - source: salt://salt_master/files/secret_infrastructure/README.md
    - mode: 600
    - template: jinja
    - require:
      - git: {{ secret_infrastructure }}/

# Copy secret_infrastructure salt files
# NOTE: These ARE NOT treated as Jinja templates
{{ secret_infrastructure }}/salt/ files:
  file.recurse:
    - name: {{ secret_infrastructure }}/salt/
    - source: salt://salt_master/files/secret_infrastructure/salt
    - dir_mode: 700
    - file_mode: 600
    - makedirs: True
    - require:
      - git: {{ secret_infrastructure }}/

# Copy secret_infrastructure pillar files
# NOTE: These ARE treated as Jinja templates
{{ secret_infrastructure }}/pillar/ files:
  file.recurse:
    - name: {{ secret_infrastructure }}/pillar/
    - source: salt://salt_master/files/secret_infrastructure/pillar
    - dir_mode: 700
    - file_mode: 600
    - makedirs: True
    - replace: False
    - template: jinja
    - require:
      - git: {{ secret_infrastructure }}/

# Copy secret_infrastructure reggie_config files
# NOTE: These ARE treated as Jinja templates
{{ secret_infrastructure }}/reggie_config/ files:
  file.recurse:
    - name: {{ secret_infrastructure }}/reggie_config/
    - source: salt://salt_master/files/secret_infrastructure/reggie_config
    - dir_mode: 700
    - file_mode: 600
    - makedirs: True
    - replace: False
    - template: jinja
    - require:
      - git: {{ secret_infrastructure }}/

# Copy secret_infrastructure reggie_config/stack.cfg
{{ secret_infrastructure }}/reggie_config/stack.cfg:
  file.managed:
    - name: {{ secret_infrastructure }}/reggie_config/stack.cfg
    - source: file:///srv/infrastructure/reggie_config/stack.cfg
    - mode: 600
    - require:
      - file: {{ secret_infrastructure }}/reggie_config/


# ============================================================================
# SSH login configuration
# ============================================================================

/root/.ssh/ public keys:
  file.recurse:
    - name: /root/.ssh/
    - makedirs: True
    - include_pat: '*.pub'
    - file_mode: 644
    - source: salt://salt_master/ssh_keys

/root/.ssh/ private keys:
  file.recurse:
    - name: /root/.ssh/
    - exclude_pat: 'E@\.*\.pub|README\.md'
    - file_mode: 600
    - source: salt://salt_master/ssh_keys


# ============================================================================
# Logging configuration
# ============================================================================

/var/log/salt/ master log dir:
  file.directory:
    - name: /var/log/salt/
    - makedirs: True
    - user: syslog
    - group: adm

salt-master rsyslog conf:
  file.managed:
    - name: /etc/rsyslog.d/salt-master.conf
    - contents: |
        if $programname == 'salt-master' then /var/log/salt/master.log
        if $programname == 'salt-master' then ~
    - listen_in:
      - service: rsyslog

/etc/logrotate.d/salt-master:
  file.managed:
    - name: /etc/logrotate.d/salt-master
    - contents: |
        /var/log/salt/master.log {
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
# Salt reactor configuration
# ============================================================================

/etc/salt/master.d/reactor.conf:
  file.managed:
    - mode: 644
    - makedirs: True
    - template: jinja
    - contents: |
        reactor:
          - 'salt/cloud/*/created':
            - '/srv/infrastructure/salt/reactor/salt_cloud_created.sls'
          - 'salt/cloud/*/destroying':
            - '/srv/infrastructure/salt/reactor/salt_cloud_destroying.sls'


# ============================================================================
# Salt master configuration
# ============================================================================

/etc/salt/master:
  file.managed:
    - source: salt://salt_master/files/salt_master.yaml
    - mode: 644
    - makedirs: True
    - template: jinja

  service.running:
    - name: salt-master
    - enable: True
    - order: last
    - watch:
      - file: /etc/salt/master
    - require_in:
      - sls: salt_minion
