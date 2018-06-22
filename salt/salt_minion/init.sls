# ============================================================================
# Baseline config
# ============================================================================

update-locale LANG="en_US.UTF-8":
  cmd.run:
    - name: update-locale LANG="en_US.UTF-8"
    - unless: grep -q -E "LANG=[\"']?en_US.UTF-8[\"']?" /etc/default/locale


# ============================================================================
# Logging configuration
# ============================================================================

/var/log/salt/ minion log dir:
  file.directory:
    - name: /var/log/salt/
    - makedirs: True
    - user: syslog
    - group: adm

salt-minion rsyslog conf:
  file.managed:
    - name: /etc/rsyslog.d/salt-minion.conf
    - contents: |
        if $programname == 'salt-minion' then /var/log/salt/minion.log
        if $programname == 'salt-minion' then ~
    - listen_in:
      - service: rsyslog

/etc/logrotate.d/salt-minion:
  file.managed:
    - name: /etc/logrotate.d/salt-minion
    - contents: |
        /var/log/salt/minion.log {
            daily
            missingok
            rotate 52
            compress
            delaycompress
            notifempty
            create 640 syslog adm
            sharedscripts
            postrotate
                invoke-rc.d rsyslog rotate > /dev/null
            endscript
        }


# ============================================================================
# Salt minion configuration
# ============================================================================

/etc/salt/minion conf:
  file.managed:
    - name: /etc/salt/minion
    - source: salt://salt_minion/files/salt_minion.conf
    - mode: 644
    - template: jinja

salt_minion:
  service.running:
    - name: salt-minion
    - enable: True
    - watch:
      - /etc/salt/minion
