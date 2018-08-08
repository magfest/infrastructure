set hostname to minion id:
  file.replace:
    - name: /etc/cloud/cloud.cfg
    - pattern: '^\s*preserve_hostname:\s+[Ff]alse\s*$'
    - repl: 'preserve_hostname: true'

  cmd.run:
    - name: hostnamectl set-hostname {{ salt['grains.get']('id') }}
    - unless: test "$(hostname)" = "{{ salt['grains.get']('id') }}"
    - watch:
      - file: /etc/cloud/cloud.cfg
    - listen_in:
      - service: rsyslog
      {%- if salt['pillar.get']('filebeat:enabled') %}
      - service: filebeat
      {%- endif %}
