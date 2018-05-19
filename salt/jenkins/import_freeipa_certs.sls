{%- set freeipa_hostname = salt['pillar.get']('freeipa:hostname') -%}
{%- set freeipa_alias = freeipa_hostname|replace('.', '_') ~ '_ca' -%}
{%- set jenkins_home = salt['pillar.get']('data:path') ~ '/jenkins/jenkins_home' -%}


{{ jenkins_home }}/{{ freeipa_alias }}.pem:
  file.managed:
    - name: {{ jenkins_home }}/{{ freeipa_alias }}.pem
    - source: https://{{ freeipa_hostname }}/ipa/ui/ca.crt
    - user: jenkins
    - group: jenkins
    - mode: 600
    - require:
      - sls: jenkins

{{ jenkins_home }}/.keystore/:
  file.directory:
    - user: jenkins
    - group: jenkins
    - mode: 700
    - makedirs: True
    - require:
      - sls: jenkins

jenkins copy java cacerts:
  cmd.run:
    - name: docker cp jenkins:/etc/ssl/certs/java/cacerts {{ jenkins_home }}/.keystore/
    - creates: {{ jenkins_home }}/.keystore/cacerts
    - require:
      - file: {{ jenkins_home }}/.keystore/

{{ jenkins_home }}/.keystore/cacerts:
  file.managed:
    - name: {{ jenkins_home }}/.keystore/cacerts
    - user: jenkins
    - group: jenkins
    - mode: 600
    - require:
      - jenkins copy java cacerts

jenkins import freeipa cacert:
  cmd.run:
    - name: >
        docker exec jenkins keytool -v -noprompt -importcert
        -keystore /var/jenkins_home/.keystore/cacerts
        -storepass changeit
        -alias {{ freeipa_alias }}
        -file /var/jenkins_home/{{ freeipa_alias }}.pem
    - require:
      - {{ jenkins_home }}/.keystore/cacerts
    - onchanges:
      - {{ jenkins_home }}/{{ freeipa_alias }}.pem

jenkins restart:
  cmd.run:
    - name: docker restart jenkins
    - onchanges:
      - jenkins import freeipa cacert
