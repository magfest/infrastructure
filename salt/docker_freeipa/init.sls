{{ salt['pillar.get']('data_path') }}/ipa-data/:
  file.directory:
    - mode: 700
    - makedirs: True

docker_freeipa:
  docker_container.running:
    - name: freeipa
    - image: freeipa/freeipa-server:latest
    - auto_remove: True
    - binds: {{ salt['pillar.get']('data_path') }}/ipa-data:/data:Z
    - ports: 80
    - labels:
      - traefik.frontend.rule=Host:freeipa.{{ salt['pillar.get']('master_domain') }}
      - traefik.port=80
      - traefik.docker.network=docker_network_internal
    - networks:
      - docker_network_internal
    - require:
      - docker_network: docker_network_internal
