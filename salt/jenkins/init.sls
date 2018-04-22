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

jenkins:
  docker_container.running:
    - name: jenkins
    - image: jenkinsci/blueocean:latest
    - auto_remove: True
    - binds: {{ salt['pillar.get']('data:path') }}/jenkins/jenkins_home:/var/jenkins_home
    - ports: 8080,50000
    - labels:
      - traefik.enable=true
      - traefik.frontend.rule=Host:jenkins.{{ salt['pillar.get']('master:domain') }}
      - traefik.frontend.entryPoints=http,https
      - traefik.port=8080
      - traefik.docker.network=docker_network_internal
    - networks:
      - docker_network_internal
    - require:
      - docker_network: docker_network_internal