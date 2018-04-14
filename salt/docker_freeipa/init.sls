{%- set hostname = 'freeipa.' ~ salt['pillar.get']('master_domain') -%}

rng-tools:
  pkg.installed

{{ salt['pillar.get']('data_path') }}/freeipa/ipa-data/:
  file.directory:
    - makedirs: True

docker_freeipa:
  docker_container.running:
    - name: freeipa
    - image: freeipa/freeipa-server:latest
    - auto_remove: True
    - binds:
      - {{ salt['pillar.get']('data_path') }}/freeipa/ipa-data:/data:Z
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    - ports: 80,88,88/udp,123/udp,389,443,464,464/udp,636
    - environment:
      - IPA_SERVER_INSTALL_OPTS: >
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
      - traefik.frontend.rule=Host:{{ hostname }}

      - traefik.kerberos.docker.network=docker_network_internal
      - traefik.kerberos.frontend.entryPoints=kerberos
      - traefik.kerberos.port=88

      - traefik.kerberos_passwd.docker.network=docker_network_internal
      - traefik.kerberos_passwd.frontend.entryPoints=kerberos_passwd
      - traefik.kerberos_passwd.port=464

      - traefik.ldap.docker.network=docker_network_internal
      - traefik.ldap.frontend.entryPoints=ldap
      - traefik.ldap.port=389

      - traefik.ldapssl.docker.network=docker_network_internal
      - traefik.ldapssl.frontend.entryPoints=ldapssl
      - traefik.ldapssl.port=636

      - traefik.web.docker.network=docker_network_internal
      - traefik.web.frontend.entryPoints=https
      - traefik.web.port=443
      - traefik.web.protocol=https
    - networks:
      - docker_network_internal
    - require:
      - docker_network: docker_network_internal
    - require_in:
      - ipa-client-install
