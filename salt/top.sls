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
    - docker_intranet
    - docker_nginx_proxy
    - docker_jenkins
