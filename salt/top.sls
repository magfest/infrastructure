base:
  '*':
    - defaults

  'not bootstrap':
    - ufw
    # - freeipa_client

  'bootstrap or salt-master':
    - swap
    - pip
    - docker
    - salt_master

  'salt-master':
    - salt_cloud
    - docker_network_proxy
    - docker_traefik
    - docker_jenkins

  'freeipa*':
    - docker_freeipa
