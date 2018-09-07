{%- import_yaml 'defaults.sls' as defaults %}

jenkins:
  user: 'vagrant'
  group: 'vagrant'


traefik:
  letsencrypt_enabled: False
  caServer: 'https://acme-staging-v02.api.letsencrypt.org/directory'  # Staging server
  cert_names: ['{{ defaults.master.host_prefix }}ipa-01.{{ defaults.master.domain }}']
