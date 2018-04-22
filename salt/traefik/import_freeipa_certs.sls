{%- set freeipa_hostname = salt['pillar.get']('freeipa:hostname') -%}
{%- set freeipa_certs_dir = salt['pillar.get']('data:path') ~ '/freeipa/ipa-data/etc/httpd/alias' -%}
{%- set traefik_certs_dir = salt['pillar.get']('data:path') ~ '/traefik/etc/traefik/certs' -%}

traefik {{ freeipa_hostname }}.cert:
  file.copy:
    - name: {{ traefik_certs_dir }}/{{ freeipa_hostname }}.cert
    - source: {{ freeipa_certs_dir }}/{{ freeipa_hostname }}.cert
    - makedirs: True
    - force: True
    - onchanges:
      - sls: freeipa.export_certs
    - require_in:
      - sls: freeipa.client

traefik {{ freeipa_hostname }}.key:
  file.copy:
    - name: {{ traefik_certs_dir }}/{{ freeipa_hostname }}.key
    - source: {{ freeipa_certs_dir }}/{{ freeipa_hostname }}.key
    - makedirs: True
    - force: True
    - onchanges:
      - sls: freeipa.export_certs
    - require_in:
      - sls: freeipa.client
      - docker_container: traefik
