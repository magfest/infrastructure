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
    - networks:
      - docker_network_proxy
    - require:
      - docker_network: docker_network_proxy
