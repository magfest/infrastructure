base:
  '*':
    - defaults

  'not bootstrap':
    - freeipa_client_secret

  'mcp or bootstrap':
    - mcp

  'mcp':
    - digitalocean_secret
    - mcp_secret
