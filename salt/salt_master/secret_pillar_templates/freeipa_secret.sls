{%- from 'salt_master/secret_pillar_templates/freeipa_client_secret.sls' import admin_password -%}

freeipa:
  ds_password: '{{ salt["random.get_str"](24) }}'
  admin_password: '{{ admin_password }}'
