base:
  '*':
    - defaults

  'not bootstrap':
    - ufw
    - freeipa_client

  'bootstrap or salt-master':
    - swap
    - pip
    - salt_master
    - docker

  'salt-master':
    - salt_cloud
    - docker_network_proxy
    - docker_traefik
    - docker_freeipa
    - docker_jenkins
