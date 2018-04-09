base:
  '*':
    - defaults

  'not bootstrap':
    - ufw

  'bootstrap':
    - pip
    - salt_master
    - docker

  'salt-master':
    - pip
    - salt_master
    - salt_cloud
    - docker
    - docker_intranet
    - docker_traefik
    - docker_jenkins
