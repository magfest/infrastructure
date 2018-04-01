salt_cloud:
  pkg.installed:
    - name: salt-cloud

/etc/salt/cloud:
  file.managed:
    - name: /etc/salt/cloud
    - source: salt://salt_cloud/salt_cloud.conf
    - mode: 644
    - template: jinja

/etc/salt/pki/cloud/:
  file.directory:
    - name: /etc/salt/pki/cloud
    - mode: 700
    - makedirs: True

/etc/salt/pki/cloud/digitalocean.pem:
  file.managed:
    - name: /etc/salt/pki/cloud/digitalocean.pem
    - source: salt://salt_cloud/digitalocean.pem
    - mode: 600

/etc/salt/pki/cloud/digitalocean.pub:
  file.managed:
    - name: /etc/salt/pki/cloud/digitalocean.pub
    - source: salt://salt_cloud/digitalocean.pub
    - mode: 600

/etc/salt/cloud.providers.d/:
  file.directory:
    - name: /etc/salt/cloud.providers.d
    - mode: 755
    - makedirs: True

/etc/salt/cloud.providers.d digitalocean.conf:
  file.managed:
    - name: /etc/salt/cloud.providers.d/digitalocean.conf
    - source: salt://salt_cloud/digitalocean.conf
    - mode: 644
    - template: jinja
