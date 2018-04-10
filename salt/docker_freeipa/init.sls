{{ salt['pillar.get']('data_path') }}/ipa-data/:
  file.directory:
    - mode: 700
    - makedirs: True

docker_freeipa:
  docker_container.running:
    - name: freeipa
    - image: freeipa/freeipa-server:latest
    - auto_remove: True
    - binds:
      - {{ salt['pillar.get']('data_path') }}/ipa-data:/data:Z
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    - ports: 53,80,53/udp,88/udp,88,389,443,123/udp,464,636,7389,9443-9445,464/udp
    - hostname: freeipa.{{ salt['pillar.get']('master_domain') }}
    - command: >
        /usr/local/sbin/init
        --realm={{ salt['pillar.get']('master_domain')|upper }}
        --ds-password=password
        --admin-password=password
    - labels:
      - traefik.enable=true
      - traefik.frontend.rule=Host:freeipa.{{ salt['pillar.get']('master_domain') }}
      - traefik.port=80
      - traefik.docker.network=docker_network_internal
    - networks:
      - docker_network_internal
    - require:
      - docker_network: docker_network_internal
