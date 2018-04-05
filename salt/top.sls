base:
  '*':
    - defaults

  'not bootstrap':
    - ufw

  'bootstrap':
    - salt_master

  'salt-master':
    - salt_master
    - salt_cloud
    - pip
    - docker
    - docker_internal_network
    - docker_nginx
    - docker_jenkins
