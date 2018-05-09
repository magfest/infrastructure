include:
  - docker_network_proxy

/etc/legacy_deploy/nginx/conf.d/default.conf:
  file.managed:
    - name: /etc/legacy_deploy/nginx/conf.d/default.conf
    - source: salt://legacy_magbot/deploy_log_server_nginx.conf
    - makedirs: True
    - template: jinja

deploy_log_server:
  docker_container.running:
    - name: magbot_deploy_log_server
    - image: nginx
    - auto_remove: True
    - binds:
      - /etc/legacy_deploy/nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf:ro
      - /var/log/legacy_deploy:/usr/share/nginx/html:ro
      - /var/log/legacy_deploy/nginx/error.log:/var/log/nginx/error.log
      - /var/log/legacy_deploy/nginx/access.log:/var/log/nginx/access.log
    - labels:
      - traefik.enable=true
      - traefik.frontend.rule=Host:{{ salt['pillar.get']('magbot:deploy_log_domain') }}
      - traefik.frontend.entryPoints=http,https
      - traefik.port=80
      - traefik.docker.network=docker_network_internal
    - networks:
      - docker_network_internal
    - watch:
      - file: /etc/legacy_deploy/nginx/conf.d/default.conf
    - require:
      - docker_network: docker_network_internal
      - sls: legacy_magbot
