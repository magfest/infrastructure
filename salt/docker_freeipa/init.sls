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
    - environment:
      - VIRTUAL_HOST: freeipa.{{ salt['pillar.get']('domain') }}
      - VIRTUAL_PORT: 80
    - networks:
      - docker_intranet
    - require:
      - docker_network: docker_intranet
