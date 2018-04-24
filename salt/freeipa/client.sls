freeipa-client install:
  pkg.installed:
    - name: freeipa-client

ipa-client-install:
  cmd.run:
    - name: >
        ipa-client-install
        --domain={{ salt['pillar.get']('freeipa:realm')|lower }}
        --realm={{ salt['pillar.get']('freeipa:realm')|upper }}
        --principal={{ salt['pillar.get']('freeipa:client_principal') }}
        --password={{ salt['pillar.get']('freeipa:client_password') }}
        --mkhomedir
        --no-ntp
        --force-join
        --unattended
    - creates: /etc/ipa/default.conf
    - require:
      - pkg: freeipa-client
