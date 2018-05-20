# ============================================================================
# Imports the FreeIPA CA certificate into the Jenkins JVM keystore
# ============================================================================

{% set freeipa_hostname = salt['pillar.get']('freeipa:hostname') -%}
{%- set freeipa_alias = freeipa_hostname|replace('.', '_') ~ '_ca' -%}
{%- set jenkins_home = salt['pillar.get']('data:path') ~ '/jenkins/jenkins_home' -%}

# Download the FreeIPA CA certificate
{{ jenkins_home }}/{{ freeipa_alias }}.pem:
  file.managed:
    - name: {{ jenkins_home }}/{{ freeipa_alias }}.pem
    - source: https://{{ freeipa_hostname }}/ipa/config/ca.crt
    - skip_verify: True
    - user: jenkins
    - group: jenkins
    - mode: 600
    - require:
      - sls: jenkins

# Import the downloaded FreeIPA CA certificate into Jenkin's keystore
jenkins import freeipa cacert:
  cmd.run:
    - name: >
        docker exec jenkins keytool -v -noprompt -importcert
        -keystore /var/jenkins_home/.keystore/cacerts
        -storepass changeit
        -alias {{ freeipa_alias }}
        -file /var/jenkins_home/{{ freeipa_alias }}.pem
    - onchanges:
      - {{ jenkins_home }}/{{ freeipa_alias }}.pem

# Restart Jenkins if there are any changes
jenkins restart:
  cmd.run:
    - name: docker restart jenkins
    - onchanges:
      - jenkins import freeipa cacert
