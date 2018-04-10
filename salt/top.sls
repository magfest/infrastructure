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
    - docker_network_proxy
    - docker_traefik
    - docker_freeipa
    - docker_jenkins
