{%- set master_domain = salt['pillar.get']('master:domain') -%}
{%- set hostname = salt['pillar.get']('freeipa:hostname') -%}

{{ salt['pillar.get']('data:path') }}/freeipa/ipa-data/:
  file.directory:
    - makedirs: True

freeipa:
  docker_container.running:
    - name: freeipa
    - image: freeipa/freeipa-server:latest
    - auto_remove: True
    - binds:
      - {{ salt['pillar.get']('data:path') }}/freeipa/ipa-data:/data:Z
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    - ports: 80,88,88/udp,123/udp,389,443,464,464/udp,636
    - port_bindings:
      - 88:88       # kerberos
      - 88:88/udp   # kerberos
      - 464:464     # kpasswd
      - 464:464/udp # kpasswd
      - 389:389     # ldap
      - 636:636     # ldapssl
    - environment:
      - IPA_SERVER_INSTALL_OPTS: >
          --domain={{ salt['pillar.get']('freeipa:realm')|lower }}
          --realm={{ salt['pillar.get']('freeipa:realm')|upper }}
          --ds-password={{ salt['pillar.get']('freeipa_server:ds_password') }}
          --admin-password={{ salt['pillar.get']('freeipa_client:admin_password') }}
          --no-ntp
          --unattended
      - IPA_SERVER_HOSTNAME: {{ hostname }}
    - tmpfs:
      - /run: ''
      - /tmp: ''
    - labels:
      - traefik.enable=true
      - traefik.frontend.rule=Host:directory.{{ master_domain }},{{ hostname }}
      - traefik.frontend.entryPoints=http,https
      # - traefik.frontend.passHostHeader=false
      # - traefik.frontend.headers.customRequestHeaders=Host:{{ hostname }}
      - traefik.port=443
      - traefik.protocol=https
      - traefik.docker.network=docker_network_internal
    - networks:
      - docker_network_external
      - docker_network_internal
    - require:
      - docker_network: docker_network_external
      - docker_network: docker_network_internal
      - pkg: rng-tools
      - file: {{ salt['pillar.get']('data:path') }}/freeipa/ipa-data/
    - require_in:
      - sls: freeipa.client
