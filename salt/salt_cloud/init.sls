/etc/salt/cloud:
  file.managed:
    - source: salt://salt_cloud/salt_cloud.conf
    - template: jinja

/etc/salt/pki/cloud/digitalocean.pem:
  file.managed:
    - contents_pillar: digitalocean:private_key
    - mode: 600
    - dir_mode: 700
    - makedirs: True

/etc/salt/pki/cloud/digitalocean.pub:
  file.managed:
    - contents_pillar: digitalocean:public_key
    - mode: 644
    - dir_mode: 700
    - makedirs: True

/etc/salt/cloud.providers.d/digitalocean.conf:
  file.managed:
    - source: salt://salt_cloud/digitalocean.conf
    - makedirs: True
    - template: jinja

/etc/salt/cloud.profiles.d/dev-profiles.conf:
 file.managed:
   - source: salt://salt_cloud/dev-profiles.conf
   - makedirs: True
   - template: jinja

/etc/salt/cloud.profiles.d/staging-profiles.conf:
 file.managed:
   - source: salt://salt_cloud/staging-profiles.conf
   - makedirs: True
   - template: jinja

/etc/salt/cloud.profiles.d/prod-profiles.conf:
 file.managed:
   - source: salt://salt_cloud/prod-profiles.conf
   - makedirs: True
   - template: jinja
