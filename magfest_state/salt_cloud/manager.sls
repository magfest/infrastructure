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

{% for target_dir in ['cloud.maps.d', 'cloud.profiles.d'] %}
/etc/salt/{{ target_dir }}:
  file.recurse:
    - name: /etc/salt/{{ target_dir }}
    - source: salt://salt_cloud/files/{{ target_dir }}
    - template: jinja
{% endfor %}

/etc/salt/roster:
  file.managed:
    - name: /etc/salt/roster
    - template: jinja
    - contents: |
        {%- for host in [
            'archive.uber.magfest.org',
            'backups.uber.magfest.org',
            'docker.uber.magfest.org',
            'docs.magfest.net',
            'jira.magfest.net',
            'megamanathon.magfest.org',
        ] %}
        {{ host }}:
          host: {{ host }}
          user: root
          priv: /root/.ssh/id_rsa
        {% endfor %}
