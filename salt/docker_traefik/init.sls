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
    # - auto_remove: True
    - watch:
      - file: {{ salt['pillar.get']('data_path') }}/traefik/etc/traefik/traefik.toml
    - binds:
      - /var/run/docker.sock:/var/run/docker.sock
      - {{ salt['pillar.get']('data_path') }}/traefik/etc/traefik/traefik.toml:/traefik.toml
      - {{ salt['pillar.get']('data_path') }}/traefik/etc/traefik/acme.json:/acme.json
    - ports: 80,443
    - port_bindings:
      - 80:80
      - 443:443
    - labels:
      - traefik.enable=true
      - traefik.frontend.rule=Host:traefik.{{ salt['pillar.get']('master_domain') }}
      - traefik.port=8080
      - traefik.docker.network=docker_network_internal
    - networks:
      - docker_network_external
      - docker_network_internal
    - require:
      - docker_network: docker_network_external
      - docker_network: docker_network_internal
