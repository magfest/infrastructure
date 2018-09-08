# ============================================================================
# Installs reggie, locust.io requirements, and locust.io master service
# ============================================================================

{%- from 'reggie_deploy/locust.sls' import env, install_dir, load_target_id, reggie_user %}
{%- set public_ip = salt['grains.get']('ip4_interfaces')[salt['grains.get']('public_interface', 'eth0')][0] %}

include:
  - reggie_deploy.locust


/var/log/locust/master.log:
  file.managed:
    - user: {{ reggie_user }}
    - makedirs: True
    - replace: False


locustmaster.service:
  file.managed:
    - name: /lib/systemd/system/locustmaster.service
    - contents: |
        [Unit]
        Description="The locust.io master service"
        After=network.target
        Before=locust.service

        [Service]
        Restart=always
        User={{ reggie_user }}
        WorkingDirectory={{ install_dir }}/plugins/uber/tests/locust
        ExecStart={{ install_dir }}/env/bin/locust \
          --locustfile={{ install_dir }}/plugins/uber/tests/locust/locustfile.py \
          --host='https://{{ load_target_id }}' \
          --loglevel=DEBUG \
          --logfile=/var/log/locust/master.log \
          --master-bind-host='{{ public_ip }}' \
          --master-bind-port=5557 \
          --web-host='' \
          --web-port=8089 \
          --master

        [Install]
        WantedBy=multi-user.target

  service.running:
    - name: locustmaster
    - enable: True
    - require:
      - file: locustmaster.service
    - watch_any:
      - file: locustmaster.service
