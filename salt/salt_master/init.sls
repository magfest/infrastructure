salt_master:
  pkg.installed:
    - name: salt-master
  service.running:
    - name: salt-master
    - require:
      - pkg: salt-master
    - watch:
      - file: /etc/salt/master

/etc/salt/master file:
  file.managed:
    - name: /etc/salt/master
    - source: salt://salt_master/salt_master.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja

/root/.ssh directory:
  file.recurse:
    - name: /root/.ssh
    - user: root
    - group: root
    - dir_mode: 700
    - file_mode: 600
    - makedirs: True
