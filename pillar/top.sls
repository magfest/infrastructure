base:
  '*':
    - defaults
    - freeipa_client_secret

  'bootstrap or mcp':
    - mcp
    - mcp_secret

  'mcp':
    - digitalocean_secret
    - freeipa
    - freeipa_secret
