export HUBOT_AUTH_ADMIN="{{ salt['pillar.get']('magbot:auth_admin', '') }}"
export HUBOT_SLACK_TOKEN="{{ salt['pillar.get']('magbot:slack_token', '') }}"

export PORT="{{ salt['pillar.get']('magbot:port', '') }}"

export HUBOT_JIRA_URL="{{ salt['pillar.get']('magbot:jira_url', '') }}"
export HUBOT_JIRA_USER="{{ salt['pillar.get']('magbot:jira_user', '') }}"
export HUBOT_JIRA_PASSWORD="{{ salt['pillar.get']('magbot:jira_password', '') }}"
export HUBOT_JIRA_IGNOREUSERS="{{ salt['pillar.get']('magbot:jira_ignoreusers', '') }}"

# export HUBOT_LOG_LEVEL="debug"
