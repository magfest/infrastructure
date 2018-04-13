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

{{ salt['pillar.get']('data_path') }}/jenkins/jenkins_home/:
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
    - binds: {{ salt['pillar.get']('data_path') }}/jenkins/jenkins_home:/var/jenkins_home
    - ports: 8080,50000
    - labels:
      - traefik.enable=true
      - traefik.frontend.rule=Host:jenkins.{{ salt['pillar.get']('master_domain') }}
      - traefik.web.frontend.entryPoints=http,https
      - traefik.web.port=8080
      - traefik.web.docker.network=docker_network_internal
      - traefik.jnlp.frontend.entryPoints=jnlp50000
      - traefik.jnlp.port=50000
      - traefik.jnlp.docker.network=docker_network_internal
    - networks:
      - docker_network_internal
    - require:
      - docker_network: docker_network_internal
