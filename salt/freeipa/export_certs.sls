{%- set freeipa_certs_dir = salt['pillar.get']('data_path') ~ '/freeipa/ipa-data/etc/httpd/alias' -%}
{%- set hostname = salt['pillar.get']('freeipa:hostname') -%}

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
