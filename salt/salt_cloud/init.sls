salt_cloud:
  pkg.installed:
    - name: salt-cloud

/etc/salt/cloud:
  file.managed:
    - source: salt://salt_cloud/salt_cloud.conf
    - mode: 644
    - template: jinja

/etc/salt/pki/cloud/:
  file.directory:
    - mode: 700
    - makedirs: True

/etc/salt/pki/cloud/digitalocean.pem:
  file.managed:
    - contents_pillar: digitalocean:private_key
    - mode: 600

/etc/salt/pki/cloud/digitalocean.pub:
  file.managed:
    - contents_pillar: digitalocean:public_key
    - mode: 644

/etc/salt/cloud.providers.d/:
  file.directory:
    - mode: 755
    - makedirs: True

/etc/salt/cloud.providers.d/digitalocean.conf:
  file.managed:
    - source: salt://salt_cloud/digitalocean.conf
    - mode: 644
    - template: jinja
