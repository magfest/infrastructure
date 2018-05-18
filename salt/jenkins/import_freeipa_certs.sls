{%- set freeipa_hostname = salt['pillar.get']('freeipa:hostname') -%}
{%- set freeipa_alias = freeipa_hostname|replace('.', '_') -%}
{%- set jenkins_home = salt['pillar.get']('data:path') ~ '/jenkins/jenkins_home/' -%}

download freeipa cacert:
  cmd.run:
    - name: >
        openssl s_client -showcerts -connect {{ freeipa_hostname }}:443 < /dev/null 2> /dev/null |
        openssl x509 -outform PEM > {{ freeipa_alias }}.pem
    - creates: {{ jenkins_home }}/{{ freeipa_alias }}.pem

{{ jenkins_home }}/.keystore/:
  file.directory:
    - user: jenkins
    - group: jenkins
    - mode: 700
    - makedirs: True
    - require:
      - user: jenkins

copy jenkins cacerts:
  cmd.run:
    - name: docker cp jenkins:/etc/ssl/certs/java/cacerts {{ jenkins_home }}/.keystore/
    - creates: {{ jenkins_home }}/.keystore/cacerts
    - require:
      - file: {{ jenkins_home }}/.keystore/

import freeipa cacert:
  cmd.run:
    - name: >
        docker exec jenkins keytool -v -noprompt -importcert
        -keystore {{ jenkins_home }}/.keystore/cacerts
        -storepass changeit
        -alias {{ freeipa_alias }}
        -file {{ jenkins_home }}/{{ freeipa_alias }}.pem
    - creates: {{ jenkins_home }}/.keystore/cacerts
    - onchanges:
      - copy jenkins cacerts
    - require_in:
      - jenkins


