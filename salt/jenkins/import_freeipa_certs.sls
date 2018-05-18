{%- set freeipa_hostname = salt['pillar.get']('freeipa:hostname') -%}
{%- set freeipa_alias = freeipa_hostname|replace('.', '_') -%}
{%- set jenkins_home = salt['pillar.get']('data:path') ~ '/jenkins/jenkins_home' -%}

jenkins download freeipa cacert:
  cmd.run:
    - name: >
        openssl s_client -showcerts -connect {{ freeipa_hostname }}:443 < /dev/null 2> /dev/null |
        openssl x509 -outform PEM > {{ jenkins_home }}/{{ freeipa_alias }}.pem
    - creates: {{ jenkins_home }}/{{ freeipa_alias }}.pem
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

jenkins import freeipa cacert:
  cmd.run:
    - name: >
        docker exec jenkins keytool -v -noprompt -importcert
        -keystore {{ jenkins_home }}/.keystore/cacerts
        -storepass changeit
        -alias {{ freeipa_alias }}
        -file {{ jenkins_home }}/{{ freeipa_alias }}.pem
    - onchanges_any:
      - jenkins download freeipa cacert
      - jenkins copy java cacerts

jenkins restart:
  cmd.run:
    - name: docker restart jenkins
    - onchanges:
      - jenkins import freeipa cacert
