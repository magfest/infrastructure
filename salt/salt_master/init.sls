salt_master:
  pkg.installed:
    - name: salt-master
  service.running:
    - name: salt-master
    - require:
      - pkg: salt-master
    - watch:
      - file: /etc/salt/master

/etc/salt/master:
  file.managed:
    - name: /etc/salt/master
    - source: salt://salt_master/salt_master.conf
    - mode: 644
    - template: jinja

/root/.ssh/:
  file.recurse:
    - name: /root/.ssh
    - source: salt://salt_master/ssh
    - dir_mode: 755
    - file_mode: 600
    - makedirs: True

/root/.ssh/authorized_keys:
  file.append:
    - name: /root/.ssh/authorized_keys
    - source: salt://salt_master/authorized_keys
    - makedirs: True

# /root/.ssh/*.pem:
#   file.check_perms:
#     - name: /root/.ssh/*.pem
#     - mode: 600
