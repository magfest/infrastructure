# ============================================================================
# Disable transparent_hugepage, see: https://redis.io/topics/latency
# ============================================================================

{% for setting in ['enabled', 'defrag'] %}
transparent_hugepage never {{ setting }}:
  cmd.run:
    - name: echo never > /sys/kernel/mm/transparent_hugepage/{{ setting }}
    - unless: grep -q '\[never\]' /sys/kernel/mm/transparent_hugepage/{{ setting }}
{% endfor %}


disable_transparent_hugepage.service:
  file.managed:
    - name: /lib/systemd/system/disable_transparent_hugepage.service
    - contents: |
        [Unit]
        Description="Disable transparent hugepage before redis starts"
        Before=redis.service

        [Service]
        Type=oneshot
        ExecStart=/bin/bash -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'
        ExecStart=/bin/bash -c 'echo never > /sys/kernel/mm/transparent_hugepage/defrag'

        [Install]
        RequiredBy=redis.service

  module.watch:
    - name: service.available
    - m_name: disable_transparent_hugepage.service
    - require:
      - file: disable_transparent_hugepage.service
    - watch:
      - file: disable_transparent_hugepage.service


