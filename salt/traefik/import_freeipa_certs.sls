{%- set freeipa_hostname = salt['pillar.get']('freeipa:hostname') -%}
{%- set freeipa_certs_dir = salt['pillar.get']('data:path') ~ '/freeipa/ipa-data/etc/httpd/alias' -%}
{%- set traefik_certs_dir = salt['pillar.get']('data:path') ~ '/traefik/etc/traefik/certs' -%}

libnss3-tools install:
  pkg.installed:
    - name: libnss3-tools

freeipa {{ hostname }}.cert:
  cmd.run:
    - name: >
        certutil
        -L
        -a
        -n 'Server-Cert'
        -d {{ freeipa_certs_dir }}
        -o {{ freeipa_certs_dir }}/{{ hostname }}.cert
    - creates: {{ freeipa_certs_dir }}/{{ hostname }}.cert
    - onlyif: diff {{ freeipa_certs_dir }}/{{ hostname }}.cert {{ traefik_certs_dir }}/{{ hostname }}.cert

freeipa {{ hostname }}.p12:
  cmd.run:
    - name: >
        pk12util
        -W ''
        -n 'Server-Cert'
        -d {{ freeipa_certs_dir }}
        -k {{ freeipa_certs_dir }}/pwdfile.txt
        -o {{ freeipa_certs_dir }}/{{ hostname }}.p12
    - creates: {{ freeipa_certs_dir }}/{{ hostname }}.p12
    - onchanges:
      - freeipa {{ hostname }}.cert

freeipa {{ hostname }}.key:
  cmd.run:
    - name: >
        openssl
        pkcs12
        -nodes
        -passin pass:
        -in {{ freeipa_certs_dir }}/{{ hostname }}.p12
        -out {{ freeipa_certs_dir }}/{{ hostname }}.key
    - creates: {{ freeipa_certs_dir }}/{{ hostname }}.key
    - onchanges:
      - freeipa {{ hostname }}.p12

traefik {{ freeipa_hostname }}.cert:
  file.copy:
    - name: {{ traefik_certs_dir }}/{{ freeipa_hostname }}.cert
    - source: {{ freeipa_certs_dir }}/{{ freeipa_hostname }}.cert
    - makedirs: True
    - force: True
    - onchanges:
      - freeipa {{ hostname }}.cert
    - require_in:
      - sls: freeipa.client

traefik {{ freeipa_hostname }}.key:
  file.copy:
    - name: {{ traefik_certs_dir }}/{{ freeipa_hostname }}.key
    - source: {{ freeipa_certs_dir }}/{{ freeipa_hostname }}.key
    - makedirs: True
    - force: True
    - onchanges:
      - freeipa {{ hostname }}.key
    - require_in:
      - sls: freeipa.client
      - docker_container: traefik
