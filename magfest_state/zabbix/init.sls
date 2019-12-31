{% set zabbix_pkgname = salt['grains.filter_by']({
  'Arch': 'zabbix-agent',
  'RedHat': 'zabbix30-agent',
  'Debian': 'zabbix-agent'
  }, grain='os_family', default='Arch')
%}

zabbix-agent:
  pkg.installed:
    - name: {{ zabbix_pkgname }}
  service.running:
    - enable: True
    - reload: True
    - require:
      - pkg: zabbix-agent
      - file: /etc/zabbix/zabbix_agentd.conf
      - file: /var/run/zabbix

/etc/zabbix/zabbix_agentd.conf:
  file.managed:
    - source: salt://zabbix/zabbix_agentd.conf
    - makedirs: True
    - require:
      - pkg: zabbix-agent
    - watch_in:
      - service: zabbix-agent

/var/run/zabbix:
  file.directory:
    - user: zabbix
    - group: zabbix
    - mode: '0755'

