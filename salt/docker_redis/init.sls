include:
  - docker_network_internal


# ============================================================================
# Configure redis files and directories
# ============================================================================

{{ salt['pillar.get']('data:path') }}/redis/data/:
  file.directory:
    - name: {{ salt['pillar.get']('data:path') }}/redis/data
    - makedirs: True


{{ salt['pillar.get']('data:path') }}/redis/etc/redis/redis.conf:
  file.managed:
    - name: {{ salt['pillar.get']('data:path') }}/redis/etc/redis/redis.conf
    - makedirs: True
    - source: salt://docker_redis/files/redis.conf
    - template: jinja

{% for setting in ['enabled', 'defrag'] %}
transparent_hugepage never {{ setting }}:
  cmd.run:
    - name: echo never > /sys/kernel/mm/transparent_hugepage/{{ setting }}
    - unless: grep -q '\[never\]' /sys/kernel/mm/transparent_hugepage/{{ setting }}
{% endfor %}


# ============================================================================
# Configure redis logging
# ============================================================================

/var/log/redis/:
  file.directory:
    - name: /var/log/redis/
    - makedirs: True
    - user: syslog
    - group: adm

/etc/rsyslog.d/redis.conf:
  file.managed:
    - name: /etc/rsyslog.d/redis.conf
    - contents: |
        if $programname == 'redis' then /var/log/redis/redis.log
        if $programname == 'redis' then ~
    - listen_in:
      - service: rsyslog

/etc/logrotate.d/redis:
  file.managed:
    - name: /etc/logrotate.d/redis
    - contents: |
        /var/log/redis/redis.log {
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
# redis docker container
# ============================================================================

docker_redis:
  docker_container.running:
    - name: {{ salt['pillar.get']('redis:hostname') }}
    - image: redis:latest
    - auto_remove: True
    - binds:
      - {{ salt['pillar.get']('data:path') }}/redis/etc/redis/redis.conf:/usr/local/etc/redis/redis.conf
      - {{ salt['pillar.get']('data:path') }}/redis/data:/data
    - ports: 6379
    - log_driver: syslog
    - log_opt:
      - tag: redis
    - networks:
      - docker_network_internal
    - require:
      - docker_network: docker_network_internal
    - watch_any:
      - file: {{ salt['pillar.get']('data:path') }}/redis/etc/redis/redis.conf
      {% for setting in ['enabled', 'defrag'] %}
      - transparent_hugepage never {{ setting }}
      {%- endfor %}
