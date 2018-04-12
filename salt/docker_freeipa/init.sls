rng-tools:
  pkg.installed

{{ salt['pillar.get']('data_path') }}/ipa-data/:
  file.directory:
    - makedirs: True

docker_freeipa:
  docker_container.running:
    - name: freeipa
    - image: freeipa/freeipa-server:latest
    # - auto_remove: True
    - binds:
      - {{ salt['pillar.get']('data_path') }}/ipa-data:/data:Z
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    - ports: 53,80,53/udp,88/udp,88,389,443,123/udp,464,636,7389,9443-9445,464/udp
    - hostname: freeipa.{{ salt['pillar.get']('master_domain') }}
    - domainname: freeipa.{{ salt['pillar.get']('master_domain') }}
    - environment:
      - IPA_SERVER_INSTALL_OPTS: --realm=MAGFEST.ORG --ds-password=password --admin-password=password --hostname=freeipa.magfest.net --no-ntp --unattended
    - tmpfs:
      - /run: ''
      - /tmp: ''
    - labels:
      - traefik.enable=true
      - traefik.frontend.rule=Host:freeipa.{{ salt['pillar.get']('master_domain') }}
      - traefik.port=443
      - traefik.protocol=https
      - traefik.docker.network=docker_network_internal
    - networks:
      - docker_network_internal
    - require:
      - docker_network: docker_network_internal
