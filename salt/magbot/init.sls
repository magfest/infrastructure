magbot:
  docker_container.running:
    - name: magbot
    - image: errbot/err:python3master
    - auto_remove: True
