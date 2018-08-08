/etc/salt/cloud:
  file.managed:
    - source: salt://salt_cloud/files/salt_cloud.conf
    - template: jinja

/etc/salt/pki/cloud/digitalocean.pem:
  file.managed:
    - source: salt://salt_cloud/pki/digitalocean.pem
    - mode: 600
    - dir_mode: 700
    - makedirs: True

/etc/salt/pki/cloud/digitalocean.pub:
  file.managed:
    - source: salt://salt_cloud/pki/digitalocean.pub
    - mode: 644
    - dir_mode: 700
    - makedirs: True

/etc/salt/cloud.providers.d/digitalocean.conf:
  file.managed:
    - source: salt://salt_cloud/files/digitalocean.conf
    - makedirs: True
    - template: jinja
    - show_changes: False

/etc/salt/cloud.profiles.d/staging-profiles.conf:
  file.managed:
    - source: salt://salt_cloud/files/staging-profiles.conf
    - makedirs: True
    - template: jinja

/etc/salt/cloud.profiles.d/prod-profiles.conf:
  file.managed:
    - source: salt://salt_cloud/files/prod-profiles.conf
    - makedirs: True
    - template: jinja

/etc/salt/cloud.maps.d/staging.map:
  file.managed:
    - source: salt://salt_cloud/files/staging.map
    - makedirs: True
    - template: jinja

/etc/salt/cloud.maps.d/prod.map:
  file.managed:
    - source: salt://salt_cloud/files/prod.map
    - makedirs: True
    - template: jinja
