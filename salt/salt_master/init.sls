salt_master:
  pkg.installed:
    - name: salt-master
  service.running:
    - name: salt-master
    - require:
      - pkg: salt-master
    - watch:
      - file: /etc/salt/master

salt-master conf:
  file.managed:
    - name: /etc/salt/master
    - source: salt://salt_master/conf
    - user: root
    - group: root
    - mode: 644

/srv/salt directory:
  file.directory:
    - name: /srv/salt
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/srv/pillar directory:
  file.directory:
    - name: /srv/pillar
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
