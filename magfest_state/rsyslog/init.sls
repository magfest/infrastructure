rsyslog service:
  pkg.installed:
    - name: rsyslog

  service.running:
    - name: rsyslog
    - enable: True
    - require:
      - pkg: rsyslog
