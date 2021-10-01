# ============================================================================
# Generate self-signed certs
# ============================================================================

{%- set certs_dir = salt['pillar.get']('ssl:certs_dir') -%}
{%- set minion_id = salt['grains.get']('id') %}

{{ certs_dir }}/{{ minion_id }}.pem:
  pkg.installed:
    - name: python-pip
    - reload_modules: True

  pip.installed:
    - name: pyopenssl
    - env_bin: /usr/bin/pip
    - reload_modules: True

  module.run:
    - tls.create_self_signed_cert:
      - tls_dir: '.'
      - CN: {{ minion_id }}
      - C: US
      - ST: Maryland
      - L: Baltimore
      - cacert_path: {{ salt['pillar.get']('ssl:dir') }}
    - unless: test -f {{ certs_dir }}/{{ minion_id }}.crt

  cmd.run:
    - name: cat {{ certs_dir }}/{{ minion_id }}.crt {{ certs_dir }}/{{ minion_id }}.key > {{ certs_dir }}/{{ minion_id }}.pem
    - unless: >
        cat {{ certs_dir }}/{{ minion_id }}.crt {{ certs_dir }}/{{ minion_id }}.key |
        diff --report-identical-files {{ certs_dir }}/{{ minion_id }}.pem - > /dev/null
