{{ salt['pillar.get']('data_path') }}/traefik/etc/traefik/traefik.toml:
  file.managed:
    - source: salt://docker_traefik/traefik.toml
    - mode: 644
    - makedirs: True
    - template: jinja

{{ salt['pillar.get']('data_path') }}/traefik/etc/traefik/acme.json:
  file.managed:
    - mode: 600
    - makedirs: True

docker_traefik:
  docker_container.running:
    - name: traefik
    - image: traefik:latest
    - auto_remove: True
    - binds:
      - /var/run/docker.sock:/var/run/docker.sock
      - {{ salt['pillar.get']('data_path') }}/traefik/etc/traefik/traefik.toml:/traefik.toml
      - {{ salt['pillar.get']('data_path') }}/traefik/etc/traefik/acme.json:/acme.json
    - labels:
      - 'traefik.port=8080'
    - port_bindings:
      - 80:80
    - networks:
      - docker_network_proxy
    - require:
      - docker_network: docker_network_proxy
