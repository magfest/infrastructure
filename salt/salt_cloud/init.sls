salt_cloud:
  pkg.installed:
    - name: salt-cloud

/etc/salt/cloud file:
  file.managed:
    - name: /etc/salt/cloud
    - source: salt://salt_cloud/conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja

/etc/salt/pki/cloud directory:
  file.directory:
    - name: /etc/salt/pki/cloud
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

/etc/salt/pki/cloud/digitalocean.pem file:
  file.managed:
    - name: /etc/salt/pki/cloud/digitalocean.pem
    - source: salt://salt_cloud/digitalocean.pem
    - user: root
    - group: root
    - mode: 600

/etc/salt/pki/cloud/digitalocean.pub file:
  file.managed:
    - name: /etc/salt/pki/cloud/digitalocean.pub
    - source: salt://salt_cloud/digitalocean.pub
    - user: root
    - group: root
    - mode: 600

/etc/salt/cloud.providers.d directory:
  file.directory:
    - name: /etc/salt/cloud.providers.d
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/etc/salt/cloud.providers.d digitalocean.conf:
  file.managed:
    - name: /etc/salt/cloud.providers.d/digitalocean.conf
    - source: salt://salt_cloud/digitalocean.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
