{%- import_yaml 'mcp_secret.sls' as mcp_secret -%}

freeipa:
  client_principal: 'admin'
  client_password: '{{ mcp_secret.freeipa.admin_password }}'
