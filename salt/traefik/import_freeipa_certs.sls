{%- set freeipa_certs_dir = salt['pillar.get']('data_path') ~ '/freeipa/ipa-data/etc/httpd/alias' -%}
{%- set traefik_certs_dir = salt['pillar.get']('data_path') ~ '/traefik/etc/traefik/certs' -%}

traefik default_cert.crt:
  file.copy:
    - name: {{ traefik_certs_dir }}/default_cert.crt
    - source: {{ freeipa_certs_dir }}/default_cert.crt
    - makedirs: True
    - force: True
    - onchanges:
      - file: {{ freeipa_certs_dir }}/default_cert.crt

traefik default_key.pem:
  file.copy:
    - name: {{ traefik_certs_dir }}/default_key.pem
    - source: {{ freeipa_certs_dir }}/default_key.pem
    - makedirs: True
    - force: True
    - onchanges:
      - file: {{ freeipa_certs_dir }}/default_key.pem
