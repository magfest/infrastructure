include:
  - docker_network_internal

{{ salt['pillar.get']('data:path') }}/traefik/etc/traefik/certs/:
  file.directory:
    - mode: 600
    - makedirs: True

{{ salt['pillar.get']('data:path') }}/traefik/etc/traefik/traefik.toml:
  file.managed:
    - source: salt://traefik/traefik.toml
    - mode: 644
    - makedirs: True
    - template: jinja

{{ salt['pillar.get']('data:path') }}/traefik/etc/traefik/acme.json:
  file.managed:
    - mode: 600
    - makedirs: True

/var/log/traefik/:
  file.directory:
    - name: /var/log/traefik/
    - makedirs: True
    - user: syslog
    - group: adm

traefik rsyslog conf:
  file.managed:
    - name: /etc/rsyslog.d/traefik.conf
    - contents: |
        if $programname == 'traefik' then /var/log/traefik/traefik.log
        if $programname == 'traefik' then ~
    - listen_in:
      - service: rsyslog

/etc/logrotate.d/traefik:
  file.managed:
    - name: /etc/logrotate.d/traefik
    - contents: |
        /var/log/traefik/traefik.log {
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

traefik:
  docker_container.running:
    - name: traefik
    - image: traefik:latest
    - auto_remove: True
    - binds:
      - /var/run/docker.sock:/var/run/docker.sock
      - {{ salt['pillar.get']('data:path') }}/traefik/etc/traefik/certs:/certs
      - {{ salt['pillar.get']('data:path') }}/traefik/etc/traefik/traefik.toml:/traefik.toml
      - {{ salt['pillar.get']('data:path') }}/traefik/etc/traefik/acme.json:/acme.json
    - ports: 80,443
    - port_bindings:
      - 80:80
      - 443:443
    - log_driver: syslog
    - log_opt:
      - tag: traefik
    - labels:
      - traefik.enable=true
      - traefik.frontend.rule=Host:{{ salt['pillar.get']('traefik:domain') }},{{ salt['pillar.get']('traefik:ui_domain') }}
      - traefik.frontend.entryPoints=http,https
      {% if salt['pillar.get']('traefik:users', {}) -%}
      - traefik.frontend.auth.basic={%- for user, password in salt['pillar.get']('traefik:users').items() -%}
          {{ user }}:{{ salt['shadow.gen_password'](password, crypt_salt='salt_salt', algorithm='md5') }}{{ ',' if not loop.last else '' }}
        {%- endfor -%}
      {% endif %}
      - traefik.port=8080
      - traefik.docker.network=docker_network_internal
    - networks:
      - docker_network_external
      - docker_network_internal
    - watch_any:
      - file: {{ salt['pillar.get']('data:path') }}/traefik/etc/traefik/traefik.toml
      - file: {{ salt['pillar.get']('data:path') }}/traefik/etc/traefik/acme.json
      - sls: traefik.import_freeipa_certs
    - require:
      - docker_network: docker_network_external
      - docker_network: docker_network_internal
      - file: {{ salt['pillar.get']('data:path') }}/traefik/etc/traefik/traefik.toml
      - file: {{ salt['pillar.get']('data:path') }}/traefik/etc/traefik/acme.json
    - require_in:
      - sls: freeipa.client
