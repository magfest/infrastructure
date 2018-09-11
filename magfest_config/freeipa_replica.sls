{% import_yaml 'defaults.sls' as defaults %}
{% set private_ip = salt['grains.get']('ip4_interfaces')[salt['grains.get']('private_interface', 'eth1')][0] %}


freeipa:
  server:
    enabled: True
