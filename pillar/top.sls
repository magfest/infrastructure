base:
  '*':
    - defaults
    - freeipa

  'not bootstrap':
    - freeipa_client_secret

  'mcp or bootstrap':
    - mcp

  'mcp':
    - digitalocean_secret
    - freeipa_server_secret
    - mcp_secret
