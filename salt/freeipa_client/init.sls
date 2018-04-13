freeipa-client:
  pkg.installed

ipa-client-install:
  cmd.run:
    - name: >
        ipa-client-install
        --mkhomedir
        --domain=freeipa.magfest.net
        --server=freeipa.magfest.net
        --realm=MAGFEST.ORG
        --fixed-primary
        --principal=admin
        --password=password
        --unattended
        --permit
    - order: last
    - require:
      - pkg: freeipa-client
