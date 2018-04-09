/etc/traefik/traefik.toml:
  file.managed:
    - source: salt://docker_traefik/traefik.toml
    - mode: 644
    - template: jinja

docker_traefik:
  docker_container.running:
    - name: traefik
    - image: traefik:latest
    - auto_remove: True
    - binds:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - /etc/traefik/traefik.toml:/etc/traefik/traefik.toml
    - ports: 80,443
    - port_bindings:
      - 80:80
      - 443:443
    - networks:
      - docker_intranet
    - require:
      - docker_network: docker_intranet
      - sls: letsencrypt
