jenkinsci/blueocean:
  docker_image.present:
    - sls: docker.images.appimage

jenkins_docker:
  docker_container.running:
    - image: jenkinsci/blueocean
    - require:
      - docker_image: jenkinsci/blueocean
