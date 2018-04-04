master_address: 127.0.0.1
minion_id: salt-master
data_path: /var/data


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


docker-containers:
  lookup:
    jenkins:
      image: 'jenkinsci/blueocean'
      runoptions:
        - '-p 8080:8080'
        - '-p 50000:50000'
        - '-v {{ salt["pillar.get"]("data_path") }}/jenkins_home:/var/jenkins_home'
