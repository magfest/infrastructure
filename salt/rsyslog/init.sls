rsyslog install:
  pkg.installed:
    - name: rsyslog

rsyslog:
  service.running:
    - enable: True
    - name: rsyslog
    - require:
      - pkg: rsyslog
