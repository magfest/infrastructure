set hostname to minion id:
  cmd.run:
    - name: hostname {{ salt['grains.get']('id') }}
    - unless: test "$(hostname)" = "{{ salt['grains.get']('id') }}"
    - listen_in:
      - service: rsyslog
      {%- if salt['pillar.get']('filebeat:enabled') %}
      - service: filebeat
      {%- endif %}
