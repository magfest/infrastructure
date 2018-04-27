export HUBOT_AUTH_ADMIN="{{ salt['pillar.get']('auth_admin', '') }}"
export HUBOT_SLACK_TOKEN="{{ salt['pillar.get']('slack_token', '') }}"

export PORT="{{ salt['pillar.get']('port', '') }}"

export HUBOT_JIRA_URL="{{ salt['pillar.get']('jira_url', '') }}"
export HUBOT_JIRA_USER="{{ salt['pillar.get']('jira_user', '') }}"
export HUBOT_JIRA_PASSWORD="{{ salt['pillar.get']('jira_password', '') }}"
export HUBOT_JIRA_IGNOREUSERS="{{ salt['pillar.get']('jira_ignoreusers', '') }}"

# export HUBOT_LOG_LEVEL="debug"
