# ============================================================================
# Logging configuration
# ============================================================================

salt-minion rsyslog conf:
  file.managed:
    - name: /etc/rsyslog.d/salt-minion.conf
    - contents: |
        if $programname == 'salt-minion' then /var/log/salt/minion.log
        if $programname == 'salt-minion' then ~
    - watch_in:
      - service: rsyslog

/etc/logrotate.d/salt-minion:
  file.managed:
    - name: /etc/logrotate.d/salt-minion
    - contents: |
        /var/log/salt/minion.log {
            weekly
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
    - source: salt://salt_minion/salt_minion.conf
    - mode: 644
    - template: jinja

salt_minion:
  service.running:
    - name: salt-minion
    - watch:
      - /etc/salt/minion
