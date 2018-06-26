base:
  '*':
    - defaults

  'not bootstrap':
    - freeipa_client_secret
    - ignore_missing: True

  'mcp or bootstrap':
    - mcp

  'mcp':
    - digitalocean_secret
    - mcp_secret
    - magbot_secret
    - slack_irc_secret
    - ignore_missing: True

  'G@is_vagrant:True':
    - vagrant

  '*reggie* and G@roles:web':
    - reggie.web

  '*reggie* and G@roles:loadbalancer':
    - reggie.loadbalancer
