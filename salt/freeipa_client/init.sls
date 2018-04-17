freeipa-client:
  pkg.installed

ipa-client-install:
  cmd.run:
    - name: >
        ipa-client-install
        --domain=freeipa.magfest.net
        --server=freeipa.magfest.net
        --realm=MAGFEST.ORG
        --fixed-primary
        --principal=admin
        --password=password
        --unattended
        --mkhomedir
        --no-ntp
    - require:
      - pkg: freeipa-client
