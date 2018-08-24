# ============================================================================
# Imports the FreeIPA CA certificate into the Jenkins JVM keystore
# ============================================================================

{% set freeipa_hostname = salt['pillar.get']('freeipa:hostname') -%}
{%- set freeipa_alias = freeipa_hostname|replace('.', '_') ~ '_ca' -%}
{%- set jenkins_home = salt['pillar.get']('data:path') ~ '/jenkins/jenkins_home' -%}
{%- set jenkins_user = salt['pillar.get']('jenkins:user') -%}
{%- set jenkins_group = salt['pillar.get']('jenkins:group') %}

# Download the FreeIPA CA certificate
{{ jenkins_home }}/{{ freeipa_alias }}.pem:
  file.managed:
    - name: {{ jenkins_home }}/{{ freeipa_alias }}.pem
    - source:
      {% if salt['pillar.get']('traefik:letsencrypt_enabled') -%}
      - https://{{ freeipa_hostname }}/ipa/config/ca.crt
      {%- else -%}
      - http://{{ freeipa_hostname }}/ipa/config/ca.crt
      {%- endif %}
    - skip_verify: True
    - user: {{ jenkins_user }}
    - group: {{ jenkins_group }}
    - mode: 600
    - require:
      - sls: docker_jenkins

# Import the downloaded FreeIPA CA certificate into Jenkin's keystore
docker_jenkins import freeipa cacert:
  cmd.run:
    - name: >
        docker exec jenkins keytool -v -noprompt -delete
        -keystore /var/jenkins_home/.keystore/cacerts
        -storepass changeit
        -alias {{ freeipa_alias }}
        ||
        docker exec jenkins keytool -v -noprompt -importcert
        -keystore /var/jenkins_home/.keystore/cacerts
        -storepass changeit
        -alias {{ freeipa_alias }}
        -file /var/jenkins_home/{{ freeipa_alias }}.pem
    - onchanges:
      - {{ jenkins_home }}/{{ freeipa_alias }}.pem

# Restart Jenkins if there are any changes
docker_jenkins restart:
  cmd.run:
    - name: docker restart jenkins
    - onchanges:
      - docker_jenkins import freeipa cacert
