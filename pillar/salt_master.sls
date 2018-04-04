master_address: 127.0.0.1
minion_id: salt-master

ufw:
  enabled:
    True
  applications:
    OpenSSH:
      enabled: True
    Saltmaster:
      enabled: True

docker-containers:
  lookup:
    jenkins:
      image: 'jenkinsci/blueocean'
