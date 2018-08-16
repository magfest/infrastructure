# ============================================================================
# Update bundled letsencrypt certificate
# ============================================================================

{%- set minion_id = salt['grains.get']('id') %}
{%- set letsencrypt_dir = '/etc/letsencrypt/live/' ~ minion_id %}
{%- set certs_dir = salt['pillar.get']('ssl:certs_dir') %}

/usr/local/bin/haproxy_bundle_letsencrypt_cert:
{%- if not salt['pillar.get']('letsencrypt') %}
  file.absent:
    - name: /usr/local/bin/haproxy_bundle_letsencrypt_cert
{% else %}
  file.managed:
    - name: /usr/local/bin/haproxy_bundle_letsencrypt_cert
    - template: jinja
    - mode: 744
    - contents: |
        #!/bin/bash

        # Bundles the LetsEncrypt cert chain & private key in a single file for HAProxy

        cat {{ letsencrypt_dir }}/fullchain.pem \
            {{ letsencrypt_dir }}/privkey.pem | \
            diff --report-identical-files {{ certs_dir }}/{{ minion_id }}.pem - > /dev/null

        if [ $? -ne 0 ]; then
            cat {{ letsencrypt_dir }}/fullchain.pem \
                {{ letsencrypt_dir }}/privkey.pem >| \
                {{ certs_dir }}/{{ minion_id }}.pem

            cp {{ letsencrypt_dir }}/fullchain.pem {{ certs_dir }}/{{ minion_id }}.crt
            cp {{ letsencrypt_dir }}/privkey.pem {{ certs_dir }}/{{ minion_id }}.key

            chmod 644 {{ certs_dir }}/{{ minion_id }}.crt
            chmod 600 {{ certs_dir }}/{{ minion_id }}.key
            chmod 600 {{ certs_dir }}/{{ minion_id }}.pem

            echo 'Updated {{ certs_dir }}/{{ minion_id }}.pem'
            systemctl reload haproxy
        else
            echo 'Already up to date {{ certs_dir }}/{{ minion_id }}.pem'
        fi

  cmd.run:
    - name: /usr/local/bin/haproxy_bundle_letsencrypt_cert
    - unless: |
        cat {{ letsencrypt_dir }}/fullchain.pem \
            {{ letsencrypt_dir }}/privkey.pem | \
            diff --report-identical-files {{ certs_dir }}/{{ minion_id }}.pem - > /dev/null
    - require:
      - file: /usr/local/bin/haproxy_bundle_letsencrypt_cert
    - watch:
      - certbot_{{ minion_id }}
{% endif %}


/etc/cron.d/haproxy_bundle_letsencrypt_cert:
{%- if not salt['pillar.get']('letsencrypt') %}
  file.absent:
    - name: /etc/cron.d/haproxy_bundle_letsencrypt_cert
{% else %}
  file.managed:
    - name: /etc/cron.d/haproxy_bundle_letsencrypt_cert
    - template: jinja
    - mode: 644
    - require:
      - file: /usr/local/bin/haproxy_bundle_letsencrypt_cert
    - contents: |
        # Runs the script to bundle the LetsEncrypt cert for HAProxy every day at 3:00 AM

        SHELL=/bin/sh
        PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

        # m h dom mon dow user  command
        0 3 * * *         root  /usr/local/bin/haproxy_bundle_letsencrypt_cert
{% endif %}
