# ============================================================================
# Bootstrap salt minion
# ============================================================================

include:
  - rsyslog
  - salt_minion

bootstrap salt-minion:
  cmd.run:
    - name: >
        curl -L https://bootstrap.saltstack.com |
        sh -s -- -i '{{ salt["grains.get"]("id") }}' -P git 'v{{ salt["test.version"]() }}'
    - onlyif: systemctl status salt-minion | grep -q 'No such file'
    - require:
      - service: rsyslog
    - require_in:
      - file: /etc/salt/minion
      - service: salt-minion
