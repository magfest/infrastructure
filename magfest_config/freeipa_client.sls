freeipa:
  client:
    enabled: True
    realm: 'magfest.org'
    hostname: {{ salt['grains.get']('fqdn', '') }}
