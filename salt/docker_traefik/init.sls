{{ salt['pillar.get']('data_path') }}/traefik/etc/traefik/traefik.toml:
  file.managed:
    - source: salt://docker_traefik/traefik.toml
    - mode: 644
    - makedirs: True
    - template: jinja

{{ salt['pillar.get']('data_path') }}/traefik/etc/traefik/acme.json:
  file.managed:
    - mode: 644

docker_traefik:
  docker_container.running:
    - name: traefik
    - image: traefik:latest
    - auto_remove: True
    - binds:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - {{ salt['pillar.get']('data_path') }}/traefik/etc/traefik/traefik.toml:/etc/traefik/traefik.toml
      - {{ salt['pillar.get']('data_path') }}/traefik/etc/traefik/acme.json:/etc/traefik/acme.json
    - ports: 80,443
    - port_bindings:
      - 80:80
      - 443:443
    - networks:
      - docker_intranet
    - require:
      - docker_network: docker_intranet
      - sls: letsencrypt
