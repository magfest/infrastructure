include:
  - nodejs
  - npm

slack-irc user:
  user.present:
    - name: slack-irc

slack-irc:
  npm.installed:
    - name: slack-irc
    - require:
      - sls: nodejs
      - sls: npm

slack_irc service conf:
  file.managed:
    - name: /lib/systemd/system/slack-irc.service
    - source: salt://slack_irc/slack-irc.service
    - template: jinja

/etc/slack-irc.conf.json:
  file.managed:
    - name: /etc/slack-irc.conf.json
    - source: salt://slack_irc/slack-irc.conf.json
    - user: root
    - group: slack-irc
    - mode: 640
    - template: jinja

/var/log/slackbot.out.log chown slack-irc:
  file.managed:
    - name: /var/log/slackbot.out.log
    - user: slack-irc
    - group: slack-irc

/var/log/slackbot.err.log chown slack-irc:
  file.managed:
    - name: /var/log/slackbot.err.log
    - user: slack-irc
    - group: slack-irc

slack-irc service running:
  service.running:
    - name: slack-irc
    - watch_any:
      - file: /lib/systemd/system/slack-irc.service
      - file: /etc/slack-irc.conf.json
    - require:
      - sls: nodejs
      - sls: npm
