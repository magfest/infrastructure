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
    - port_bindings:
      - 80:80       # http
      - 443:443     # https
      - 88:88       # kerberos
      - 88:88/udp   # kerberos
      - 464:464     # kerberos_passwd
      - 464:464/udp # kerberos_passwd
      - 389:389     # ldap
      - 636:636     # ldapssl
    - environment:
      - IPA_SERVER_INSTALL_OPTS: {{ salt['pillar.get']('freeipa:install_opts') }}
      - IPA_SERVER_HOSTNAME: {{ salt['pillar.get']('freeipa:hostname') }}
    - tmpfs:
      - /run: ''
      - /tmp: ''
    - require:
      - pkg: rng-tools
      - file: {{ salt['pillar.get']('data_path') }}/freeipa/ipa-data/
      - sls: docker
    - require_in:
      - ipa-client-install
