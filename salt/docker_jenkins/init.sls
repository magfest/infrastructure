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
    - ports: 8080,50000
    - networks:
      - docker_intranet
    - require:
      - docker_network: docker_intranet
