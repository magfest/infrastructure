{%- from 'salt_master/secret_pillar_templates/freeipa_secret.sls' import admin_password -%}

freeipa_client:
  realm: 'magfest.org'
  admin_password: {{ admin_password }}
