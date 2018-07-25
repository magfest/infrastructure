# ============================================================================
# Generate self-signed certs
# ============================================================================
{%- set certs_dir = salt['pillar.get']('ssl:certs_dir') -%}
{%- set minion_id = salt['grains.get']('id') %}

include:
  - pip

pip install pyopenssl:
  pip.installed:
    - name: pyopenssl
    - reload_modules: True

create self signed cert:
  module.run:
    - tls.create_self_signed_cert:
      - tls_dir: '.'
      - CN: {{ minion_id }}
      - C: US
      - ST: Maryland
      - L: Baltimore
      - cacert_path: {{ salt['pillar.get']('ssl:dir') }}
    - unless: test -f {{ certs_dir }}/{{ minion_id }}.crt

bundle self signed cert:
  cmd.run:
    - name: cat {{ certs_dir }}/{{ minion_id }}.crt {{ certs_dir }}/{{ minion_id }}.key > {{ certs_dir }}/{{ minion_id }}.pem
    - creates: {{ certs_dir }}/{{ minion_id }}.pem
