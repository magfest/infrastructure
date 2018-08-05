# ============================================================================
# Logging configuration
# ============================================================================

/var/log/salt/:
  file.directory:
    - name: /var/log/salt/
    - makedirs: True
    - user: syslog
    - group: adm

/etc/rsyslog.d/salt-minion.conf:
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
# SSH login configuration
# ============================================================================

/root/.ssh/authorized_keys:
  file.append:
    - text:
      - 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2eSXsBB78a1s0/Dr6CZ4fbtnuQAuY8/p+efHnP16/IHYKsdEwAz+W+NppnLVkeV8pm9YSMpbiiD6fjncctmi73PzUM9JHCAyi5ImRsKi9KmNNpGjNlwZACUIIFTVnJmOGXUEHU5rnNTUJR41UuJtY8PrxpQxrN3bWjcrgIFNRRwBk0RHl6m5jfTP7RZ3ie8ipfrWYdsSitwhr+VD1+5uTfPMzpnpe4jvBKWAWoP72Dn0lfD+/ht9kg0YziWLLgJrmTWKPqBhLNXkFW5sXUwrFYIoJkCADZL4SAIIxJbXrfaSzRRVSy5vFdwvcFhR0/9afF13puXmrxorNAvjIA3Dv saltmaster@magfest.org'
      - 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCcOrXauQnNPMqsdw1pDqZlVnx0B80mu/ZJK9TptZVM6/oSgWArO9o3kuTQJpE/GfEwY+z3mQBnrR9IYVhNXS2ouaJy8TvvGredvBNOIk3mX083jIHYeRWBiSBctCmanR3Zuz7XEarCO2SdL5nk9lF0viX83fRHjHNsmN7zIi8tYdPK9ITfnLzGfKXn9TK+IFVMNZ002zQeTFGT63E2JZCh+BotMeEzPOcm5W12F3r1PTV579jyPemtc5iLBJX2LD7RbuCmHi7UL948Crqtq1Y1RiGuGFOGx6+pp6D/gSgGDIsEdbEaejlN14rqcWaDrU2D5BNFHbx5UiCLXT4sx8Nv robruana@magfest.org'
      - 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJKBZzNEJxzeLOytMa6lhz2DiRjlHxXvG/qfFIa2SZXY/+IPb7MYEbDhCVBCmSBRgcEx0XqRLs865om/R0t0zUrH5IDwojveQ92I3DzKjkAtrwSbAFpFqNp4vC0+N0ZS0t+lKpMXSlczbwKvZ9LdvHKwDVVjhJDqhvwuiyXCnuTa2ad4ZoAAlBVyn7FCKAXlxfyX0+Kk+J7YLhEm2UGSXmkX61g28I0BczXiPE9veUZtO6POFZ8puX0Av3Pv2rZEPBdpCJYPtUsOpOAXJgYudP9V7ztlcU2nVbPwiBN+ZK9yfYzQa8OWjIUSgUudM7eFRVFu1s0Kyg8xC0VRFYKY6l dom@magfest.org'

/root/.ssh/known_hosts:
  cmd.run:
    - name: ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts 2>&1
    - unless: grep -q 'github\.com' /root/.ssh/known_hosts


# ============================================================================
# Salt minion configuration
# ============================================================================

{% if salt['pillar.get']('minion') %}
/etc/salt/minion:
  file.append:
    - name: /etc/salt/minion
    - template: jinja
    - text:
      {%- for key, value in salt['pillar.get']('minion').items() %}
      - |
         {{ {key: value}|yaml(False)|indent(9) }}
      {%- endfor %}
{% endif %}

salt_minion:
  service.running:
    - name: salt-minion
    - enable: True
    - order: last
    - watch:
      - file: /etc/salt/minion
