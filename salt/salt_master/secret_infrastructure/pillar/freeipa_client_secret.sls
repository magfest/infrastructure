{%- from 'mcp_secret.sls' import freeipa_admin_password -%}

freeipa:
  client_principal: 'admin'
  client_password: '{{ freeipa_admin_password }}'
