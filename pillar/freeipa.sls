{%- from 'defaults.sls' import master_domain -%}

freeipa:
  realm: 'magfest.org'
  hostname: 'ipa-01.{{ master_domain }}'
