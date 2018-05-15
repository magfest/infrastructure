include:
  - docker_network_proxy

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

{{ salt['pillar.get']('data:path') }}/jenkins/jenkins_home/:
  file.directory:
    - user: jenkins
    - group: jenkins
    - mode: 700
    - makedirs: True
    - require:
      - user: jenkins

magbot:
  docker_container.running:
    - name: magbot
    - image: errbot/err:latest
    - auto_remove: True
    - binds: {{ salt['pillar.get']('data:path') }}/jenkins/jenkins_home:/var/jenkins_home
