# ============================================================================
# Generate self-signed certs
# ============================================================================
{%- set certs_dir = salt['pillar.get']('ssl:certs_dir') %}

pip install pyopenssl:
  pip.installed:
    - name: pyopenssl
    - reload_modules: True
    - require:
      - reggie python install

create self signed cert:
  module.run:
    - name: tls.create_self_signed_cert
    - tls_dir: '.'
    - cacert_path: {{ salt['pillar.get']('ssl:dir') }}
    - unless: test -f {{ certs_dir }}/default.crt

bundle self signed cert:
  cmd.run:
    - name: cat {{ certs_dir }}/default.crt {{ certs_dir }}/default.key > {{ certs_dir }}/default.pem
    - creates: {{ certs_dir }}/default.pem
