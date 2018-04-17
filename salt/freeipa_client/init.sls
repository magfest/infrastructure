freeipa-client:
  pkg.installed

ipa-client-install:
  cmd.run:
    - name: >
        ipa-client-install
        --domain=ipa.magfest.net
        --server=ipa-01.magfest.net
        --server=ipa-02.magfest.net
        --realm=MAGFEST.ORG
        --principal=admin
        --password=password
        --unattended
        --mkhomedir
        --no-ntp
    - require:
      - pkg: freeipa-client
