# ============================================================================
# Installs reggie, locust.io requirements, and locust.io master service
# ============================================================================

{%- set reggie_user = salt['pillar.get']('reggie:user') %}
{%- set install_dir = salt['pillar.get']('reggie:install_dir') %}
{%- set env = salt['grains.get']('env', 'load') %}
{%- set locustmaster_id, locustmaster_ip = salt['mine.get'](
    'G@roles:reggie and G@roles:locustmaster and G@env:' ~ env,
    'public_ip',
    'compound').items()|first %}

{%- set load_target_id = salt['mine.get'](
    'G@roles:reggie and G@roles:loadbalancer and G@env:' ~ env,
    'public_ip',
    'compound').keys()|first %}



# ============================================================================
# Bump up the number of file descriptors our services are allowed to open
# ============================================================================

{%- from 'macros.jinja' import ulimit %}
{{ ulimit('reggie_deploy.locust', 'reggie', 'nofile', 1048576, 1048576, watch_in=['service: locust']) }}


include:
  - reggie.install


locust.io requirements:
  pip.installed:
    - requirements: {{ install_dir }}/plugins/uber/tests/locust/requirements.txt
    - user: {{ salt['pillar.get']('reggie:user') }}
    - bin_env: {{ install_dir }}/env
    - require:
      - sls: reggie.install


/var/log/locust/minion.log:
  file.managed:
    - user: {{ reggie_user }}
    - makedirs: True


locust.service:
  file.managed:
    - name: /lib/systemd/system/locust.service
    - contents: |
        [Unit]
        Description="The locust.io minion service"
        After=network.target

        [Service]
        Restart=always
        User={{ reggie_user }}
        WorkingDirectory={{ install_dir }}/plugins/uber/tests/locust
        ExecStart={{ install_dir }}/env/bin/locust \
          --locustfile={{ install_dir }}/plugins/uber/tests/locust/locustfile.py \
          --host='https://{{ load_target_id }}' \
          --loglevel=DEBUG \
          --logfile=/var/log/locust/minion.log \
          --master-host='{{ locustmaster_ip }}' \
          --master-port=5557 \
          --slave

        [Install]
        WantedBy=multi-user.target

  service.running:
    - name: locust
    - require:
      - file: locust.service
    - watch_any:
      - file: locust.service
      - sls: reggie.install
