base:
  '*':
    - defaults

  'not bootstrap':
    - ufw

  'bootstrap':
    - pip
    - salt_master

  'salt-master':
    - pip
    - salt_master
    - salt_cloud
    - docker
    - docker_intranet
    - docker_nginx_proxy
    - docker_jenkins
