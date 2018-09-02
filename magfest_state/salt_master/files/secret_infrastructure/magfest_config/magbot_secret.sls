magbot:
  auth_admin: ''
  slack_token: ''
  port: 9999
  jira_url: https://jira.magfest.net
  jira_user: magbot
  jira_password: ''
  jira_ignoreusers: jira
  salt_host: {{ salt['network.interface_ip'](salt['grains.get']('public_interface', 'eth0')) }}
  salt_username: ''
  salt_password: ''
  salt_api_url: https://{{ salt['network.interface_ip'](salt['grains.get']('public_interface', 'eth0')) }}:9000
