docker_nginx:
  docker_container.running:
    - image: nginx:latest
    - require:
      - pip install docker
