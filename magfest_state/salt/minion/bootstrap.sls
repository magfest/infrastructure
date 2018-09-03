# ============================================================================
# Bootstrap salt minion
# ============================================================================

include:
  - rsyslog
  - salt.minion

bootstrap salt-minion:
  cmd.run:
    - name: >
        curl -L https://bootstrap.saltstack.com |
        sh -s -- -i '{{ salt["grains.get"]("id") }}' -P git 'v{{ salt["test.version"]() }}'
    - unless: test -f /usr/bin/salt-minion
    - require:
      - service: rsyslog
    - require_in:
      - file: /etc/salt/minion
      - service: salt-minion
