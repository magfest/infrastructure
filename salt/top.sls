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
    - docker
    - docker_jenkins
    - docker.containers
