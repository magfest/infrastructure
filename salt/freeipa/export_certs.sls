{%- set freeipa_certs_dir = salt['pillar.get']('data:path') ~ '/freeipa/ipa-data/etc/httpd/alias' -%}
{%- set hostname = salt['pillar.get']('freeipa:hostname') -%}

libnss3-tools install:
  pkg.installed:
    - name: libnss3-tools

freeipa cert8.db:
  file.managed:
    - name: {{ freeipa_certs_dir }}/cert8.db
    - create: False

freeipa key3.db:
  file.managed:
    - name: {{ freeipa_certs_dir }}/key3.db
    - create: False

freeipa secmod.db:
  file.managed:
    - name: {{ freeipa_certs_dir }}/secmod.db
    - create: False

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
    - onchanges_any:
      - file: {{ freeipa_certs_dir }}/cert8.db
      - file: {{ freeipa_certs_dir }}/key3.db
      - file: {{ freeipa_certs_dir }}/secmod.db

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
      - file: {{ freeipa_certs_dir }}/{{ hostname }}.cert

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
      - file: {{ freeipa_certs_dir }}/{{ hostname }}.p12
