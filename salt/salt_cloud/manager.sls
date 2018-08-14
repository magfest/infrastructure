/etc/salt/cloud:
  file.managed:
    - template: jinja
    - contents: |
        minion:
          master: {{ salt['network.interface_ip'](salt['grains.get']('private_interface', 'eth1')) }}

          mine_functions:
            public_ip:
              - mine_function: network.interface_ip
              - eth0
            private_ip:
              - mine_function: network.interface_ip
              - {{ salt['grains.get']('private_interface', 'eth1') }}

          use_superseded:
            - module.run

          log_file: file:///dev/log

/etc/salt/cloud.providers.d/digitalocean.conf:
  file.managed:
    - makedirs: True
    - template: jinja
    - show_changes: False
    - contents: |
        digitalocean:
          driver: digitalocean
          personal_access_token: {{ salt['pillar.get']('digitalocean:personal_access_token') }}
          ssh_key_file: /etc/salt/pki/cloud/digitalocean.pem
          ssh_key_names: {{ salt['pillar.get']('digitalocean:ssh_key_names') }}
          script: bootstrap-salt
          script_args: -P git 'v2018.3.2'

/etc/salt/pki/cloud/digitalocean.pem:
  file.managed:
    - source: salt://salt_cloud/pki/digitalocean.pem
    - mode: 600
    - dir_mode: 700
    - makedirs: True

/etc/salt/pki/cloud/digitalocean.pub:
  file.managed:
    - source: salt://salt_cloud/pki/digitalocean.pub
    - mode: 644
    - dir_mode: 700
    - makedirs: True

{% for file in salt['cp.list_master'](prefix='salt_cloud/files') %}
{% set filename = file.rsplit('/', 1)[-1] %}
{% set target_dir = '/etc/salt/cloud.maps.d' if filename.endswith('.map') else '/etc/salt/cloud.profiles.d' %}
{{ target_dir }}/{{ filename }}:
  file.managed:
    - source: salt://{{ file }}
    - makedirs: True
    - template: jinja
{% endfor %}
