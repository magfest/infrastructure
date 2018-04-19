freeipa-client install:
  pkg.installed:
    - name: freeipa-client

ipa-client-install:
  cmd.run:
    - name: >
        ipa-client-install
        --domain={{ salt['pillar.get']('freeipa:realm')|lower }}
        --realm={{ salt['pillar.get']('freeipa:realm')|upper }}
        --principal=admin
        --password={{ salt['pillar.get']('freeipa_client:admin_password') }}
        --mkhomedir
        --no-ntp
        --unattended
    - require:
      - pkg: freeipa-client
