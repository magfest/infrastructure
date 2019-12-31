include:
  - docker.network


# ============================================================================
# Configure magbot files and plugins
# ============================================================================

{%- set errbot_dirs = ['ssl', 'ssh', 'data', 'plugins', 'storage_plugins'] %}

{% for subdir in errbot_dirs %}
{{ salt['pillar.get']('data:path') }}/magbot/{{ subdir }}/:
  file.directory:
    - name: {{ salt['pillar.get']('data:path') }}/magbot/{{ subdir }}
    - makedirs: True
{% endfor %}

{{ salt['pillar.get']('data:path') }}/magbot/config.py:
  file.managed:
    - name: {{ salt['pillar.get']('data:path') }}/magbot/config.py
    - source: salt://docker_magbot/files/config.py
    - show_changes: False
    - template: jinja

docker_magbot magbot git latest:
  git.latest:
    - name: https://github.com/magfest/magbot.git
    - target: {{ salt['pillar.get']('data:path') }}/magbot/plugins/magbot

docker_magbot err-profiles git latest:
  git.latest:
    - name: https://github.com/shengis/err-profiles.git
    - target: {{ salt['pillar.get']('data:path') }}/magbot/plugins/err-profiles

docker_magbot err-storage-redis git latest:
  git.latest:
    - name: https://github.com/sijis/err-storage-redis.git
    - target: {{ salt['pillar.get']('data:path') }}/magbot/storage_plugins/err-storage-redis


# ============================================================================
# Configure magbot logging
# ============================================================================

/var/log/magbot/:
  file.directory:
    - name: /var/log/magbot/
    - makedirs: True
    - user: syslog
    - group: adm

/etc/rsyslog.d/magbot.conf:
  file.managed:
    - name: /etc/rsyslog.d/magbot.conf
    - contents: |
        if $programname == 'magbot' then /var/log/magbot/magbot.log
        if $programname == 'magbot' then ~
    - listen_in:
      - service: rsyslog

/etc/logrotate.d/magbot:
  file.managed:
    - name: /etc/logrotate.d/magbot
    - contents: |
        /var/log/magbot/magbot.log {
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
# Configure credentials and permissions needed by magbot
# ============================================================================

/etc/sudoers.d/{{ salt['pillar.get']('magbot:salt_username') }}:
  file.managed:
    - name: /etc/sudoers.d/{{ salt['pillar.get']('magbot:salt_username') }}
    - mode: 440
    - check_cmd: visudo -c -f
    - contents: |
        # Created by Salt
        # User rules for {{ salt['pillar.get']('magbot:salt_username') }}
        {{ salt['pillar.get']('magbot:salt_username') }} ALL=(ALL) /usr/bin/git, /usr/bin/salt, /usr/bin/salt-cloud, /usr/bin/salt-run

{{ salt['pillar.get']('data:path') }}/magbot/ssh/ public keys:
  file.recurse:
    - name: {{ salt['pillar.get']('data:path') }}/magbot/ssh/
    - makedirs: True
    - include_pat: '*.pub'
    - file_mode: 644
    - source: salt://magbot/ssh_keys

{{ salt['pillar.get']('data:path') }}/magbot/ssh/ private keys:
  file.recurse:
    - name: {{ salt['pillar.get']('data:path') }}/magbot/ssh/
    - exclude_pat: 'E@\.*\.pub|README\.md'
    - file_mode: 600
    - source: salt://magbot/ssh_keys


# ============================================================================
# magbot docker container
# ============================================================================

docker_magbot:
  docker_container.running:
    - name: magbot
    - image: magfest/docker-errbot:latest
    - auto_remove: True
    - binds:
      - {{ salt['pillar.get']('data:path') }}/magbot:/srv
    - log_driver: syslog
    - log_opt:
      - tag: magbot
    - networks:
      - docker_network_external
      - docker_network_internal
    - require:
      - docker_network: docker_network_external
      - docker_network: docker_network_internal
    - watch_any:
      - file: {{ salt['pillar.get']('data:path') }}/magbot/config.py
      - git: https://github.com/magfest/magbot.git
      - git: https://github.com/shengis/err-profiles.git
      - git: https://github.com/sijis/err-storage-redis.git
