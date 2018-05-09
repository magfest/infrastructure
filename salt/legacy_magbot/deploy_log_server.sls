include:
  - docker_network_proxy

deploy_log_server:
  docker_container.running:
    - name: magbot_deploy_log_server
    - image: nginx
    - auto_remove: True
    - binds: /var/log/legacy_deploy:/usr/share/nginx/html:ro
    - labels:
      - traefik.enable=true
      - traefik.frontend.rule=Host:{{ salt['pillar.get']('magbot:deploy_log_domain') }}
      - traefik.frontend.entryPoints=http,https
      - traefik.port=80
      - traefik.docker.network=docker_network_internal
    - networks:
      - docker_network_internal
    - require:
      - docker_network: docker_network_internal
      - sls: legacy_magbot
