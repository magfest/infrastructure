jenkins group:
  group.present:
    - name: jenkins
    - gid: 1000

jenkins user:
  user.present:
    - name: jenkins
    - uid: 1000
    - gid: 1000
    - require:
      - group: jenkins

{{ salt['pillar.get']('data_path') }}/jenkins_home/:
  file.directory:
    - user: jenkins
    - group: jenkins
    - mode: 700
    - makedirs: True
    - require:
      - user: jenkins

docker_jenkins:
  docker_container.running:
    - name: jenkins
    - image: jenkinsci/blueocean:latest
    - auto_remove: True
    - binds: {{ salt['pillar.get']('data_path') }}/jenkins_home:/var/jenkins_home
    - labels:
      - traefik.frontend.rule=Host:{{ salt['pillar.get']('master_domain') }}
      - traefik.port=8080
    - networks:
      - docker_network_proxy
    - require:
      - docker_network: docker_network_proxy
