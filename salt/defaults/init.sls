default:
  pkg.installed:
    - name: salt-minion
  service.running:
    - name: salt-minion
    - require:
      - pkg: salt-minion
    - watch:
      - /etc/salt/minion

/etc/salt/minion:
  file.managed:
    - source: salt://salt_minion/salt_minion.conf
    - mode: 644
    - template: jinja
