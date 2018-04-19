{%- set freeipa_certs_dir = salt['pillar.get']('data_path') ~ '/freeipa/ipa-data/etc/httpd/alias' -%}

libnss3-tools install:
  pkg.installed:
    - name: libnss3-tools

{{ freeipa_certs_dir }}:
  file.directory

freeipa default_cert.crt:
  cmd.run:
    - name: >
        certutil
        -L
        -a
        -n 'Server-Cert'
        -d {{ freeipa_certs_dir }}
        -o {{ freeipa_certs_dir }}/default_cert.crt
    - watch:
      - file: {{ freeipa_certs_dir }}*.db

freeipa default_key.p12:
  cmd.run:
    - name: >
        pk12util
        -W ''
        -n 'Server-Cert'
        -d {{ freeipa_certs_dir }}
        -k {{ freeipa_certs_dir }}/pwdfile.txt
        -o {{ freeipa_certs_dir }}/default_key.p12
    - onchanges:
      - file: {{ freeipa_certs_dir }}/default_cert.crt

freeipa default_key.pem:
  cmd.run:
    - name: >
        openssl
        pkcs12
        -nodes
        -in {{ freeipa_certs_dir }}/default_key.p12
        -out {{ freeipa_certs_dir }}/default_key.pem
    - onchanges:
      - file: {{ freeipa_certs_dir }}/default_key.p12
