{% raw %}{%- import_yaml 'mcp_secret.sls' as mcp_secret -%}{% endraw %}

freeipa:
  client_principal: 'admin'
  client_password: '{% raw %}{{ mcp_secret.freeipa.admin_password }}{% endraw %}'
