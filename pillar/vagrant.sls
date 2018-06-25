master:
  domain: magfest.info
  address: saltmaster.magfest.info

freeipa:
  hostname: 'ipa-01.magfest.info'
  ui_domain: 'directory.magfest.info'

jenkins:
  user: 'vagrant'
  group: 'vagrant'

traefik:
  letsencrypt_enabled: False
  caServer: 'https://acme-staging.api.letsencrypt.org/directory'  # Staging server
  cert_names: ['ipa-01.magfest.info']
