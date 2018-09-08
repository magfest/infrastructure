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
# Nicer bash environment
# ============================================================================

file.managed /root/.bash_aliases:
  file.managed:
    - name: /root/.bash_aliases

file.blockreplace /root/.bash_aliases:
  file.blockreplace:
    - name: /root/.bash_aliases
    - append_if_not_found: True
    - append_newline: True
    - template: jinja
    - require:
      - file: file.managed /root/.bash_aliases
    - marker_start: '# ==== START BLOCK MANAGED BY SALT (salt_master) ===='
    - content: alias salt-job='salt-run --out highstate jobs.lookup_jid'
    - marker_end: '# ==== END BLOCK MANAGED BY SALT (salt_master) ===='


# ============================================================================
# Secret infrastructure configuration
# ============================================================================

{%- set secret_infrastructure = salt['pillar.get']('data:path') ~ '/secret/infrastructure' %}
{%- set secret_dir_mode = 755 if salt['grains.get']('is_vagrant') else 700 %}
{%- set secret_file_mode = 644 if salt['grains.get']('is_vagrant') else 600 %}

# Create directory if it doesn't exist
{{ secret_infrastructure }}/:
  file.directory:
    - makedirs: True
    - mode: {{ secret_dir_mode }}


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
    - source: salt://salt/master/files/secret_infrastructure/README.md
    - mode: {{ secret_file_mode }}
    - template: jinja
    - require:
      - git: {{ secret_infrastructure }}/

# Copy secret_infrastructure salt files
# NOTE: These ARE NOT treated as Jinja templates
{{ secret_infrastructure }}/magfest_state/ files:
  file.recurse:
    - name: {{ secret_infrastructure }}/magfest_state/
    - source: salt://salt/master/files/secret_infrastructure/magfest_state
    - dir_mode: {{ secret_dir_mode }}
    - file_mode: {{ secret_file_mode }}
    - makedirs: True
    - require:
      - git: {{ secret_infrastructure }}/

# Copy secret_infrastructure pillar files
# NOTE: These ARE treated as Jinja templates
{{ secret_infrastructure }}/magfest_config/ files:
  file.recurse:
    - name: {{ secret_infrastructure }}/magfest_config/
    - source: salt://salt/master/files/secret_infrastructure/magfest_config
    - dir_mode: {{ secret_dir_mode }}
    - file_mode: {{ secret_file_mode }}
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
    - source: salt://salt/master/files/secret_infrastructure/reggie_config
    - dir_mode: {{ secret_dir_mode }}
    - file_mode: {{ secret_file_mode }}
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
    - mode: {{ secret_file_mode }}
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
    - source: salt://salt/master/ssh_keys

/root/.ssh/ private keys:
  file.recurse:
    - name: /root/.ssh/
    - exclude_pat: 'E@\.*\.pub|README\.md'
    - file_mode: 600
    - source: salt://salt/master/ssh_keys


# ============================================================================
# Logging configuration
# ============================================================================

/var/log/salt/ master log dir:
  file.directory:
    - name: /var/log/salt/
    - makedirs: True
    - user: syslog
    - group: adm

{% for service in ['master', 'api'] %}
salt-{{ service }} rsyslog conf:
  file.managed:
    - name: /etc/rsyslog.d/salt-{{ service }}.conf
    - contents: |
        if $programname == 'salt-{{ service }}' then /var/log/salt/{{ service }}.log
        if $programname == 'salt-{{ service }}' then ~
    - listen_in:
      - service: rsyslog

/etc/logrotate.d/salt-{{ service }}:
  file.managed:
    - name: /etc/logrotate.d/salt-{{ service }}
    - contents: |
        /var/log/salt/{{ service }}.log {
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
{% endfor %}


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
            - '/srv/infrastructure/magfest_state/salt/reactor/salt_cloud_created.sls'
          - 'salt/cloud/*/destroying':
            - '/srv/infrastructure/magfest_state/salt/reactor/salt_cloud_destroying.sls'


# ============================================================================
# Salt master configuration
# ============================================================================

salt-master service:
  file.managed:
    - name: /etc/salt/master
    - source: salt://salt/master/files/salt_master.yaml
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
      - sls: salt.minion


# ============================================================================
# Salt master user interface configuration
# ============================================================================

{% set version = '0.3.1' %}
molten salt ui:
  archive.extracted:
    - name: /srv/
    - user: root
    - group: root
    - source: https://github.com/martinhoefling/molten/releases/download/v{{ version }}/molten-{{ version }}.tar.gz
    - source_hash: 675f9c85c8f24cf7fec9dfa0f75c842dde7c968d
    - archive_format: tar
    - options: v
    - if_missing: /srv/molten-{{ version }}

  file.symlink:
    - name: /srv/molten
    - target: /srv/molten-{{ version }}


# ============================================================================
# Salt master API configuration
# ============================================================================

/etc/ssl/certs/salt-master.pem:
  pkg.installed:
    - name: python-pip
    - reload_modules: True

  pip.installed:
    - name: pyopenssl
    - reload_modules: True

  module.run:
    - tls.create_self_signed_cert:
      - tls_dir: '.'
      - CN: salt-master
      - C: US
      - ST: Maryland
      - L: Baltimore
      - cacert_path: /etc/ssl
    - unless: test -f /etc/ssl/certs/salt-master.crt

  cmd.run:
    - name: cat /etc/ssl/certs/salt-master.crt /etc/ssl/certs/salt-master.key > /etc/ssl/certs/salt-master.pem
    - unless: >
        cat /etc/ssl/certs/salt-master.crt /etc/ssl/certs/salt-master.key |
        diff --report-identical-files /etc/ssl/certs/salt-master.pem - > /dev/null

pip install cherrypy:
  pip.installed:
    - name: cherrypy
    - reload_modules: True

pip install python-ldap:
  pkg.installed:
    - pkgs:
      - build-essential
      - python3-dev
      - python2.7-dev
      - libldap2-dev
      - libsasl2-dev
      - ldap-utils

  pip.installed:
    - name: python-ldap
    - reload_modules: True

salt-api service:
  service.running:
    - name: salt-api
    - enable: True
    - order: last
    - watch:
      - file: /etc/salt/master
      - file: /srv/molten
    - require:
      - service: salt-master
