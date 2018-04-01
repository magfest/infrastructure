salt_minion:
  pkg.installed:
    - name: salt-minion
  service.running:
    - name: salt-minion
    - require:
      - pkg: salt-minion
    - watch:
      - file: /etc/salt/minion

/etc/salt/minion conf:
  file.managed:
    - name: /etc/salt/minion
    - source: salt://salt_minion/salt_minion.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
