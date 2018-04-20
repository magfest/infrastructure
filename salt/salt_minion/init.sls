/etc/salt/minion conf:
  file.managed:
    - name: /etc/salt/minion
    - source: salt://salt_minion/salt_minion.conf
    - mode: 644
    - template: jinja

salt_minion:
  service.running:
    - name: salt-minion
    - watch:
      - /etc/salt/minion
