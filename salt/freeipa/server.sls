# ============================================================================
# Installs a FreeIPA server in a docker container
# ============================================================================

{% set hostname = salt['pillar.get']('freeipa:hostname') -%}
{%- set data_path = salt['pillar.get']('data:path') -%}
{%- set slapd_dse_ldif = (
    data_path
    ~ '/freeipa/ipa-data/etc/dirsrv/slapd-'
    ~ salt['pillar.get']('freeipa:realm')|replace('.', '-')|upper ~ '/dse.ldif') -%}

include:
  - docker_network_external
  - docker_network_internal

# rng-tools help generate entropy for the freeipa server install.
rng-tools install:
  pkg.installed:
    - name: rng-tools

# Custom rewrite rules to support proxying the web UI.
{{ data_path }}/freeipa/ipa-data/etc/httpd/conf.d/ipa-rewrite.conf:
  file.managed:
    - source: salt://freeipa/files/ipa-rewrite.conf
    - makedirs: True
    - template: jinja


# ============================================================================
# FreeIPA docker container
# ============================================================================

freeipa:
  docker_container.running:
    - name: freeipa
    - image: freeipa/freeipa-server:latest
    - auto_remove: True
    - binds:
      - {{ data_path }}/freeipa/ipa-data:/data:Z
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    - ports: 80,88,88/udp,123/udp,389,443,464,464/udp,636,7389/tcp,9443-9445/tcp
    - port_bindings:
      - 88:88  # kerberos
      - 88:88/udp  # kerberos
      - 464:464  # kpasswd
      - 464:464/udp  # kpasswd
      - 389:389  # ldap
      - 636:636  # ldapssl
      - 7389:7389  # ipa replica
      - 9443-9445:9443-9445  # ipa replica config
    - environment:
      - IPA_SERVER_INSTALL_OPTS: >
          --domain={{ salt['pillar.get']('freeipa:realm')|lower }}
          --realm={{ salt['pillar.get']('freeipa:realm')|upper }}
          --ds-password={{ salt['pillar.get']('freeipa:ds_password') }}
          --admin-password={{ salt['pillar.get']('freeipa:admin_password') }}
          --no-ntp
          --unattended
      - IPA_SERVER_HOSTNAME: {{ hostname }}
    - tmpfs:
      - /run: ''
      - /tmp: ''
    - labels:
      - traefik.enable=true
      - traefik.frontend.rule=Host:{{ hostname }},{{ salt['pillar.get']('freeipa:ui_domain') }}
      - traefik.frontend.entryPoints=http,https
      - traefik.port=80
      - traefik.docker.network=docker_network_internal
    - networks:
      - docker_network_external
      - docker_network_internal
    - watch:
      - file: {{ data_path }}/freeipa/ipa-data/etc/httpd/conf.d/ipa-rewrite.conf
    - require:
      - pkg: rng-tools
      - docker_network: docker_network_external
      - docker_network: docker_network_internal
      - file: {{ data_path }}/freeipa/ipa-data/etc/httpd/conf.d/ipa-rewrite.conf
    - require_in:
      - sls: freeipa.client

# Touch a file to indicate the FreeIPA server has installed successfully. The
# server install takes awhile, and the log file it generates is lengthy. Any
# states that depend on the FreeIPA server installation can use this state
# as a prerequisite.
freeipa install:
  cmd.run:
    - name: >
        grep 'The ipa-server-install command was successful'
        {{ data_path }}/freeipa/ipa-data/var/log/ipaserver-install.log &&
        touch {{ data_path }}/freeipa/ipa-data/var/log/ipaserver-install-complete
    - creates: {{ data_path }}/freeipa/ipa-data/var/log/ipaserver-install-complete
    - require_in:
      - sls: jenkins.import_freeipa_certs
      - sls: traefik.import_freeipa_certs
    - require:
      - freeipa


# ============================================================================
# Tighten LDAP security for slapd
# ============================================================================

# The ipa server MUST be stopped before making configuration changes. The ipa
# server dumps it's configuration on shutdown, so any changes made while it's
# running will be overwritten.
#
# This state stops the ipa server if it detects any of the expected
# configuration settings are missing.
freeipa stop ipa:
  cmd.run:
    - name: docker exec freeipa systemctl stop ipa
    - unless:
      - "grep 'nsslapd-allow-anonymous-access: rootdse' {{ slapd_dse_ldif }}"
      - "grep 'nsslapd-minssf: 56' {{ slapd_dse_ldif }}"
    - require:
      - freeipa install

# Disable anonymous binds.
freeipa slapd disable anonymous access:
  file.line:
    - name: {{ slapd_dse_ldif }}
    - content: 'nsslapd-allow-anonymous-access: rootdse'
    - before: '^nsslapd-allow-hashed-passwords:\s*on\s*$'
    - mode: ensure
    - require:
      - freeipa stop ipa

# Require StartTLS when using unencrypted port.
freeipa slapd require starttls:
  file.line:
    - name: {{ slapd_dse_ldif }}
    - content: 'nsslapd-minssf: 56'
    - before: '^nsslapd-minssf-exclude-rootdse:\s*on\s*$'
    - mode: ensure
    - require:
      - freeipa stop ipa

# Start ipa if it was stopped or any configuration changes were made.
freeipa start ipa:
  cmd.run:
    - name: docker exec freeipa systemctl start ipa
    - onchanges:
      - freeipa stop ipa
      - freeipa slapd disable anonymous access
      - freeipa slapd require starttls
