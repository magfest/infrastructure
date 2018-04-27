include:
  - nodejs
  - npm

slack_irc user:
  user.present:
    - name: slack_irc

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
    - group: slack_irc
    - mode: 640
    - template: jinja

/var/log/slackbot.out.log chown slack_irc:
  file.managed:
    - name: /var/log/slackbot.out.log
    - user: slack_irc
    - group: slack_irc

/var/log/slackbot.err.log chown slack_irc:
  file.managed:
    - name: /var/log/slackbot.err.log
    - user: slack_irc
    - group: slack_irc

slack_irc service running:
  service.running:
    - name: slack_irc
    - watch_any:
      - file: /lib/systemd/system/slack-irc.service
      - file: /etc/slack-irc.conf.json
    - require:
      - pkg: nodejs
      - pkg: npm
