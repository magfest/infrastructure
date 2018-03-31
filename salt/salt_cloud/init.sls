salt_cloud:
  pkg.installed:
    - name: salt-cloud

salt-cloud conf:
  file.managed:
    - name: /etc/salt/cloud
    - source: salt://salt_cloud/conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja

/etc/salt/cloud.providers.d directory:
  file.directory:
    - name: /etc/salt/cloud.providers.d
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/etc/salt/cloud.providers.d digitalocean.conf:
  file.managed:
    - name: digitalocean.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
