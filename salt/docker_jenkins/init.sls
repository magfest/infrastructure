jenkins group:
  group.present:
    - name: jenkins
    - gid: 1000

jenkins user:
  user.present:
    - require:
      - jenkins group
    - name: jenkins
    - uid: 1000
    - gid: 1000

{{ salt['pillar.get']('data_path') }}/jenkins_home/:
  file.directory:
    - require:
      - jenkins user
    - user: jenkins
    - group: jenkins
    - mode: 700
    - makedirs: True
