{%- set data_path = '/srv/volumes/data' -%}

master_address: 127.0.0.1
minion_id: salt-master
data_path: {{ data_path }}


ufw:
  enabled:
    True

  services:
    http:
      protocol: tcp
    https:
      protocol: tcp

  applications:
    OpenSSH:
      enabled: True
    Saltmaster:
      enabled: True

docker-pkg:
  lookup:
    config:
      - DOCKER_OPTS="--iptables=false"

docker-containers:
  lookup:
    nginx:
      image: 'nginx'
      runoptions:
        - '--name nginx'
        - '-p 80:80'
        - '-p 443:443'

    jenkins:
      image: 'jenkinsci/blueocean'
      runoptions:
        - '-p 8080:8080'
        - '-p 50000:50000'
        - '-v {{ data_path }}/jenkins_home:/var/jenkins_home'
        - '-u 1000'
